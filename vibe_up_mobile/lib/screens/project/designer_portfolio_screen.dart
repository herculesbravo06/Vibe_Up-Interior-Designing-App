import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/services/request_service.dart';

class DesignerPortfolioScreen extends StatelessWidget {
  final String name;
  final String designerId;
  final String bio;
  final String rating;
  final String experience;
  final String profileUrl;
  final String? projectId;
  final String? projectName;

  const DesignerPortfolioScreen({
    super.key,
    required this.name,
    required this.designerId,
    required this.bio,
    required this.rating,
    required this.experience,
    required this.profileUrl,
    this.projectId,
    this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: AppTheme.glassDecoration,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryAccent, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryAccent.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.goldGradient,
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundImage: CachedNetworkImageProvider(profileUrl),
                      onBackgroundImageError: (_, __) {},
                      backgroundColor: Colors.black,
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fade().slideY(begin: 0.2),
                  const SizedBox(height: 10),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fade(delay: 100.ms),
                  const SizedBox(height: 28),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat(context, Icons.star_rounded, rating, 'Rating'),
                      _buildDivider(),
                      _buildStat(context, Icons.work_history_rounded, '$experience yrs', 'Exp'),
                      _buildDivider(),
                      _buildStat(context, Icons.design_services_rounded, '15+', 'Works'),
                    ],
                  ).animate().fade(delay: 200.ms),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Qualifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expertise & Awards',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildQualTile(context, Icons.school_rounded, 'M.Des Interior Design'),
                    _buildQualTile(context, Icons.verified_rounded, 'Certified Luxury Space Specialist'),
                    _buildQualTile(context, Icons.emoji_events_rounded, 'Platinum Design Award 2025'),
                  ],
                ),
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Portfolio Gallery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Masterpieces',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'SEE ALL',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        _buildPortfolioImage('https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=400'),
                        _buildPortfolioImage('https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=400'),
                        _buildPortfolioImage('https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=400'),
                        _buildPortfolioImage('https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=400'),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 48),

            // Send Request Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _showRequestDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: AppTheme.primaryAccent.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Collaborate with $name',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.2),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryAccent, size: 26),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDim, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQualTile(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: AppTheme.primaryAccent),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildPortfolioImage(String url) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: url,
              height: 180,
              width: 240,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.05), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryAccent))),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context) {
    final projectNameController = TextEditingController(text: projectName);
    final projectDetailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.white10)),
        title: Text('Start Collaboration', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Details', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDim, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: projectNameController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g., Luxe Master Suite',
                hintStyle: GoogleFonts.inter(color: AppTheme.textDim.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: projectDetailsController,
              maxLines: 4,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tell $name about your vision...',
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
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textDim)),
          ),
          ElevatedButton(
            onPressed: () async {
              final pName = projectNameController.text.trim();
              final pDetails = projectDetailsController.text.trim();
              if (pName.isEmpty) return;

              final success = await RequestService.saveRequest(
                designerId: designerId,
                projectName: pName,
                projectDetails: pDetails.isEmpty ? 'No details' : pDetails,
                projectId: projectId,
              );

              if (ctx.mounted) Navigator.pop(ctx);
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Collaboration request sent!'), backgroundColor: AppTheme.primaryAccent, behavior: SnackBarBehavior.floating),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Send Request', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
