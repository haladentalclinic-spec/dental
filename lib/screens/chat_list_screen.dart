import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_header.dart';
import '../models/app_models.dart';
import 'conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabase = SupabaseService.instance;
  final _auth = AuthService.instance;
  List<Message> _conversations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() { _loading = true; _error = null; });
    try {
      final userId = _auth.currentUserId;
      if (userId == null) { 
        setState(() { 
          _error = 'Please sign in to view messages'; 
          _loading = false; 
        }); 
        return; 
      }
      final list = await _supabase.fetchConversationList(userId);
      setState(() { _conversations = list; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _partnerId(Message msg) {
    final uid = _auth.currentUserId!;
    return msg.senderId == uid ? (msg.receiverId ?? '') : (msg.senderId ?? '');
  }

  String _partnerName(Message msg) {
    final uid = _auth.currentUserId!;
    if (msg.senderId == uid) return 'User';
    return msg.senderName ?? 'User';
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Messages', showBackButton: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading conversations...');
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadConversations);
    if (_conversations.isEmpty) return const EmptyView(message: 'No conversations yet', icon: Icons.chat_bubble_outline_rounded);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final msg = _conversations[index];
        final partnerId = _partnerId(msg);
        final name = _partnerName(msg);
        final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ConversationScreen(partnerId: partnerId, partnerName: name),
            )),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(initials, style: TextStyle(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(msg.message, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_timeAgo(msg.createdAt),
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
