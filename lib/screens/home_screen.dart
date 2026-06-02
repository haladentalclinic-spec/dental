import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/loading_view.dart';
import 'clinic_info_screen.dart';
import 'notifications_screen.dart';
import 'banners_screen.dart';
import 'locations_screen.dart';
import 'settings_screen.dart';

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
  List<BannerItem> _banners = [];

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
      final clinicMap = await _service.fetchClinic();
      if (clinicMap != null) {
        _clinic = Clinic.fromMap(clinicMap);
        final bannerMaps = await _service.fetchBanners(_clinic!.id);
        _banners = bannerMaps.map(BannerItem.fromMap).toList();
      }
    } catch (e) {
      _error = 'Failed to load data: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_clinic?.name ?? 'Hala Dental'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const LoadingView(message: 'Loading clinic data...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Banners ──
                      if (_banners.isNotEmpty) ...[
                        BannerCarousel(banners: _banners),
                        const SizedBox(height: 20),
                      ],

                      // ── Quick Actions Grid ──
                      Text(
                        'Quick Access',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _QuickActionsGrid(clinicId: _clinic?.id),
                    ],
                  ),
                ),
    );
  }
}

/// Grid of quick action cards for navigation.
class _QuickActionsGrid extends StatelessWidget {
  final String? clinicId;

  const _QuickActionsGrid({this.clinicId});

  @override
  Widget build(BuildContext context) {
    final items = <_QuickAction>[
      _QuickAction(
        icon: Icons.local_hospital_rounded,
        label: 'Clinic Info',
        color: const Color(0xFF1E88E5),
        screenBuilder: () => const ClinicInfoScreen(),
      ),
      _QuickAction(
        icon: Icons.notifications_rounded,
        label: 'Notifications',
        color: const Color(0xFFFFA726),
        screenBuilder: () => const NotificationsScreen(),
      ),
      _QuickAction(
        icon: Icons.campaign_rounded,
        label: 'Banners',
        color: const Color(0xFF66BB6A),
        screenBuilder: () => const BannersScreen(),
      ),
      _QuickAction(
        icon: Icons.location_on_rounded,
        label: 'Locations',
        color: const Color(0xFFEF5350),
        screenBuilder: () => const LocationsScreen(),
      ),
      _QuickAction(
        icon: Icons.settings_rounded,
        label: 'Settings',
        color: const Color(0xFFAB47BC),
        screenBuilder: () => const SettingsScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => item.screenBuilder()),
            );
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: item.color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Widget Function() screenBuilder;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.screenBuilder,
  });
}