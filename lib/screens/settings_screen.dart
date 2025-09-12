import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _darkMode = false;
  bool _notifications = true;
  String _currency = 'USD';
  bool _isLoading = true;

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
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'john.doe@example.com',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
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
                  onTap: () {
                    _showCurrencyDialog();
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
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Delete all transactions and settings'),
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showClearDataDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('About'),
                  subtitle: const Text('App version and info'),
                  leading: const Icon(Icons.info),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showAboutDialog();
                  },
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

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all your transactions and settings. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear all data
                await _settingsService.clearAllSettings();
                // You would also clear transaction data here

                if (context.mounted) {
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Personal Finance Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet),
      children: [
        const Text('A simple app to track your personal finances.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter for educational purposes.'),
      ],
    );
  }
}
