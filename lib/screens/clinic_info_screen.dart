import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';
import '../widgets/app_header.dart';
import '../widgets/loading_view.dart';

class ClinicInfoScreen extends StatefulWidget {
  const ClinicInfoScreen({super.key});
  @override
  State<ClinicInfoScreen> createState() => _ClinicInfoScreenState();
}

class _ClinicInfoScreenState extends State<ClinicInfoScreen> {
  final _service = SupabaseService.instance;
  bool _loading = true;
  String? _error;
  Clinic? _clinic;

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
      await _service.fetchSettings(_clinic!.id);
      }
    } catch (e) {
      _error = 'Failed to load clinic info: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Clinic Info'),
      body: _loading
          ? const LoadingView(message: 'Loading clinic info...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _clinic == null
                  ? const EmptyView(message: 'No clinic data found', icon: Icons.local_hospital_rounded)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(padding: const EdgeInsets.all(16), children: [
                        _InfoCard(icon: Icons.local_hospital_rounded, title: _clinic!.name, subtitle: 'Clinic'),
                        if (_clinic!.phone != null && _clinic!.phone!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _ActionCard(icon: Icons.phone_rounded, title: 'Phone', subtitle: _clinic!.phone!, onTap: () => _openPhone(_clinic!.phone!), trailing: const Icon(Icons.call_rounded, color: Colors.green)),
                          const SizedBox(height: 12),
                          _ActionCard(icon: Icons.chat_rounded, title: 'WhatsApp', subtitle: _clinic!.phone!, onTap: () => _openWhatsApp(_clinic!.phone!), trailing: const Icon(Icons.open_in_new_rounded, size: 18)),
                        ],
                        if (_clinic!.address != null && _clinic!.address!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _InfoCard(icon: Icons.location_on_rounded, title: 'Address', subtitle: _clinic!.address!),
                        ],
                        if (_clinic!.url != null && _clinic!.url!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _ActionCard(icon: Icons.language_rounded, title: 'Website', subtitle: _clinic!.url!, onTap: () => _openWebsite(_clinic!.url!), trailing: const Icon(Icons.open_in_new_rounded, size: 18)),
                        ],
                        if (_clinic!.map != null) ...[
                          const SizedBox(height: 12),
                          _ActionCard(
                            icon: Icons.map_rounded,
                            title: 'View on Map',
                            subtitle: '${_clinic!.map!['lat'] ?? ''}, ${_clinic!.map!['lng'] ?? ''}',
                            onTap: () {
                              final lat = (_clinic!.map!['lat'] as num?)?.toDouble();
                              final lng = (_clinic!.map!['lng'] as num?)?.toDouble();
                              if (lat != null && lng != null) _openMap(lat, lng);
                            },
                            trailing: const Icon(Icons.launch_rounded, size: 18),
                          ),
                        ],
                      ]),
                    ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ])),
        ]),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(radius: 24, backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            if (trailing != null) trailing!,
          ]),
        ),
      ),
    );
  }
}