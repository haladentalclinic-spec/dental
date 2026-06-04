import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_header.dart';
import '../widgets/loading_view.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'en';
  bool _loading = true;

  static const _keyTheme = 'theme_mode';
  static const _keyLanguage = 'language';

  static const _themeLabels = <ThemeMode, String>{
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
    ThemeMode.system: 'System',
  };

  static const _languageLabels = <String, String>{
    'en': 'English',
    'ar': 'العربية',
    'ckb': 'کوردی',
  };

  static const _languageCodes = ['en', 'ar', 'ckb'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_keyTheme) ?? 'system';
    final lang = prefs.getString(_keyLanguage) ?? 'en';
    setState(() {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeStr,
        orElse: () => ThemeMode.system,
      );
      _language = lang;
      _loading = false;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode.name);
  }

  Future<void> _setLanguage(String lang) async {
    setState(() => _language = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language set to ${_languageLabels[lang] ?? lang}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Settings'),
      body: _loading
          ? const LoadingView(message: 'Loading settings...')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildThemeSection(),
                const SizedBox(height: 16),
                _buildLanguageSection(),
                const SizedBox(height: 16),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.brightness_6_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text('Theme', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...ThemeMode.values.map((mode) {
              return RadioListTile<ThemeMode>(
                title: Text(_themeLabels[mode] ?? mode.name),
                value: mode,
                groupValue: _themeMode,
                onChanged: (v) {
                  if (v != null) _setThemeMode(v);
                },
                activeColor: Theme.of(context).colorScheme.primary,
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
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
            ..._languageCodes.map((code) {
              return RadioListTile<String>(
                title: Text(_languageLabels[code] ?? code),
                value: code,
                groupValue: _language,
                onChanged: (v) {
                  if (v != null) _setLanguage(v);
                },
                activeColor: Theme.of(context).colorScheme.primary,
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
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
            const ListTile(title: Text('App Name'), subtitle: Text('Hala Dental Clinic'), dense: true, contentPadding: EdgeInsets.zero),
            const ListTile(title: Text('Version'), subtitle: Text('1.0.0'), dense: true, contentPadding: EdgeInsets.zero),
            const ListTile(title: Text('Developer'), subtitle: Text('Hala Dental Team'), dense: true, contentPadding: EdgeInsets.zero),
          ],
        ),
      ),
    );
  }
}
