import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/feedback/designer_feedback_screen.dart';
import 'package:vibe_up/screens/feedback/general_feedback_screen.dart';

class FeedbackOptionsScreen extends StatelessWidget {
  const FeedbackOptionsScreen({super.key});

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
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rate_review_rounded, size: 60, color: AppTheme.primaryAccent),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              Text(
                'Luxury in Every Detail',
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                'Help us refine the VibeUp experience. Share your thoughts or review our designers.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
              ).animate().fade(delay: 300.ms),
              const SizedBox(height: 56),

              _buildAction(
                context, 
                'Review a Designer', 
                'Evaluate the professionals you have collaborated with.',
                Icons.person_pin_rounded, 
                AppTheme.primaryAccent,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignerFeedbackScreen())),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 20),
              
              _buildAction(
                context, 
                'App Experience', 
                'Share your suggestions regarding the VibeUp platform.',
                Icons.app_settings_alt_rounded, 
                const Color(0xFF7B68EE),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralFeedbackScreen())),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, String title, String subtitle, IconData icon, Color accentColor, VoidCallback onTap) {
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
              child: Icon(icon, size: 28, color: accentColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
