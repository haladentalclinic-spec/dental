import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';
import '../widgets/app_header.dart';
import '../widgets/loading_view.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});
  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final _service = SupabaseService.instance;
  bool _loading = true;
  String? _error;
  List<BannerItem> _items = [];

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
        final maps = await _service.fetchAllBanners(clinicMap['id'] as String);
        _items = maps.map(BannerItem.fromMap).toList();
      }
    } catch (e) {
      _error = 'Failed to load banners: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Banners'),
      body: _loading
          ? const LoadingView(message: 'Loading banners...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? const EmptyView(message: 'No banners available', icon: Icons.campaign_rounded)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 180,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 180,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.broken_image_rounded, size: 40),
                                  ),
                                ),
                                if (item.title != null && item.title!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      item.title!,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}