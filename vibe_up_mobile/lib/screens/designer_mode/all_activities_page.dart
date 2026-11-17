import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/services/notification_service.dart';
import 'manage_requests_page.dart';
import 'designer_chat_list_screen.dart';
import 'my_project.dart';
import 'feedback_page.dart';

class AllActivitiesPage extends StatefulWidget {
  final String designerId;
  const AllActivitiesPage({super.key, required this.designerId});

  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;
  final Color primary = AppTheme.primaryAccent;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    final notifs = await NotificationService.getNotifications(widget.designerId);
    if (mounted) {
      setState(() {
        _activities = notifs;
        _isLoading = false;
      });
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'request_new':
        return Icons.inbox;
      case 'request_accepted':
        return Icons.check_circle;
      case 'request_declined':
        return Icons.cancel;
      case 'message_new':
        return Icons.chat_bubble;
      case 'design_uploaded':
        return Icons.upload_file;
      case 'admin_update':
        return Icons.admin_panel_settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'request_new':
        return Colors.blue;
      case 'request_accepted':
        return Colors.green;
      case 'request_declined':
        return Colors.red;
      case 'message_new':
        return Colors.teal;
      case 'design_uploaded':
        return Colors.purple;
      default:
        return primary;
    }
  }

  void _onActivityTap(Map<String, dynamic> activity) {
    final type = activity['type'] ?? '';
    
    if (type == 'request_new' || type == 'request_accepted' || type == 'request_declined') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRequestsPage()));
    } else if (type == 'message_new') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignerChatListScreen()));
    } else if (type == 'design_uploaded') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProject()));
    } else {
      // Default: go to manage requests
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRequestsPage()));
    }
    
    // Mark as read
    if (activity['id'] != null) {
      NotificationService.markAsRead(activity['id']);
    }
  }

  String _timeAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return timestamp;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("All Activities", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 24)),
        centerTitle: true,
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificationService.markAllAsRead(widget.designerId);
              _loadActivities();
            },
            child: Text("Mark All Read", style: GoogleFonts.dmSans(color: primary, fontSize: 14)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 64, color: AppTheme.textDim.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text("No activities yet", style: GoogleFonts.dmSans(fontSize: 18, color: AppTheme.textDim, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadActivities,
                  color: primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      final type = activity['type'] ?? '';
                      final isUnread = activity['is_read'] == 0 || activity['is_read'] == '0';
                      
                      return InkWell(
                        onTap: () => _onActivityTap(activity),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUnread ? primary.withOpacity(0.05) : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: isUnread ? Border.all(color: primary.withOpacity(0.2)) : Border.all(color: Colors.white.withOpacity(0.05)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getColor(type).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_getIcon(type), color: _getColor(type), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity['title'] ?? 'Activity',
                                      style: GoogleFonts.dmSans(
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary
                                      ),
                                    ),
                                    if (activity['message'] != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        activity['message'],
                                        style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      _timeAgo(activity['created_at']),
                                      style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textDim),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                                ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded, color: AppTheme.textDim),
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
