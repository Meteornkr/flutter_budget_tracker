// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/currency_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          ListTile(
            title: const Text('Currency'),
            subtitle: Text(currencyProvider.selectedCurrency), // Show current currency
            onTap: () => _showCurrencySelectionDialog(context, currencyProvider),
          ),
          ListTile(
            title: const Text('Export Data'),
            onTap: () {
              // TODO: Implement data export (e.g., to CSV)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export coming soon!')),
              );
            },
          ),
           ListTile(
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Implement notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showCurrencySelectionDialog(BuildContext context, CurrencyProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provider.availableCurrencies.length,
              itemBuilder: (BuildContext context, int index) {
                final currencyCode = provider.availableCurrencies[index];
                return ListTile(
                  title: Text(currencyCode),
                  onTap: () {
                    provider.setSelectedCurrency(currencyCode);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}