import 'package:vibe_up/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/feedback/general_feedback_screen.dart';
import 'package:vibe_up/screens/feedback/designer_feedback_screen.dart';

class FeedbackSelectionScreen extends StatelessWidget {
  const FeedbackSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Feedback', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Luxury in Every Detail',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ).animate().fade().slideX(begin: -0.2),
              const SizedBox(height: 12),
              Text(
                'Help us refine the VibeUp experience. Share your thoughts or review our designers.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ).animate().fade(delay: 200.ms).slideX(begin: -0.2),
              const SizedBox(height: 48),

              _buildOptionCard(
                context,
                title: 'Review a Designer',
                description: 'Evaluate the professionals you collaborated with.',
                icon: Icons.person_pin_rounded,
                accentColor: AppTheme.primaryAccent,
                delay: 300,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignerFeedbackScreen())),
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                title: 'App Experience',
                description: 'Share your thoughts regarding the VibeUp platform.',
                icon: Icons.app_settings_alt_rounded,
                accentColor: const Color(0xFF7B68EE),
                delay: 400,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralFeedbackScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required String title, required String description, required IconData icon, required Color accentColor, required int delay, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.12), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ],
        ),
      ).animate().fade(delay: delay.ms).slideY(begin: 0.2),
    );
  }
}
