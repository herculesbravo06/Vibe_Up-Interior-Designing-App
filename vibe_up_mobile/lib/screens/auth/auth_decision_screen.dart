import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';
import 'package:vibe_up/screens/auth/signup_screen.dart';

class AuthDecisionScreen extends StatelessWidget {
  const AuthDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A16), Color(0xFF0F0F1A), Color(0xFF1A0F20)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Icon with glow ring
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardColor,
                      border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.maps_home_work_outlined, size: 64, color: AppTheme.primaryAccent),
                  ),
                ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                const SizedBox(height: 44),

                Text(
                  'Welcome to VibeUp',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms).slideY(begin: 0.15),

                const SizedBox(height: 14),

                Text(
                  'Discover and design your dream living space with AI & AR.',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: AppTheme.textDim,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 350.ms),

                const Spacer(),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('New User Sign Up', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ).animate().fade(delay: 500.ms).slideY(begin: 0.2),

                const SizedBox(height: 14),

                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isDesigner: false)));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.18), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    child: Text('Log In as User', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ).animate().fade(delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 14),

                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(isDesigner: true)));
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppTheme.textDim,
                  ),
                  child: Text(
                    'Log In as Designer',
                    style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.primaryAccent, fontWeight: FontWeight.w600),
                  ),
                ).animate().fade(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
