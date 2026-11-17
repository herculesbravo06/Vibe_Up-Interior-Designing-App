import 'package:vibe_up/screens/designer_mode/my_project.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'manage_requests_page.dart';
import 'designer_chat_list_screen.dart';
import 'feedback_page.dart';
import 'finishedproject.dart';
import 'designer_profile_page.dart';
import 'all_activities_page.dart';
import 'designer_ai_chat_screen.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';
import 'package:vibe_up/screens/auth/auth_decision_screen.dart';
import 'package:flutter/material.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/services/notification_service.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'dart:async';

class DesignerDashboard extends StatefulWidget {
  const DesignerDashboard({super.key});

  @override
  State<DesignerDashboard> createState() => _DesignerDashboardState();
}

class _DesignerDashboardState extends State<DesignerDashboard> {
  String _userName = 'Designer';
  String _designerId = '';
  String _userId = '';
  int _unreadCount = 0;
  Map<String, dynamic> _stats = {
    'total_projects': 0,
    'pending_requests': 0,
    'completed_projects': 0,
    'rating': 0.0
  };
  List<Map<String, dynamic>> _activities = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Designer';
      _designerId = prefs.getString('designer_id') ?? prefs.getString('user_id') ?? '';
      _userId = prefs.getString('user_id') ?? '';
    });
    _refreshData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshData());
  }

  Future<void> _refreshData() async {
    if (_designerId.isEmpty) return;
    final result = await ApiService.getDesignerStats(_designerId);
    if (mounted) {
      if (result['status'] == 'success') {
        setState(() => _stats = result['data']);
      }
      final notifs = await NotificationService.getNotifications(_designerId);
      final unread = await NotificationService.getUnreadCount(_designerId);
      setState(() {
        _activities = notifs.take(5).toList();
        _unreadCount = unread;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.primaryAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final profile = _stats['profile'] ?? {};
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DesignerProfilePage(
                            name: profile['name'] ?? _userName,
                            role: "Interior Designer",
                            location: profile['location'] ?? "Expert",
                            image: profile['profile_image'] != null
                                ? '${ApiService.baseUrl}${profile['profile_image']}'
                                : "https://i.pravatar.cc/150?u=$_designerId",
                            projects: _stats['total_projects'],
                            experience: profile['experience_years']?.toString() ?? "8+",
                            rating: double.tryParse(_stats['rating']?.toString() ?? '0') ?? 0.0,
                          )));
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.primaryAccent.withOpacity(0.3)]),
                              ),
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  _stats['profile']?['profile_image'] != null
                                      ? '${ApiService.baseUrl}${_stats['profile']?['profile_image']}'
                                      : "https://i.pravatar.cc/150?u=$_designerId",
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Good morning,", style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textDim, letterSpacing: 1.2)),
                                Text(_userName, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            decoration: AppTheme.glassDecoration,
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined, size: 22),
                              onPressed: () {},
                            ),
                          ),
                          if (_unreadCount > 0)
                            Positioned(
                              right: 4, top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AppTheme.errorColor, shape: BoxShape.circle),
                                child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _statCard(Icons.architecture_rounded, "Total Projects", _stats['total_projects'].toString(), const Color(0xFF7B68EE)),
                      _statCard(Icons.pending_actions_rounded, "Pending", _stats['pending_requests'].toString(), const Color(0xFFFF7043)),
                      _statCard(Icons.check_circle_rounded, "Completed", _stats['completed_projects'].toString(), const Color(0xFF4CAF50)),
                      _statCard(Icons.star_rounded, "Rating", "${_stats['rating']}/5", AppTheme.primaryAccent),
                    ],
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Quick Actions", style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProject())), child: _actionCard("My Projects", Icons.folder_rounded, const Color(0xFF7B68EE))),
                          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRequestsPage())), child: _actionCard("Manage Requests", Icons.inbox_rounded, const Color(0xFFFF7043))),
                          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinishedProjectsPage())), child: _actionCard("Finished", Icons.check_circle_rounded, const Color(0xFF4CAF50))),
                          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage())), child: _actionCard("Feedback", Icons.rate_review_rounded, const Color(0xFF29B6F6))),
                          GestureDetector(
                            onTap: () {
                              try { Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignerAiChatScreen())); }
                              catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
                            },
                            child: _actionCard("AI Assistant", Icons.auto_awesome_rounded, AppTheme.primaryAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Recent Activity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Recent Activity", style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllActivitiesPage(designerId: _designerId))),
                            child: Text("View All", style: GoogleFonts.dmSans(color: AppTheme.primaryAccent, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_activities.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text("No recent activity", style: GoogleFonts.dmSans(color: AppTheme.textDim)),
                        ),
                      ..._activities.map((act) {
                        final type = act['type'] ?? '';
                        IconData icon;
                        switch (type) {
                          case 'request_new': icon = Icons.inbox_rounded; break;
                          case 'request_accepted': icon = Icons.check_circle_rounded; break;
                          case 'request_declined': icon = Icons.cancel_rounded; break;
                          case 'message_new': icon = Icons.chat_bubble_rounded; break;
                          default: icon = Icons.notifications_rounded;
                        }
                        return _activityTile(icon, act['title'] ?? 'Notification', _timeAgo(act['created_at'] ?? ''), onTap: () {
                          if (act['id'] != null) NotificationService.markAsRead(act['id']);
                          if (type == 'message_new') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignerChatListScreen()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRequestsPage()));
                          }
                        });
                      }),
                    ],
                  ),
                ).animate().fade(delay: 400.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppTheme.background,
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16162C).withOpacity(0.95), // Floating pill background
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
              BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, -2)),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navItem(Icons.home_rounded, 'Home', true, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DesignerDashboard()))),
                  _navItem(Icons.folder_rounded, 'Projects', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProject()))),
                  _navItem(Icons.chat_bubble_rounded, 'Chat', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignerChatListScreen()))),
                  _navItem(Icons.person_rounded, 'Profile', false, () {
                    final profile = _stats['profile'] ?? {};
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DesignerProfilePage(
                      name: profile['name'] ?? _userName, role: "Interior Designer",
                      location: profile['location'] ?? "Online",
                      image: profile['profile_image'] != null ? '${ApiService.baseUrl}${profile['profile_image']}' : "https://i.pravatar.cc/150?u=$_designerId",
                      projects: _stats['total_projects'], experience: profile['profile_years']?.toString() ?? "8+",
                      rating: double.tryParse(_stats['rating']?.toString() ?? '0') ?? 0.0,
                    )));
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: active ? 18 : 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: active ? AppTheme.primaryAccent : AppTheme.textDim),
            if (active) ...[
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textDim, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, letterSpacing: 0.3), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _activityTile(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.primaryAccent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textDim)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }

  String _timeAgo(String timestamp) {
    if (timestamp.isEmpty) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return timestamp;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
