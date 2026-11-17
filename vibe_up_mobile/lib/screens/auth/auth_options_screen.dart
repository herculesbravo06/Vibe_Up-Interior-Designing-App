import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';
import 'package:vibe_up/screens/auth/signup_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

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
        child: Stack(
          children: [
            // Ambient glow top-right
            Positioned(
              top: -40,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryAccent.withOpacity(0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Ambient glow bottom-left
            Positioned(
              bottom: 80,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondaryAccent.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),

                    // Logo with ring
                    Center(
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryAccent.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.primaryAccent.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/logo_premium.png',
                            width: 68,
                            height: 68,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.auto_awesome,
                              size: 44,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ),
                      ),
                    ).animate()
                     .fade(duration: 600.ms)
                     .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 32),

                    // App name gradient
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Color(0xFFFF9494), Color(0xFFFF6B6B), Color(0xFFFFB347)],
                      ).createShader(b),
                      child: Text(
                        'VIBEUP',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 6,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fade(delay: 300.ms, duration: 600.ms),

                    const SizedBox(height: 12),

                    Text(
                      'Design Your Dream Space',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textDim,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fade(delay: 500.ms, duration: 600.ms),

                    const Spacer(flex: 2),

                    // Feature mini pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPill(Icons.auto_awesome_outlined, 'AI Design'),
                        const SizedBox(width: 12),
                        _buildPill(Icons.view_in_ar_outlined, '3D Tours'),
                        const SizedBox(width: 12),
                        _buildPill(Icons.palette_outlined, 'Catalog'),
                      ],
                    ).animate().fade(delay: 650.ms, duration: 500.ms),

                    const SizedBox(height: 40),

                    // Create Account button (coral primary)
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 750.ms, duration: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 14),

                    // Log in button (outlined glass)
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen(isDesigner: false)),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: BorderSide(color: Colors.white.withOpacity(0.18), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Log In',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 850.ms, duration: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 20),

                    // Designer login link
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen(isDesigner: true)),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: 'Are you a designer?  ',
                            style: GoogleFonts.dmSans(
                              color: AppTheme.textDim,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Log In',
                                style: GoogleFonts.dmSans(
                                  color: AppTheme.primaryAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 950.ms, duration: 400.ms),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.primaryAccent),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
