import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/app_header.dart';
import '../models/app_models.dart' as models;
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Profile'),
        body: const Center(child: Text('Not logged in')),
      );
    }
    return Scaffold(
      appBar: const AppHeader(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(user.initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(user.role.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    backgroundColor: user.isAdmin ? Colors.red : user.isDoctor ? AppColors.primary : AppColors.secondary,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (user.patientCode != null) ...[
                    const SizedBox(height: 8),
                    Text('Code: ${user.patientCode}', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (user.phone != null) _actionCard(Icons.phone_rounded, 'Phone', user.phone!, () => _launch('tel:${user.phone}')),
          if (user.whatsapp != null) _actionCard(Icons.chat_rounded, 'WhatsApp', user.whatsapp!, () => _launch('https://wa.me/${user.whatsapp!.replaceAll(RegExp(r'[^0-9+]'), '')}')),
          if (user.gender != null) _infoCard(Icons.wc_rounded, 'Gender', user.gender!),
          if (user.age != null) _infoCard(Icons.numbers_rounded, 'Age', '${user.age}'),
          if (user.bloodType != null) _infoCard(Icons.water_drop_rounded, 'Blood Type', user.bloodType!),
          if (user.address != null) _infoCard(Icons.location_on_rounded, 'Address', user.address!),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showEditDialog(user),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceContainerHigh, foregroundColor: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
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

  Widget _infoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _actionCard(IconData icon, String label, String value, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showEditDialog(models.User user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final addressCtrl = TextEditingController(text: user.address ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await SupabaseService.instance.updateUser(user.id, {
                'full_name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'address': addressCtrl.text.trim(),
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              // Refresh by reloading session
              await AuthService.instance.loadSession();
              setState(() {});
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Profile updated')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
