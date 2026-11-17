import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/home/home_screen.dart';
import 'package:vibe_up/screens/chat/chat_list_screen.dart';
import 'package:vibe_up/screens/profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.primaryAccent,
        unselectedItemColor: AppTheme.textDim,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_outlined)), 
            activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home)), 
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.chat_bubble_outline)), 
            activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.chat_bubble)), 
            label: 'Chat'
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)), 
            activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person)), 
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}
