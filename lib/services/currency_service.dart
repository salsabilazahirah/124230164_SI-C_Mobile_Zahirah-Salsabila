import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Static exchange rates (fallback if API fails)
  static const Map<String, double> staticRates = {
    'USD': 1.0,
    'IDR': 15750.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 149.50,
    'SGD': 1.35,
    'MYR': 4.72,
  };

  // Try to fetch live rates, fallback to static if fails
  Future<Map<String, double>> getExchangeRates() async {
    try {
      // Using exchangerate-api.com free tier (no API key needed for basic usage)
      final response = await http
          .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(data['rates']);
        return rates;
      }
    } catch (e) {
      // If API fails, return static rates
    }
    return staticRates;
  }

  double convert(
    double amount,
    String from,
    String to,
    Map<String, double> rates,
  ) {
    if (from == to) return amount;

    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;

    // Convert to USD first, then to target currency
    final amountInUSD = amount / fromRate;
    return amountInUSD * toRate;
  }

  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'IDR':
        return 'Rp';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SGD':
        return 'S\$';
      case 'MYR':
        return 'RM';
      default:
        return currency;
    }
  }

  String formatCurrency(double amount, String currency) {
    final symbol = getCurrencySymbol(currency);
    if (currency == 'IDR') {
      // Format IDR with thousand separator
      final formatted = amount.toStringAsFixed(0);
      final parts = <String>[];
      var remaining = formatted;
      while (remaining.length > 3) {
        parts.insert(0, remaining.substring(remaining.length - 3));
        remaining = remaining.substring(0, remaining.length - 3);
      }
      if (remaining.isNotEmpty) {
        parts.insert(0, remaining);
      }
      return '$symbol ${parts.join('.')}';
    }
    if (currency == 'JPY') {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}
