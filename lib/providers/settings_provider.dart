import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/currency_service.dart';

class SettingsProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final CurrencyService _currencyService = CurrencyService();

  String _selectedCurrency = 'IDR';
  Map<String, double> _exchangeRates = {};
  Position? _currentPosition;
  String _locationName = 'Unknown';
  String _timezone = 'WIB';
  int _timezoneOffset = 7; // UTC+7 default
  String _selectedTimezone = 'WIB'; // User selected timezone

  String get selectedCurrency => _selectedCurrency;
  Map<String, double> get exchangeRates => _exchangeRates;
  String get locationName => _locationName;
  String get timezone => _timezone;
  String get selectedTimezone => _selectedTimezone;
  int get timezoneOffset => _timezoneOffset;
  Position? get currentPosition => _currentPosition;

  List<String> get availableCurrencies => ['IDR', 'USD', 'EUR', 'MYR', 'JPY'];

  Map<String, int> get availableTimezones => {
    'WIT': 9, // Waktu Indonesia Timur (UTC+9)
    'WITA': 8, // Waktu Indonesia Tengah (UTC+8)
    'WIB': 7, // Waktu Indonesia Barat (UTC+7)
    'JST': 9, // Japan Standard Time (UTC+9)
    'KST': 9, // Korea Standard Time (UTC+9)
    'SGT': 8, // Singapore Time (UTC+8)
    'ICT': 7, // Indochina Time (UTC+7)
    'GMT': 0, // Greenwich Mean Time (UTC+0)
    'EST': -5, // Eastern Standard Time (UTC-5)
    'PST': -8, // Pacific Standard Time (UTC-8)
    'CST': -6, // Central Standard Time (UTC-6)
    'MST': -7, // Mountain Standard Time (UTC-7)
  };

  Future<void> init() async {
    await loadExchangeRates();
    await updateLocation();
  }

  Future<void> loadExchangeRates() async {
    _exchangeRates = await _currencyService.getExchangeRates();
    notifyListeners();
  }

  void changeCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void changeTimezone(String timezone) {
    _selectedTimezone = timezone;
    _timezoneOffset = availableTimezones[timezone] ?? 7;
    notifyListeners();
  }

  double convertPrice(double priceInUSD) {
    return _currencyService.convert(
      priceInUSD,
      'USD',
      _selectedCurrency,
      _exchangeRates,
    );
  }

  String formatPrice(double priceInUSD) {
    final converted = convertPrice(priceInUSD);
    return _currencyService.formatCurrency(converted, _selectedCurrency);
  }

  Future<void> updateLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _currentPosition = position;
      _locationName = await _locationService.getLocationName(position);
      _timezone = _locationService.getTimezoneFromLocation(
        position.latitude,
        position.longitude,
      );
      _timezoneOffset = _locationService.getTimezoneOffset(_timezone);
      notifyListeners();
    }
  }

  DateTime getLocalTime() {
    return DateTime.now().toUtc().add(Duration(hours: _timezoneOffset));
  }

  String getFormattedTime() {
    final time = getLocalTime();
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $_selectedTimezone';
  }

  DateTime getSelectedTimezoneTime() {
    return DateTime.now().toUtc().add(Duration(hours: _timezoneOffset));
  }
}
