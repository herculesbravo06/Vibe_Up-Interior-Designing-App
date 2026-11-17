import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/main_navigation.dart';
import 'package:vibe_up/screens/designer_mode/designer_dashboard.dart';
import 'package:vibe_up/screens/auth/auth_decision_screen.dart';
import 'package:vibe_up/screens/auth/forgot_password_screen.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthDecisionScreen()),
        (route) => false,
      );
    }
  }
}

class LoginScreen extends StatefulWidget {
  final bool isDesigner;
  const LoginScreen({super.key, required this.isDesigner});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}api_v2/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'isDesigner': widget.isDesigner,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      setState(() => _isLoading = false);

      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        if (data['user']['designer_id'] != null && data['user']['designer_id'] is String) {
          await prefs.setString('designer_id', data['user']['designer_id']);
        }
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('user_name', data['user']['full_name'] ?? 'User');
        await prefs.setString('user_email', data['user']['email'] ?? '');
        await prefs.setString('user_role', data['user']['role'] ?? '');

        if (mounted) {
          if (widget.isDesigner) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DesignerDashboard()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Connection error. Please try again later.';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please check your internet or server IP.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                        ),
                      ),
                    ).animate().fade(duration: 300.ms),

                    const SizedBox(height: 36),

                    // Title
                    Text(
                      widget.isDesigner ? 'Designer Login' : 'Welcome Back',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ).animate().fade(duration: 400.ms).slideX(begin: -0.1),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue designing',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppTheme.textDim,
                      ),
                    ).animate().fade(delay: 200.ms, duration: 400.ms),

                    const SizedBox(height: 48),

                    // Email Field
                    _buildLabel('Email Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'your@email.com',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textDim, size: 20),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 22),

                    // Password Field
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textDim, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppTheme.textDim,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.dmSans(
                            color: AppTheme.primaryAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 500.ms),

                    const SizedBox(height: 36),

                    // Login Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.primaryAccent.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              'Sign In',
                              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                      ),
                    ).animate().fade(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
