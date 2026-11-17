import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/chat/chat_detail_screen.dart';
import 'package:vibe_up/screens/chat/human_chat_screen.dart';
import 'package:vibe_up/screens/designer_mode/chat_page.dart';
import 'package:vibe_up/services/request_service.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _acceptedDesigners = [];

  @override
  void initState() {
    super.initState();
    _loadAcceptedDesigners();
  }

  Future<void> _loadAcceptedDesigners() async {
    final accepted = await RequestService.getRequests(status: 'accepted');
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final r in accepted) {
      final name = r['designerName'] ?? '';
      if (name.isNotEmpty && seen.add(name)) unique.add(r);
    }
    if (mounted) setState(() => _acceptedDesigners = unique);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Messages', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: AppTheme.glassDecoration,
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: _loadAcceptedDesigners,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // AI Assistant
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(designerName: 'VibeUp AI Assistant'))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryAccent.withOpacity(0.12), AppTheme.primaryAccent.withOpacity(0.04)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.black, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VibeUp AI', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Your virtual design assistant', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryAccent),
                    ],
                  ),
                ),
              ).animate().fade().slideY(begin: -0.05),
            ),
          ),

          // Designer Section Header
          if (_acceptedDesigners.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Your Designers', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              ),
            ),

          // Designer Chats
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final req = _acceptedDesigners[index];
                  final name = req['designerName'] ?? 'Designer';
                  final project = req['projectName'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        final rId = (req['designer_user_id']?.toString() ?? '').isNotEmpty
                            ? req['designer_user_id'].toString()
                            : (req['designer_id']?.toString() ?? '');
                        final sId = req['user_id']?.toString() ?? '';
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => HumanChatScreen(designerName: name, senderId: sId, receiverId: rId),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                              child: Text(name[0].toUpperCase(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    project.isNotEmpty ? 'Project: $project' : 'Tap to chat',
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDim),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textDim),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: (100 + index * 60).ms).slideX(begin: -0.05),
                  );
                },
                childCount: _acceptedDesigners.length,
              ),
            ),
          ),

          // Empty State
          if (_acceptedDesigners.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppTheme.textDim.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No designer chats yet.\nSend a request from the Designers list!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
