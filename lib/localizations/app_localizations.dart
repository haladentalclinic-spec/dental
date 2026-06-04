import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

/// Loads UI translations from the `public.translations` table.
class AppLocalizations {
  final String lang;
  Map<String, String> _strings = {};

  AppLocalizations(this.lang);

  static Future<AppLocalizations> load(String lang) async {
    final instance = AppLocalizations(lang);
    instance._strings = await SupabaseService.instance.fetchTranslations(lang);
    return instance;
  }

  String t(String key, {String? fallback}) {
    return _strings[key] ?? fallback ?? key;
  }

  bool get isRtl => lang == 'ar' || lang == 'ckb';

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'ckb'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
