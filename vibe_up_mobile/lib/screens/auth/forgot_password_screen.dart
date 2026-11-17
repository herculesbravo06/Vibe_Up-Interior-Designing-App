import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibe_up/screens/auth/otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}api/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'forgot_password_request',
          'email': _emailController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => _isLoading = false);

      if (data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent to email! Please check your inbox.')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Email not found')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error. Please try again later.')),
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
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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

                  const SizedBox(height: 40),

                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryAccent.withOpacity(0.1),
                      border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.lock_reset, size: 40, color: AppTheme.primaryAccent),
                  ).animate().fade().scale(),

                  const SizedBox(height: 28),

                  Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fade().slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  Text(
                    'Enter the email associated with your account and we\'ll send you a 4-digit OTP to reset your password.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.textDim,
                      height: 1.5,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _emailController,
                    style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 15),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'your@email.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textDim, size: 20),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ).animate().fade(delay: 400.ms).slideX(begin: 0.1),

                  const SizedBox(height: 36),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRequestOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.primaryAccent.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Send OTP', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ).animate().fade(delay: 600.ms).scale(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
