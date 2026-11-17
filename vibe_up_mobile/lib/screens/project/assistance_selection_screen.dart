import 'package:vibe_up/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/project/ai_design_setup_screen.dart';
import 'package:vibe_up/screens/project/designer_list_screen.dart';
import 'package:vibe_up/screens/project/diy_workspace_screen.dart';

class AssistanceSelectionScreen extends StatelessWidget {
  final String? projectId;
  final String? projectName;
  final Map<String, dynamic>? projectData;
  final bool isFloorPlanMode;
  const AssistanceSelectionScreen({super.key, this.projectId, this.projectName, this.projectData, this.isFloorPlanMode = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Design Philosophy', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Your Experience',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate().fade().slideX(begin: -0.1),
              const SizedBox(height: 12),
              Text(
                'How would you like to curate your space? Choose between our advanced AI, expert artisans, or your own creative intuition.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ).animate().fade(delay: 100.ms),
              const SizedBox(height: 48),

              _buildLuxuryOptionCard(
                context,
                title: 'INTELLIGENT AI',
                subtitle: 'Generative Design Studio',
                description: 'Our proprietary AI synthesizes your preferences into high-fidelity interior concepts in seconds.',
                icon: Icons.auto_awesome_rounded,
                accentColor: AppTheme.primaryAccent,
                delay: 200,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiDesignSetupScreen(projectId: projectId))),
              ),
              const SizedBox(height: 20),
              _buildLuxuryOptionCard(
                context,
                title: 'EXPERT CONCIERGE',
                subtitle: 'Artisan Consultation',
                description: 'Collaborate with world-class interior designers for a bespoke, hand-crafted aesthetic.',
                icon: Icons.groups_3_rounded,
                accentColor: const Color(0xFF7B68EE),
                delay: 300,
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => DesignerListScreen(
                      projectId: projectId,
                      projectName: projectName,
                    )
                  )
                ),
              ),
              const SizedBox(height: 20),
              _buildLuxuryOptionCard(
                context,
                title: 'CREATIVE ATELIER',
                subtitle: 'DIY Mastery',
                description: 'Full autonomy with our high-end 3D workspace and curated furniture archives.',
                icon: Icons.architecture_rounded,
                accentColor: const Color(0xFF4CAF50),
                delay: 400,
                onTap: () async {
                  final result = await Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => DiyWorkspaceScreen(
                        projectId: projectId,
                        projectData: projectData,
                        isFloorPlanMode: isFloorPlanMode,
                        roomName: projectName,
                      )
                    )
                  );
                  if (context.mounted) {
                    if (result != null && result is Map && result['success'] == true) {
                      Navigator.pop(context, result);
                    } else if (result == true) {
                      Navigator.pop(context, true);
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryOptionCard(BuildContext context, {
    required String title, 
    required String subtitle,
    required String description, 
    required IconData icon, 
    required Color accentColor,
    required int delay, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryAccent,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDim,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textDim, size: 14),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.6,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ).animate().fade(delay: delay.ms).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutQuart),
    );
  }
}
