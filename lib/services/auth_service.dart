import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';

/// Singleton auth service using phone+password against public.users.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  User? _currentUser;
  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  String? get currentUserRole => _currentUser?.role;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isDoctor => _currentUser?.role == 'doctor';
  bool get isPatient => _currentUser?.role == 'patient';
  bool get isStaff => _currentUser?.role == 'staff';

  /// Load user session from saved user id.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      final user = await SupabaseService.instance.getUser(userId);
      if (user != null && user.isActive) {
        _currentUser = user;
      } else {
        await prefs.remove('user_id');
      }
    }
  }

  /// Sign in with phone + password (plain text matching).
  Future<bool> signIn(String phone, String password) async {
    final user = await SupabaseService.instance.authenticate(phone, password);
    if (user != null) {
      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      return true;
    }
    return false;
  }

  /// Sign out: clear user and stored id.
  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  /// Register new user (patient sign-up).
  Future<User?> signUp(Map<String, dynamic> data) async {
    return await SupabaseService.instance.signUp(data);
  }
}
