import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../models/app_models.dart';
import '../widgets/app_header.dart';
import '../widgets/loading_view.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = SupabaseService.instance;
  bool _loading = true;
  String? _error;
  List<NotificationItem> _items = [];

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
      if (AuthService.instance.currentUserId == null) {
        setState(() {
          _error = 'Please sign in to view notifications';
          _loading = false;
        });
        return;
      }
      final clinicMap = await _service.fetchClinic();
      if (clinicMap != null) {
        final maps = await _service.fetchNotifications(userId: AuthService.instance.currentUserId);
        _items = maps.map((m) => NotificationItem.fromMap(m as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Notifications'),
      body: _loading
          ? const LoadingView(message: 'Loading notifications...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? const EmptyView(message: 'No notifications yet', icon: Icons.notifications_off_rounded)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isHigh = item.priority == 'high';
                          final date = item.createdAt != null
                              ? DateFormat('MMM dd, yyyy \u2022 hh:mm a').format(item.createdAt!)
                              : '';
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isHigh
                                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  isHigh ? Icons.priority_high_rounded : Icons.notifications_rounded,
                                  color: isHigh ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.body != null && item.body!.isNotEmpty)
                                    Text(
                                      item.body!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
