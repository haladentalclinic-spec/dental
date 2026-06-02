import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLang = AppConstants.defaultLanguage;

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage;
    });
  }

  Future<void> _setLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, lang);
    setState(() => _currentLang = lang);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language set to ${AppConstants.languageNames[lang] ?? lang}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('Language', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...AppConstants.supportedLanguages.map((lang) {
                    return RadioListTile<String>(
                      title: Text(AppConstants.languageNames[lang] ?? lang),
                      value: lang,
                      groupValue: _currentLang,
                      onChanged: (v) { if (v != null) _setLang(v); },
                      activeColor: Theme.of(context).colorScheme.primary,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ListTile(title: Text('App Name'), subtitle: Text('Hala Dental'), dense: true, contentPadding: EdgeInsets.zero),
                  const ListTile(title: Text('Version'), subtitle: Text('1.0.0'), dense: true, contentPadding: EdgeInsets.zero),
                  const ListTile(title: Text('Developer'), subtitle: Text('Hala Dental Clinic'), dense: true, contentPadding: EdgeInsets.zero),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
