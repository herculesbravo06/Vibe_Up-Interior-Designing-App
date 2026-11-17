import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/screens/auth/reset_password_screen.dart';
import 'package:vibe_up/theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}api/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'verify_otp',
          'email': widget.email,
          'otp': _otpController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (mounted) {
        setState(() => _isVerifying = false);
        
        if (data['status'] == 'success') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: widget.email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Invalid OTP. Please check your email.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error. Please try again.')),
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
                      color: AppTheme.secondaryAccent.withOpacity(0.1),
                      border: Border.all(color: AppTheme.secondaryAccent.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.mark_email_read, size: 40, color: AppTheme.secondaryAccent),
                  ).animate().fade().scale(),

                  const SizedBox(height: 28),

                  Text(
                    'Enter OTP',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fade().slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  Text(
                    'We sent a 4-digit code to:\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.textDim,
                      height: 1.5,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 44),

                  TextFormField(
                    controller: _otpController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      letterSpacing: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '0000',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 28,
                        letterSpacing: 12,
                        color: AppTheme.textDim.withOpacity(0.4),
                      ),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 4) {
                        return 'Please enter the 4-digit OTP';
                      }
                      return null;
                    },
                  ).animate().fade(delay: 400.ms).slideX(begin: 0.1),

                  const SizedBox(height: 36),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.primaryAccent.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isVerifying 
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Verify & Continue', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700)),
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
