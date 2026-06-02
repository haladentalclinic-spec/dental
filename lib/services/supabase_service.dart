import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  late final SupabaseClient _client;

  SupabaseClient get client => _client;

  /// Initialize Supabase client. Call once in main() before runApp().
  Future<void> init() async {
    _client = SupabaseClient(
      SupabaseConfig.url,
      SupabaseConfig.anonKey,
    );
  }

  /// Quick connection test — tries a simple select on `translations`.
  Future<bool> testConnection() async {
    try {
      final _ = await _client.from('translations').select('id').limit(1);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ────────────────────── READ HELPERS ──────────────────────

  /// Fetch the first active clinic.
  Future<Map<String, dynamic>?> fetchClinic() async {
    final data = await _client
        .from('clinics')
        .select('*')
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();
    return data;
  }

  /// Fetch settings for a given clinic.
  Future<Map<String, dynamic>?> fetchSettings(String clinicId) async {
    return await _client
        .from('settings')
        .select('*')
        .eq('clinic_id', clinicId)
        .maybeSingle();
  }

  /// Fetch active banners for a clinic.
  Future<List<Map<String, dynamic>>> fetchBanners(String clinicId) async {
    final now = DateTime.now().toIso8601String().substring(0, 10);
    final data = await _client
        .from('banners')
        .select('*')
        .eq('clinic_id', clinicId)
        .eq('is_active', true)
        .or('start_date.is.null,start_date.lte.$now')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch all active banners for a clinic (no date filter).
  Future<List<Map<String, dynamic>>> fetchAllBanners(String clinicId) async {
    final data = await _client
        .from('banners')
        .select('*')
        .eq('clinic_id', clinicId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch notifications for a clinic.
  Future<List<Map<String, dynamic>>> fetchNotifications(String clinicId) async {
    final data = await _client
        .from('notifications')
        .select('*')
        .eq('clinic_id', clinicId)
        .order('created_at', ascending: false)
        .limit(100);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch locations for a clinic.
  Future<List<Map<String, dynamic>>> fetchLocations(String clinicId) async {
    final data = await _client
        .from('locations')
        .select('*')
        .eq('clinic_id', clinicId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch works (dental treatments) for a clinic.
  Future<List<Map<String, dynamic>>> fetchWorks(String clinicId) async {
    final data = await _client
        .from('works')
        .select('*')
        .eq('clinic_id', clinicId)
        .order('created_at', ascending: false)
        .limit(100);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch translations for a given language code.
  Future<Map<String, String>> fetchTranslations(String lang) async {
    final data = await _client
        .from('translations')
        .select('t_key, value')
        .eq('lang', lang);
    final map = <String, String>{};
    for (final row in data) {
      map[row['t_key'] as String] = row['value'] as String;
    }
    return map;
  }
}