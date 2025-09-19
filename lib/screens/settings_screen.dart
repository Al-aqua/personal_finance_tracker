import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/transaction_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final SettingsService _settingsService = SettingsService();
  final TransactionService _transactionService = TransactionService();

  bool _darkMode = false;
  bool _notifications = true;
  String _currency = 'USD';
  bool _isLoading = true;
  bool _isSyncing = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final currency = await _settingsService.getCurrency();
      final darkMode = await _settingsService.getDarkMode();
      final notifications = await _settingsService.getNotifications();

      setState(() {
        _currency = currency;
        _darkMode = darkMode;
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDarkMode(bool value) async {
    await _settingsService.setDarkMode(value);
    setState(() {
      _darkMode = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dark mode ${value ? 'enabled' : 'disabled'}')),
      );
    }
  }

  Future<void> _updateNotifications(bool value) async {
    await _settingsService.setNotifications(value);
    setState(() {
      _notifications = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
        ),
      );
    }
  }

  Future<void> _updateCurrency(String currency) async {
    await _settingsService.setCurrency(currency);
    setState(() {
      _currency = currency;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Currency changed to $currency')));
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _transactionService.syncToCloud();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _authService.signOut();
        // AuthWrapper will automatically navigate to login screen
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign out failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _currentUser?.displayName
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currentUser?.email ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Synced',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Preferences Section
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Enable dark theme'),
                  value: _darkMode,
                  onChanged: _updateDarkMode,
                  secondary: const Icon(Icons.dark_mode),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Receive transaction alerts'),
                  value: _notifications,
                  onChanged: _updateNotifications,
                  secondary: const Icon(Icons.notifications),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Currency'),
                  subtitle: Text('Current: $_currency'),
                  leading: const Icon(Icons.attach_money),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showCurrencyDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cloud Sync Section
          const Text(
            'Cloud & Sync',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Sync Data'),
                  subtitle: const Text('Upload local data to cloud'),
                  leading: _isSyncing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_sync),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _isSyncing ? null : _syncData,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Account Info'),
                  subtitle: const Text('Manage your account settings'),
                  leading: const Icon(Icons.account_circle),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account management coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions Section
          const Text(
            'Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export Data'),
                  subtitle: const Text('Download your transaction data'),
                  leading: const Icon(Icons.download),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon!'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('About'),
                  subtitle: const Text('App version and info'),
                  leading: const Icon(Icons.info),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showAboutDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Sign out of your account'),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['USD', 'EUR', 'GBP', 'JPY'].map((currency) {
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: _currency,
                onChanged: (value) {
                  if (value != null) {
                    _updateCurrency(value);
                  }
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Personal Finance Tracker',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet),
      children: [
        const Text('A simple app to track your personal finances.'),
        const SizedBox(height: 16),
        const Text('Now with cloud sync powered by Firebase!'),
      ],
    );
  }
}
