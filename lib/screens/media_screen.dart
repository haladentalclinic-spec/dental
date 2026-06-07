import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/supabase_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_header.dart';
import '../models/app_models.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final _supabase = SupabaseService.instance;
  List<MediaItem> _mediaList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (AuthService.instance.currentUserId == null) {
        setState(() {
          _error = 'Please sign in to view media';
          _loading = false;
        });
        return;
      }
      final list = await _supabase.fetchMedia();
      // Filter only image-type items
      final images = list.where((m) => m.isImage).toList();
      setState(() { _mediaList = images; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Media'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading media...');
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadMedia);
    if (_mediaList.isEmpty) {
      return const EmptyView(message: 'No media available', icon: Icons.photo_library_rounded);
    }

    return RefreshIndicator(
      onRefresh: _loadMedia,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _mediaList.length,
        itemBuilder: (context, index) {
          final item = _mediaList[index];
          return GestureDetector(
            onTap: () => _openMediaPreview(item),
            child: CachedNetworkImage(
              imageUrl: item.fileUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(Icons.broken_image_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openMediaPreview(MediaItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _MediaPreviewScreen(item: item),
    ));
  }
}

class _MediaPreviewScreen extends StatelessWidget {
  final MediaItem item;

  const _MediaPreviewScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(item.fileName ?? 'Media', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: item.fileUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
          ),
        ),
      ),
    );
  }
}
