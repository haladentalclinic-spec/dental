import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/app_models.dart' as models;

/// Central data service scoped to the active clinic.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  late final SupabaseClient _client;

  /// Cached clinic ID (set after login)
  String? _currentClinicId;
  String get currentClinicId => _currentClinicId ?? '';

  SupabaseClient get client => _client;

  Future<void> init() async {
    _client = SupabaseClient(
      SupabaseConfig.url,
      SupabaseConfig.anonKey,
    );
  }

  // ────────────────────── AUTH ──────────────────────

  Future<models.User?> authenticate(String phone, String password) async {
    final data = await _client
        .from('users')
        .select('*')
        .eq('phone', phone)
        .eq('password_hash', password)
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    final user = models.User.fromMap(data);
    _currentClinicId = user.clinicId;
    return user;
  }

  void setClinicId(String id) => _currentClinicId = id;

  Future<models.User?> signUp(Map<String, dynamic> userData) async {
    if (_currentClinicId != null && userData['clinic_id'] == null) {
      userData['clinic_id'] = _currentClinicId;
    }
    final data = await _client
        .from('users')
        .insert(userData)
        .select()
        .maybeSingle();
    if (data == null) return null;
    return models.User.fromMap(data);
  }

  Future<models.User?> getUser(String userId) async {
    final data = await _client
        .from('users')
        .select('*')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    final user = models.User.fromMap(data);
    if (_currentClinicId == null && user.clinicId != null) {
      _currentClinicId = user.clinicId;
    }
    return user;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _client.from('users').update(updates).eq('id', userId);
  }

  // ────────────────────── CLINIC ──────────────────────

  Future<models.Clinic?> fetchClinic() async {
    final data = await _client
        .from('clinics')
        .select('*')
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    final clinic = models.Clinic.fromMap(data);
    _currentClinicId ??= clinic.id;
    return clinic;
  }

  // ────────────────────── SETTINGS ──────────────────────

  Future<models.ClinicSettings?> fetchSettings() async {
    if (_currentClinicId == null) return null;
    final data = await _client
        .from('settings')
        .select('*')
        .eq('clinic_id', _currentClinicId!)
        .maybeSingle();
    return data != null ? models.ClinicSettings.fromMap(data) : null;
  }

  // ────────────────────── USERS ──────────────────────

  Future<List<models.User>> fetchDoctors() async {
    if (_currentClinicId == null) return [];
    final data = await _client
        .from('users')
        .select('*')
        .eq('clinic_id', _currentClinicId!)
        .eq('role', 'doctor')
        .eq('is_active', true)
        .order('full_name');
    return (data as List).map((m) => models.User.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<List<models.User>> fetchPatients() async {
    if (_currentClinicId == null) return [];
    final data = await _client
        .from('users')
        .select('*')
        .eq('clinic_id', _currentClinicId!)
        .eq('role', 'patient')
        .eq('is_active', true)
        .order('full_name');
    return (data as List).map((m) => models.User.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<List<models.User>> fetchAllUsers() async {
    if (_currentClinicId == null) return [];
    final data = await _client
        .from('users')
        .select('*')
        .eq('clinic_id', _currentClinicId!)
        .eq('is_active', true)
        .order('full_name');
    return (data as List).map((m) => models.User.fromMap(m as Map<String, dynamic>)).toList();
  }

  // ────────────────────── WORKS ──────────────────────

  Future<List<models.Work>> fetchWorks({String? patientId}) async {
    if (_currentClinicId == null) return [];
    var q = _client.from('works').select('*').eq('clinic_id', _currentClinicId!);
    if (patientId != null) q = q.eq('patient_id', patientId);
    final data = await q.order('created_at', ascending: false).limit(100);
    return (data as List).map((m) => models.Work.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<List<models.Work>> fetchWorksWithDetails({String? patientId}) async {
    if (_currentClinicId == null) return [];
    var q = _client
        .from('works')
        .select('*, users!works_doctor_id_fkey(full_name, image), patients:users!works_patient_id_fkey(full_name, image)')
        .eq('clinic_id', _currentClinicId!);
    if (patientId != null) q = q.eq('patient_id', patientId);
    final data = await q.order('created_at', ascending: false).limit(100);
    return (data as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      if (map['users'] != null) {
        map['doctor_name'] = (map['users'] as Map)['full_name'];
        map['doctor_image'] = (map['users'] as Map)['image'];
      }
      if (map['patients'] != null) {
        map['patient_name'] = (map['patients'] as Map)['full_name'];
        map['patient_image'] = (map['patients'] as Map)['image'];
      }
      map.remove('users');
      map.remove('patients');
      return models.Work.fromMap(map);
    }).toList();
  }

  Future<models.Work?> createWork(Map<String, dynamic> data) async {
    data['clinic_id'] ??= _currentClinicId;
    final result = await _client.from('works').insert(data).select().maybeSingle();
    return result != null ? models.Work.fromMap(result) : null;
  }

  // ────────────────────── NOTIFICATIONS ──────────────────────

  Future<List<models.NotificationItem>> fetchNotifications({String? userId}) async {
    if (_currentClinicId == null) return [];
    var q = _client.from('notifications').select('*').eq('clinic_id', _currentClinicId!);
    if (userId != null) q = q.eq('user_id', userId);
    final data = await q.order('created_at', ascending: false).limit(100);
    return (data as List).map((m) => models.NotificationItem.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }

  // ────────────────────── MESSAGES ──────────────────────

  Future<List<models.Message>> fetchConversation(String userId1, String userId2) async {
    if (_currentClinicId == null) return [];
    final data = await _client
        .from('messages')
        .select('*, sender:users!messages_sender_id_fkey(full_name, image)')
        .eq('clinic_id', _currentClinicId!)
        .or('sender_id.eq.$userId1,receiver_id.eq.$userId1')
        .or('sender_id.eq.$userId2,receiver_id.eq.$userId2')
        .order('created_at', ascending: true);
    return (data as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      if (map['sender'] != null) {
        map['sender_name'] = (map['sender'] as Map)['full_name'];
        map['sender_image'] = (map['sender'] as Map)['image'];
      }
      map.remove('sender');
      return models.Message.fromMap(map);
    }).toList();
  }

  Future<List<models.Message>> fetchConversationList(String currentUserId) async {
    if (_currentClinicId == null) return [];
    final data = await _client
        .from('messages')
        .select('*, sender:users!messages_sender_id_fkey(full_name, image)')
        .eq('clinic_id', _currentClinicId!)
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .order('created_at', ascending: false);
    final msgs = (data as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      if (map['sender'] != null) {
        map['sender_name'] = (map['sender'] as Map)['full_name'];
        map['sender_image'] = (map['sender'] as Map)['image'];
      }
      map.remove('sender');
      return models.Message.fromMap(map);
    }).toList();
    final seen = <String>{};
    final result = <models.Message>[];
    for (final msg in msgs) {
      final partnerId = msg.senderId == currentUserId ? msg.receiverId : msg.senderId;
      if (partnerId != null && seen.add(partnerId)) result.add(msg);
    }
    return result;
  }

  Future<models.Message?> sendMessage(Map<String, dynamic> data) async {
    data['clinic_id'] ??= _currentClinicId;
    final result = await _client.from('messages').insert(data).select().maybeSingle();
    return result != null ? models.Message.fromMap(result) : null;
  }

  Future<void> markMessagesSeen(String senderId, String receiverId) async {
    await _client
        .from('messages')
        .update({'is_seen': true})
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .eq('is_seen', false);
  }

  // ────────────────────── REMINDERS ──────────────────────

  Future<List<models.Reminder>> fetchReminders({String? patientId}) async {
    if (_currentClinicId == null) return [];
    var q = _client.from('reminders').select('*').eq('clinic_id', _currentClinicId!);
    if (patientId != null) q = q.eq('patient_id', patientId);
    final data = await q.order('reminder_date', ascending: false).limit(50);
    return (data as List).map((m) => models.Reminder.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<models.Reminder?> createReminder(Map<String, dynamic> data) async {
    data['clinic_id'] ??= _currentClinicId;
    final result = await _client.from('reminders').insert(data).select().maybeSingle();
    return result != null ? models.Reminder.fromMap(result) : null;
  }

  Future<void> updateReminderStatus(String id, String status) async {
    await _client.from('reminders').update({'status': status}).eq('id', id);
  }

  // ────────────────────── MEDIA ──────────────────────

  Future<List<models.MediaItem>> fetchMedia({String? relatedTable, String? relatedId}) async {
    if (_currentClinicId == null) return [];
    var q = _client.from('media').select('*').eq('clinic_id', _currentClinicId!);
    if (relatedTable != null) q = q.eq('related_table', relatedTable);
    if (relatedId != null) q = q.eq('related_id', relatedId);
    final data = await q.order('created_at', ascending: false);
    return (data as List).map((m) => models.MediaItem.fromMap(m as Map<String, dynamic>)).toList();
  }

  // ────────────────────── BANNERS ──────────────────────

  Future<List<models.BannerItem>> fetchBanners() async {
    if (_currentClinicId == null) return [];
    final now = DateTime.now().toIso8601String().substring(0, 10);
    final data = await _client
        .from('banners')
        .select('*')
        .eq('clinic_id', _currentClinicId!)
        .eq('is_active', true)
        .or('start_date.is.null,start_date.lte.$now')
        .order('created_at', ascending: false);
    return (data as List).map((m) => models.BannerItem.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<List<models.BannerItem>> fetchAllBanners() async {
    if (_currentClinicId == null) return [];
    final data = await _client
        .from('banners')
        .select('*')
        .eq('clinic_id', _currentClinicId!)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (data as List).map((m) => models.BannerItem.fromMap(m as Map<String, dynamic>)).toList();
  }

  // ────────────────────── LOCATIONS ──────────────────────

  Future<List<models.LocationItem>> fetchLocations() async {
    if (_currentClinicId == null) return [];
    final data = await _client
        .from('locations')
        .select('*')
        .eq('clinic_id', _currentClinicId!)
        .order('created_at', ascending: false);
    return (data as List).map((m) => models.LocationItem.fromMap(m as Map<String, dynamic>)).toList();
  }

  // ────────────────────── TRANSLATIONS ──────────────────────

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

  // ────────────────────── ACTIVITY LOG ──────────────────────

  Future<void> logActivity(String action, {String? tableName, String? recordId, String? userId}) async {
    if (_currentClinicId == null) return;
    await _client.from('activity_logs').insert({
      'clinic_id': _currentClinicId,
      'user_id': userId,
      'action': action,
      'table_name': tableName,
      'record_id': recordId,
    });
  }
}
