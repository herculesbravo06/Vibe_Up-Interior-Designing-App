import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/project_dimensions_screen.dart';
import 'package:vibe_up/screens/project/house_setup_screen.dart';

class ProjectTypeScreen extends StatelessWidget {
  const ProjectTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Your Method',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ).animate().fade(duration: 400.ms).slideX(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'How would you like to start your project?',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textDim,
                ),
              ).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: -0.2),
              const SizedBox(height: 48),

              // Option 1: Generate Room
              _buildTypeCard(
                context,
                icon: Icons.dashboard_customize_outlined,
                title: 'Generate Room',
                description: 'Enter room dimensions manually and design a single room from scratch.',
                gradient: const [Color(0xFF2A2A40), Color(0xFF1E1E30)],
                delay: 200,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectDimensionsScreen()),
                ),
              ),
              const SizedBox(height: 20),

              // Option 2: Build Whole House (Manual)
              _buildTypeCard(
                context,
                icon: Icons.holiday_village_outlined,
                title: 'Create Whole House',
                description: 'Select your BHK layout and manually craft a full house from scratch.',
                gradient: const [Color(0xFF202A24), Color(0xFF131A16)],
                delay: 275,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HouseSetupScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required int delay,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPremium
                ? AppTheme.primaryAccent.withOpacity(0.4)
                : AppTheme.textDim.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isPremium
                  ? AppTheme.primaryAccent.withOpacity(0.08)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isPremium
                    ? AppTheme.primaryAccent.withOpacity(0.15)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPremium
                      ? AppTheme.primaryAccent.withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Icon(
                icon,
                size: 30,
                color: isPremium ? AppTheme.primaryAccent : AppTheme.textLight,
              ),
            ),
            const SizedBox(width: 20),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'AI',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isPremium ? AppTheme.primaryAccent : AppTheme.textDim,
              size: 24,
            ),
          ],
        ),
      ),
    ).animate().fade(delay: Duration(milliseconds: delay)).slideY(begin: 0.15);
  }
}
