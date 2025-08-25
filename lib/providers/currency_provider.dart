import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedCurrency = 'USD';

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'PHP': '₱',
  };

  CurrencyProvider() {
    _loadCurrency();
  }

  String get selectedCurrency => _selectedCurrency;
  String get selectedCurrencySymbol => _currencySymbols[_selectedCurrency] ?? '\$';
  List<String> get availableCurrencies => _currencySymbols.keys.toList();

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('currency') ?? 'USD';
    notifyListeners();
  }

  Future<void> setSelectedCurrency(String currencyCode) async {
    if (_currencySymbols.containsKey(currencyCode)) {
      _selectedCurrency = currencyCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currencyCode);
      notifyListeners();
    }
  }
}