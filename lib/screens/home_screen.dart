import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../models/app_models.dart';
import '../utils/theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/banner_carousel.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'services_screen.dart';
import 'doctors_screen.dart';
import 'clinics_screen.dart';
import 'reminders_screen.dart';
import 'locations_screen.dart';
import 'clinic_info_screen.dart';
import 'chat_list_screen.dart';
import 'media_screen.dart';
import 'work_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = SupabaseService.instance;
  bool _loading = true;
  String? _error;
  Clinic? _clinic;
  ClinicSettings? _settings;
  List<BannerItem> _banners = [];
  List<Work> _recentWorks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _clinic = await _service.fetchClinic();
      if (_clinic != null) {
        _banners = await _service.fetchBanners();
        _settings = await _service.fetchSettings();
        _recentWorks = await _service.fetchWorksWithDetails();
        if (_recentWorks.length > 3) {
          _recentWorks = _recentWorks.sublist(0, 3);
        }
      }
    } catch (e) {
      _error = 'Failed to load data: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final title = _settings?.clinicName ?? _clinic?.name ?? 'Hala Dental';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    user.initials,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const LoadingView(message: 'Loading...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_banners.isNotEmpty) ...[
                        BannerCarousel(banners: _banners),
                        const SizedBox(height: 20),
                      ],
                      Text('Quick Access', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildQuickGrid(context),
                      const SizedBox(height: 24),
                      _buildWhatsAppCard(context),
                      if (_recentWorks.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Recent Works', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ..._recentWorks.map((w) => _WorkCard(work: w)),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuickGrid(BuildContext context) {
    final items = [
      _QItem(Icons.medical_services_rounded, 'Services', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen()))),
      _QItem(Icons.person_rounded, 'Doctors', AppColors.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorsScreen()))),
      _QItem(Icons.calendar_month_rounded, 'Appointments', Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicsScreen()))),
      _QItem(Icons.notifications_rounded, 'Notifications', Colors.amber, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
      _QItem(Icons.alarm_rounded, 'Reminders', Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
      _QItem(Icons.location_on_rounded, 'Locations', Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen()))),
      _QItem(Icons.local_hospital_rounded, 'Clinic Info', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicInfoScreen()))),
      _QItem(Icons.chat_rounded, 'Chat', AppColors.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()))),
      _QItem(Icons.photo_library_rounded, 'Media', Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaScreen()))),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: item.onTap,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(item.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWhatsAppCard(BuildContext context) {
    final whatsapp = _settings?.phone1 ?? _clinic?.phone ?? '+9647701234567';
    return Card(
      color: const Color(0xFF25D366),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openWhatsApp(whatsapp),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connect on WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(whatsapp, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _QItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QItem(this.icon, this.label, this.color, this.onTap);
}

class _WorkCard extends StatelessWidget {
  final Work work;
  const _WorkCard({required this.work});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 20),
        ),
        title: Text(work.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${work.doctorName ?? ''} • ${work.formattedStartDate}'),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkDetailScreen(work: work))),
      ),
    );
  }
}
