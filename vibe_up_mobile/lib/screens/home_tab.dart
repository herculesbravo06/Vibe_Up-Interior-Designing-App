import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/project/project_type_screen.dart';
import 'package:vibe_up/screens/old_projects/old_projects_list_screen.dart';
import 'package:vibe_up/screens/feedback/feedback_selection_screen.dart';
import 'package:vibe_up/screens/catalog/design_catalog_screen.dart';
import 'package:vibe_up/screens/chat/chat_list_screen.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';

import 'package:vibe_up/screens/tours/tour_categories_screen.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/notification_service.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';
import 'package:vibe_up/screens/project/diy_workspace_screen.dart';


import 'dart:async';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _userName = 'User';
  String _userId = '';
  List<Map<String, dynamic>> _activities = [];
  bool _isLoadingActivities = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchActivities());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userId = prefs.getString('user_id') ?? '';
    });
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    if (_userId.isEmpty) return;
    try {
      final notifs = await NotificationService.getNotifications(_userId);
      if (mounted) {
        setState(() {
          _activities = notifs.take(3).toList();
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingActivities = false);
    }
  }

  // Greeting based on time
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Define action items
  static const List<_ActionItem> _actionItems = [
    _ActionItem('New Project', Icons.add_home_work_outlined, Color(0xFFFF6B6B), Color(0x22FF6B6B)),
    _ActionItem('Old Projects', Icons.folder_copy_outlined, Color(0xFFFFB347), Color(0x22FFB347)),
    _ActionItem('360° Tours', Icons.view_in_ar_outlined, Color(0xFF7B68EE), Color(0x227B68EE)),
    _ActionItem('Design Catalog', Icons.palette_outlined, Color(0xFF4ECCA3), Color(0x224ECCA3)),
    _ActionItem('AI Floorplan', Icons.auto_awesome_motion_rounded, Color(0xFFFF9494), Color(0x22FF9494)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A16), Color(0xFF0F0F1A), Color(0xFF12121E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Greeting badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  DateTime.now().hour < 17 ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                  size: 14,
                                  color: AppTheme.secondaryAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _greeting,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Profile Dropdown
                    PopupMenuButton(
                      offset: const Offset(0, 50),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryAccent.withOpacity(0.6), AppTheme.secondaryAccent.withOpacity(0.4)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.cardColor,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$_userId'),
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20),
                              SizedBox(width: 8),
                              Text('Logout'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'logout') {
                          AuthService.logout(context);
                        }
                      },
                    ).animate().fade().scale(),
                  ],
                ).animate().fade().slideX(begin: -0.15),
                
                const SizedBox(height: 24),

                // User name
                Text(
                  'Hi, $_userName',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                const SizedBox(height: 6),

                // Subtitle with gradient text
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF9494), Color(0xFFFFB347)],
                  ).createShader(bounds),
                  child: Text(
                    'Let\'s create something beautiful ✨',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),
                
                // ─── Action Cards Grid ───
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: _actionItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return _buildActionCard(
                      context,
                      title: item.title,
                      icon: item.icon,
                      accentColor: item.color,
                      bgColor: item.bgColor,
                      delay: 300 + (i * 80),
                      onTap: () => _handleActionTap(i),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Feedback wide card
                _buildWideActionCard(
                  context, 
                  title: 'Share Feedback', 
                  subtitle: 'Help us improve your experience',
                  icon: Icons.rate_review_outlined, 
                  delay: 750,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackSelectionScreen())),
                ),
                
                const SizedBox(height: 36),
                
                // ─── Recent Activity Section ───
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ).animate().fade(delay: 800.ms),

                const SizedBox(height: 16),
                
                if (_isLoadingActivities)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primaryAccent.withOpacity(0.6),
                        ),
                      ),
                    ),
                  )
                else if (_activities.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 36, color: AppTheme.textDim.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No recent activity',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 850.ms)
                else
                  ..._activities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final act = entry.value;
                    return _buildRecentActivityItem(
                      context, 
                      act['title'] ?? 'Notification', 
                      act['message'] ?? '', 
                      delay: 850 + (index * 100),
                      onTap: () {
                         // Basic routing based on type
                         if (act['type'] == 'request_accepted' || act['type'] == 'request_declined') {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const OldProjectsListScreen()));
                         } else if (act['type'] == 'message_new') {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
                         }

                      }
                    );
                  }),
                
                const SizedBox(height: 100), // spacing for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleActionTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectTypeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OldProjectsListScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TourCategoriesScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignCatalogScreen()));
        break;
      case 4:
        _showAIFloorplanDialog(context);
        break;
    }
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required int delay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: accentColor),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fade(delay: delay.ms).scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        delay: delay.ms,
        duration: 350.ms,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Widget _buildWideActionCard(
      BuildContext context, {
      required String title,
      required String subtitle,
      required IconData icon,
      required int delay,
      required VoidCallback onTap,
    }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: AppTheme.secondaryAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      color: AppTheme.textDim,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textDim.withOpacity(0.5), size: 22),
          ],
        ),
      ).animate().fade(delay: delay.ms).slideX(begin: 0.08),
    );
  }

  Widget _buildRecentActivityItem(BuildContext context, String title, String subtitle, {required int delay, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.notifications_outlined, color: AppTheme.primaryAccent.withOpacity(0.7), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.textDim,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textDim.withOpacity(0.4), size: 20),
          ],
        ),
      ).animate().fade(delay: delay.ms).slideX(begin: 0.08),
    );
  }

  Future<void> _pickFloorplanImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null && context.mounted) {
        Navigator.pop(context); // Close initial dialog
        
        // Show "Analysis" progress dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppTheme.primaryAccent),
                const SizedBox(height: 20),
                Text('Analyzing Floorplan...', 
                  style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text('AI is extracting architectural details', 
                  style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 12)),
              ],
            ),
          ),
        );

        // Simulate AI Processing
        await Future.delayed(const Duration(seconds: 3));
        
        if (context.mounted) {
          Navigator.pop(context); // Close progress
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Floorplan analyzed! Initial 3D model generated.'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Navigate to 3D Editor with a fresh room
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DiyWorkspaceScreen(
                roomName: 'My Floor Plan',
                isFloorPlanMode: true,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error picking image')),
        );
      }
    }
  }

  void _showAIFloorplanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('AI Floorplan Recognition', 
          style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.primaryAccent, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Convert any 2D blueprint or hand-drawn sketch into a fully interactive 3D model using AI Plan Recognition.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: AppTheme.textDim, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _pickFloorplanImage(context),
                icon: const Icon(Icons.upload_file_rounded, size: 20),
                label: Text('Upload Floorplan', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.dmSans(color: AppTheme.textDim)),
          )
        ],
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ActionItem(this.title, this.icon, this.color, this.bgColor);
}
