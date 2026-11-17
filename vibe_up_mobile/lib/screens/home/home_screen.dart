import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/auth/auth_decision_screen.dart';
import 'package:vibe_up/screens/project/project_type_screen.dart';
import 'package:vibe_up/screens/project/old_projects_screen.dart';
import 'package:vibe_up/screens/feedback/feedback_options_screen.dart';
import 'package:vibe_up/screens/catalogue/catalogue_screen.dart';
import 'package:vibe_up/screens/chat/chat_list_screen.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';


import 'package:vibe_up/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _unreadCount = 0;
  String _userName = 'User';
  String _userId = '';
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _initRealtime();
  }

  Future<void> _initRealtime() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? 'U10001';
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });

    _fetchActivities();
    NotificationService.startPolling(_userId, onUnreadCountChanged: (count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
        _fetchActivities();
      }
    });
  }

  Future<void> _fetchActivities() async {
    if (_userId.isEmpty) return;
    final notifs = await NotificationService.getNotifications(_userId);
    if (mounted) {
      setState(() {
        _activities = notifs.take(5).toList();
      });
    }
  }

  @override
  void dispose() {
    NotificationService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _fetchActivities,
        color: AppTheme.primaryAccent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Premium App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppTheme.background,
              elevation: 0,
              toolbarHeight: 70,
              title: Row(
                children: [
                  Image.asset('assets/logo_premium.png', width: 36, height: 36,
                    errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: AppTheme.primaryAccent, size: 28)),
                  const SizedBox(width: 12),
                  ShaderMask(
                    shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                    child: Text('VIBEUP', style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 3, color: Colors.white,
                    )),
                  ),
                ],
              ),
              actions: [
                Stack(
                  alignment: Alignment.center,
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
                        right: 6, top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text('$_unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        AppTheme.primaryAccent.withOpacity(0.3),
                        AppTheme.primaryAccent.withOpacity(0.1),
                      ]),
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.cardColor,
                      child: Icon(Icons.person, color: AppTheme.primaryAccent, size: 18),
                    ),
                  ),
                  color: AppTheme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'logout') AuthService.logout(context);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: AppTheme.errorColor, size: 18),
                          const SizedBox(width: 10),
                          Text('Logout', style: GoogleFonts.inter(color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Welcome Hero
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1E28), Color(0xFF16161C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryAccent.withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userName,
                            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ready to design your dream space?',
                            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectTypeScreen())),
                              icon: const Icon(Icons.add, size: 20),
                              label: Text('Start New Project', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 500.ms).slideY(begin: 0.1),

                    const SizedBox(height: 28),

                    // Quick Actions Grid
                    Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _buildPremiumCard(
                          icon: Icons.history_rounded,
                          title: 'My Projects',
                          subtitle: 'Resume work',
                          color: const Color(0xFF7B68EE),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OldProjectsScreen())),
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: _buildPremiumCard(
                          icon: Icons.style_rounded,
                          title: 'Catalogue',
                          subtitle: 'Browse items',
                          color: const Color(0xFFFF7043),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogueScreen())),
                        )),
                      ],
                    ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(child: _buildPremiumCard(
                          icon: Icons.rate_review_rounded,
                          title: 'Feedback',
                          subtitle: 'Rate & Review',
                          color: const Color(0xFF4CAF50),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackOptionsScreen())),
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: _buildPremiumCard(
                          icon: Icons.view_in_ar_rounded,
                          title: '3D House',
                          subtitle: 'Explore in AR',
                          color: const Color(0xFF29B6F6),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectTypeScreen())),
                        )),
                      ],
                    ).animate().fade(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1),

                    const SizedBox(height: 32),

                    // Activity Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Activity', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                        TextButton.icon(
                          onPressed: _fetchActivities,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text('Refresh', style: GoogleFonts.inter(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryAccent),
                        ),
                      ],
                    ).animate().fade(delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: 12),

                    if (_activities.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: AppTheme.glassDecoration,
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textDim.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('No recent activity', style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14)),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_activities.length, (i) {
                        final act = _activities[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildActivityTile(
                            act['title'] ?? 'Update',
                            act['created_at'] ?? '',
                            act['title']?.toLowerCase().contains('message') == true ? Icons.message_rounded : Icons.notifications_active_rounded,
                            () {
                              if (act['title']?.toLowerCase().contains('message') == true) {
                                Navigator.pushNamed(context, '/chats');
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const OldProjectsScreen()));
                              }
                            },
                          ),
                        );
                      }).animate(interval: 80.ms, delay: 500.ms).fade().slideX(begin: 0.05),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        height: 135,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDim)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String title, String time, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryAccent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                  Text(time, style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }
}
