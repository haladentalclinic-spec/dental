import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';
import '../widgets/app_header.dart';
import '../widgets/loading_view.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});
  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _service = SupabaseService.instance;
  bool _loading = true;
  String? _error;
  List<LocationItem> _items = [];

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
        final maps = await _service.fetchLocations();
        _items = maps.map((m) => LocationItem.fromMap(m as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _error = 'Failed to load locations: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Locations'),
      body: _loading
          ? const LoadingView(message: 'Loading locations...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? const EmptyView(message: 'No locations available', icon: Icons.location_off_rounded)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final loc = _items[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                                      child: Icon(Icons.location_on_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(loc.city ?? loc.country ?? 'Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                          if (loc.displayAddress.isNotEmpty)
                                            Text(loc.displayAddress, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                  ]),
                                  if (loc.latitude != null && loc.longitude != null) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openMap(loc.latitude!, loc.longitude!),
                                        icon: const Icon(Icons.map_rounded, size: 18),
                                        label: const Text('Open in Maps'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
