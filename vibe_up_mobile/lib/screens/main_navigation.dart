import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/screens/home_tab.dart';
import 'package:vibe_up/screens/chat/chat_list_screen.dart';
import 'package:vibe_up/screens/profile/profile_screen.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/api_service.dart';
import 'dart:async';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}


class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _startHeartbeat();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  Future<void> _startHeartbeat() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    
    // Immediate heartbeat on login/entry
    if (userId.isNotEmpty) {
      ApiService.sendHeartbeat(userId);
    }

    // Periodic heartbeat every 2 minutes
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (userId.isNotEmpty) {
        ApiService.sendHeartbeat(userId);
      }
    });
  }


  final List<Widget> _tabs = const [
    HomeTab(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 8, left: 20, right: 20, top: 0),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: AppTheme.primaryAccent.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
              _buildNavItem(2, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryAccent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive ? AppTheme.primaryAccent : AppTheme.textDim,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
