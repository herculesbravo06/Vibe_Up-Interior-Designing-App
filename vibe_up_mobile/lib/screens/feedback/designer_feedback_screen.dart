import 'package:vibe_up/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/services/request_service.dart';

class DesignerFeedbackScreen extends StatefulWidget {
  const DesignerFeedbackScreen({super.key});

  @override
  State<DesignerFeedbackScreen> createState() => _DesignerFeedbackScreenState();
}

class _DesignerFeedbackScreenState extends State<DesignerFeedbackScreen> {
  List<dynamic> _designers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDesigners();
  }

  Future<void> _loadDesigners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('user_id');

      if (currentUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final allDesigners = await ApiService.getDesigners();
      
      // Get accepted requests for the current user
      final requests = await RequestService.getRequests(status: 'accepted', userId: currentUserId);
      
      // Get set of designer IDs that accepted the user's requests
      final acceptedDesignerIds = requests.map((r) => r['designer_id']).toSet();

      // Filter designers list by designer_id (D...)
      final filteredDesigners = allDesigners.where((d) => acceptedDesignerIds.contains(d['designer_id'])).toList();

      if (mounted) {
        setState(() {
          _designers = filteredDesigners;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Review Designers', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 2))
          : _designers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: 80, color: AppTheme.textDim.withOpacity(0.2)),
                      const SizedBox(height: 20),
                      Text('No collaborations yet', style: GoogleFonts.poppins(fontSize: 18, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('Designers you\'ve worked with will appear here.', style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: _designers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final designer = _designers[index];
                    final profileUrl = designer['profile_pic_url'] ?? 'https://i.pravatar.cc/150?img=${index + 5}';
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.goldGradient),
                                child: CircleAvatar(radius: 32, backgroundImage: NetworkImage(profileUrl)),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      designer['name'] ?? 'Designer',
                                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppTheme.primaryAccent, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${designer['rating'] ?? '0.0'} Rating',
                                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '${designer['experience_years'] ?? '0'} Yrs Exp',
                                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _showFeedbackDialog(context, designer),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                                foregroundColor: AppTheme.primaryAccent,
                                elevation: 0,
                                side: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text('Leave a Review', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: (100 + index * 100).ms).slideY(begin: 0.1);
                  },
                ),
    );
  }

  void _showFeedbackDialog(BuildContext context, Map<String, dynamic> designer) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E28),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
              title: Text('Rate ${designer['name']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: index < selectedRating ? AppTheme.primaryAccent : AppTheme.textDim.withOpacity(0.3),
                        size: 36,
                      ),
                      onPressed: () => setDialogState(() => selectedRating = index + 1),
                    )),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts on their work...',
                      hintStyle: GoogleFonts.inter(color: AppTheme.textDim.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textDim)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    if (commentController.text.trim().isEmpty) return;
                    setDialogState(() => isSubmitting = true);
                    try {
                      await ApiService.submitDesignerFeedback(
                        designerId: designer['designer_id'] ?? designer['id'] ?? '',
                        rating: selectedRating,
                        comment: commentController.text.trim(),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Feedback Submitted'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      setDialogState(() => isSubmitting = false);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Failed to submit. Try again.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text('Submit review', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
