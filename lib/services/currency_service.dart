import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.dev/v1';
  static const Duration _timeout = Duration(seconds: 10);

  // Get supported currencies
  Future<List<String>> getSupportedCurrencies() async {
    try {
      final url = Uri.parse('$_baseUrl/currencies');
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.keys.toList()..sort();
      } else {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching currencies: $e');
      // Return default currencies if API fails
      return ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
    }
  }

  // Convert currency
  Future<CurrencyRate> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // Return same currency if from and to are the same
    if (fromCurrency == toCurrency) {
      return CurrencyRate(
        amount: amount,
        baseCurrency: fromCurrency,
        targetCurrency: toCurrency,
        rate: 1.0,
        date: DateTime.now(),
      );
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/latest?amount=$amount&from=$fromCurrency&to=$toCurrency',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CurrencyRate.fromJson(data, toCurrency);
      } else {
        throw Exception('Failed to convert currency: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error converting currency: $e');
      rethrow; // Re-throw the error so the UI can handle it
    }
  }
}
