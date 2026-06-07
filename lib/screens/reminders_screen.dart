import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_header.dart';
import '../models/app_models.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (AuthService.instance.currentUserId == null) {
        setState(() {
          _error = 'Please sign in to view reminders';
          _loading = false;
        });
        return;
      }
      _items = await SupabaseService.instance.fetchReminders(patientId: AuthService.instance.currentUserId);
    } catch (e) {
      _error = 'Failed to load reminders: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markDone(Reminder r) async {
    await SupabaseService.instance.updateReminderStatus(r.id, 'done');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Reminders'),
      body: _loading
          ? const LoadingView(message: 'Loading reminders...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? const EmptyView(message: 'No reminders', icon: Icons.alarm_off_rounded)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final r = _items[index];
                          Color statusColor;
                          switch (r.status) {
                            case 'done': statusColor = Colors.green; break;
                            case 'cancelled': statusColor = Colors.red; break;
                            default: statusColor = Colors.orange;
                          }
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                child: Icon(
                                  r.isDone ? Icons.check_circle_rounded : Icons.alarm_rounded,
                                  color: statusColor,
                                ),
                              ),
                              title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(r.formattedDate),
                              trailing: r.isPending
                                  ? IconButton(
                                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                                      onPressed: () => _markDone(r),
                                    )
                                  : Chip(
                                      label: Text(r.status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                                      backgroundColor: statusColor,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
