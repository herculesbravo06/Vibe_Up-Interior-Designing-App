import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/auth/auth_options_screen.dart';
import 'package:vibe_up/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const AuthOptionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A16), Color(0xFF0F0F1A), Color(0xFF1A0F1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background ambient glow
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryAccent.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
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

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with glow ring
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryAccent.withOpacity(0.18),
                          AppTheme.primaryAccent.withOpacity(0.04),
                          Colors.transparent,
                        ],
                        radius: 1.3,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryAccent.withOpacity(0.25),
                            width: 1.5,
                          ),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF252545), Color(0xFF1A1A30)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: Image.asset(
                            'assets/logo_premium.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.auto_awesome,
                              size: 44,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fade(duration: 700.ms)
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.0, 1.0),
                        duration: 900.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 44),

                  // App name with coral gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF9494), Color(0xFFFF6B6B), Color(0xFFFFB347)],
                    ).createShader(bounds),
                    child: Text(
                      'VIBEUP',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .fade(delay: 700.ms, duration: 700.ms)
                      .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 700.ms, curve: Curves.easeOut),

                  const SizedBox(height: 14),

                  // Tagline
                  Text(
                    'Design Your Dream Space',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3.5,
                      color: AppTheme.textDim,
                    ),
                  ).animate().fade(delay: 1400.ms, duration: 700.ms),

                  const SizedBox(height: 72),

                  // Minimal loading dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryAccent.withOpacity(0.5),
                        ),
                      )
                          .animate(delay: Duration(milliseconds: 1800 + i * 150))
                          .fade(duration: 400.ms)
                          .then()
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.6, 0.6),
                            end: const Offset(1.2, 1.2),
                            duration: Duration(milliseconds: 700 + i * 100),
                            curve: Curves.easeInOut,
                          );
                    }),
                  ).animate().fade(delay: 1800.ms, duration: 500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
