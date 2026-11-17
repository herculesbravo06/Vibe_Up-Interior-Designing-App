import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/designer_portfolio_screen.dart';
import 'package:vibe_up/screens/chat/human_chat_screen.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/services/request_service.dart';

class DesignerListScreen extends StatefulWidget {
  final String? projectId;
  final String? projectName;
  const DesignerListScreen({super.key, this.projectId, this.projectName});

  @override
  State<DesignerListScreen> createState() => _DesignerListScreenState();
}

class _DesignerListScreenState extends State<DesignerListScreen> {
  List<dynamic> _designers = [];
  List<Map<String, dynamic>> _acceptedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final designers = await ApiService.getDesigners();
      final accepted = await RequestService.getRequests(status: 'accepted');
      // Deduplicate accepted by designer name
      final seen = <String>{};
      final unique = <Map<String, dynamic>>[];
      for (final r in accepted) {
        final name = r['designerName'] ?? '';
        if (name.isNotEmpty && seen.add(name)) {
          unique.add(r);
        }
      }
      if (mounted) {
        setState(() {
          _designers = designers;
          _acceptedRequests = unique;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Expert Designers', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: AppTheme.glassDecoration,
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () {
                setState(() => _isLoading = true);
                _loadData();
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 2))
          : _designers.isEmpty && _acceptedRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: 64, color: AppTheme.textDim.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No designers found', style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    // Accepted Designers
                    if (_acceptedRequests.isNotEmpty) ...[
                      Row(
                        children: [
                           Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                             child: const Icon(Icons.verified_rounded, color: Color(0xFF4CAF50), size: 18),
                           ),
                           const SizedBox(width: 12),
                           Text('Active Collaborations', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ],
                      ).animate().fade(),
                      const SizedBox(height: 6),
                      Text('Designers who have accepted your requests.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ..._acceptedRequests.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final req = entry.value;
                        final name = req['designerName'] ?? 'Designer';
                        final project = req['projectName'] ?? 'Project';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2A1E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF4CAF50).withOpacity(0.15),
                                child: Text(name[0].toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4CAF50))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text('Project: $project', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final rId = (req['designer_user_id']?.toString() ?? '').isNotEmpty 
                                        ? req['designer_user_id'].toString() 
                                        : (req['designer_id']?.toString() ?? '');
                                    final sId = req['user_id']?.toString() ?? '';
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => HumanChatScreen(designerName: name, senderId: sId, receiverId: rId)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('Chat', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(delay: (100 + idx * 60).ms).slideX(begin: -0.05);
                      }),
                      const SizedBox(height: 32),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 24),
                    ],

                    // Browse Designers
                    if (_designers.isNotEmpty) ...[
                      Text('Top Portfolio Designers', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)).animate().fade(),
                      const SizedBox(height: 16),
                      ..._designers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final designer = entry.value;
                        final profileUrl = designer['profile_pic_url'] ?? 'https://i.pravatar.cc/150?img=${index + 10}';
                        final rating = designer['rating']?.toString() ?? '0.0';
                        final experience = designer['experience_years']?.toString() ?? '0';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.goldGradient),
                                    child: CircleAvatar(radius: 28, backgroundImage: CachedNetworkImageProvider(profileUrl)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(designer['name'] ?? 'Designer', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textPrimary)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, color: AppTheme.primaryAccent, size: 18),
                                            Text(' $rating', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                            const SizedBox(width: 16),
                                            Text('$experience Yrs Exp', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                designer['bio'] ?? 'Expert in high-end luxury interiors and bespoke spatial design.',
                                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => DesignerPortfolioScreen(
                                      name: designer['name'] ?? 'Designer',
                                      designerId: designer['designer_id']?.toString() ?? designer['id']?.toString() ?? '',
                                      bio: designer['bio'] ?? 'Interior Design Specialist',
                                      rating: designer['rating']?.toString() ?? '0.0',
                                      experience: designer['experience_years']?.toString() ?? '0',
                                      profileUrl: profileUrl,
                                      projectId: widget.projectId,
                                      projectName: widget.projectName,
                                    )));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    foregroundColor: AppTheme.primaryAccent,
                                    side: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.3)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: Text('View Full Portfolio', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(delay: (200 + index * 100).ms).slideY(begin: 0.1);
                      }),
                    ],
                  ],
                ),
    );
  }
}
