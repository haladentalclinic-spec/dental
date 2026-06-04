import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'services_screen.dart';
import 'doctors_screen.dart';
import 'clinics_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'reminders_screen.dart';
import 'chat_list_screen.dart';
import 'media_screen.dart';
import 'locations_screen.dart';
import 'clinic_info_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ServicesScreen(),
    DoctorsScreen(),
    ClinicsScreen(),
    _MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    AuthService.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuTile(
            icon: Icons.person_rounded,
            color: AppColors.primary,
            title: 'Profile',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          _MenuTile(
            icon: Icons.notifications_rounded,
            color: Colors.orange,
            title: 'Notifications',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          _MenuTile(
            icon: Icons.alarm_rounded,
            color: Colors.teal,
            title: 'Reminders',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
          ),
          _MenuTile(
            icon: Icons.chat_rounded,
            color: AppColors.secondary,
            title: 'Chat',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen())),
          ),
          _MenuTile(
            icon: Icons.photo_library_rounded,
            color: Colors.purple,
            title: 'Media Gallery',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaScreen())),
          ),
          _MenuTile(
            icon: Icons.location_on_rounded,
            color: Colors.red,
            title: 'Locations',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen())),
          ),
          _MenuTile(
            icon: Icons.local_hospital_rounded,
            color: AppColors.primary,
            title: 'Clinic Info',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicInfoScreen())),
          ),
          _MenuTile(
            icon: Icons.settings_rounded,
            color: Colors.grey,
            title: 'Settings',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }
}
