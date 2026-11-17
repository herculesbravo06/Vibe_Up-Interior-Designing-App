import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/screens/designer_mode/chat_page.dart';
import 'package:vibe_up/services/request_service.dart';
import 'package:vibe_up/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:vibe_up/theme/app_theme.dart';

class DesignerChatListScreen extends StatefulWidget {
  const DesignerChatListScreen({super.key});

  @override
  State<DesignerChatListScreen> createState() => _DesignerChatListScreenState();
}

class _DesignerChatListScreenState extends State<DesignerChatListScreen> {
  List<Map<String, dynamic>> _clients = [];
  Map<String, String> _lastMessages = {};   
  Map<String, String> _lastTimes = {};      
  Map<String, int> _unreadCounts = {};      
  bool _isLoading = true;
  Timer? _refreshTimer;

  String currentDesignerId = ''; // designer table ID (e.g. D20001)
  String currentUserId = '';     // user table ID (e.g. U20001)
  final Color primaryOrange = AppTheme.primaryAccent;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentDesignerId = prefs.getString('designer_id') ?? '';
      currentUserId = prefs.getString('user_id') ?? '';
    });
    _loadLocalClients();
    _tryFetchApiData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _tryFetchApiData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalClients() async {
    if (currentDesignerId.isEmpty) return;
    final accepted = await RequestService.getRequests(status: 'accepted', designerId: currentDesignerId);
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final r in accepted) {
      final name = r['userName'] ?? '';
      if (name.isNotEmpty && seen.add(name)) {
        unique.add(r);
      }
    }
    if (mounted) {
      setState(() {
        _clients = unique;
        _isLoading = false;
      });
    }
  }

  Future<void> _tryFetchApiData() async {
    if (currentUserId.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}api_v2/get_chat_list.php?user_id=$currentUserId'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final chats = List<Map<String, dynamic>>.from(data['chats']);
          final Map<String, String> msgs = {};
          final Map<String, String> times = {};
          final Map<String, int> unreads = {};

          for (final chat in chats) {
            final name = chat['other_user_name'] ?? '';
            msgs[name] = chat['last_message'] ?? '';
            times[name] = _formatTime(chat['last_message_time']);
            final otherId = chat['other_user_id'] ?? '';
            if (otherId.isNotEmpty) {
              unreads[name] = chat['unread_count'] ?? 0;
            }
          }

          if (mounted) {
            setState(() {
              _lastMessages = msgs;
              _lastTimes = times;
              _unreadCounts = unreads;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Chat list API error: $e");
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        int h = dt.hour;
        int m = dt.minute;
        String ampm = h >= 12 ? 'pm' : 'am';
        if (h > 12) h -= 12;
        if (h == 0) h = 12;
        return '$h:${m.toString().padLeft(2, '0')} $ampm';
      } else if (diff.inDays == 1) return 'Yesterday';
      else if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      } else return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Chats', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 26, color: AppTheme.textPrimary)),
        centerTitle: false,
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryOrange),
            onPressed: () { _loadLocalClients(); _tryFetchApiData(); },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 72, color: AppTheme.textDim.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No chats yet',
                        style: GoogleFonts.playfairDisplay(fontSize: 22, color: AppTheme.textDim, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text('Accept a project request to start chatting!', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: _clients.length,
                  itemBuilder: (context, index) {
                    final req = _clients[index];
                    final userName = req['userName'] ?? 'User';
                    final projectName = req['projectName'] ?? 'Project';
                    final targetUserId = req['user_id']?.toString() ?? '';

                    final lastMsg = _lastMessages[userName] ?? 'Tap to chat';
                    final lastTime = _lastTimes[userName] ?? '';
                    final int unreadCount = _unreadCounts[userName] ?? 0;

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (targetUserId.isEmpty) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  clientName: userName,
                                  projectTitle: projectName,
                                  senderId: currentUserId,
                                  receiverId: targetUserId,
                                  userRole: 'designer',
                                ),
                              ),
                            ).then((_) {
                              _loadLocalClients();
                              _tryFetchApiData();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: primaryOrange.withOpacity(0.12),
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryOrange),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: GoogleFonts.playfairDisplay(
                                          fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                                          fontSize: 18,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lastMsg,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: unreadCount > 0 ? Colors.white : AppTheme.textDim,
                                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      lastTime,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: unreadCount > 0 ? primaryOrange : AppTheme.textDim,
                                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (unreadCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: primaryOrange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(delay: (80 + index * 40).ms).slideX(begin: -0.05),
                        if (index < _clients.length - 1)
                          Divider(height: 1, indent: 78, endIndent: 16, color: Colors.white.withOpacity(0.05)),
                      ],
                    );
                  },
                ),
    );
  }
}
