// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
            subtitle: const Text('USD'), // Placeholder
            onTap: () {
              // TODO: Implement currency selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Currency selection coming soon!')),
              );
            },
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
}