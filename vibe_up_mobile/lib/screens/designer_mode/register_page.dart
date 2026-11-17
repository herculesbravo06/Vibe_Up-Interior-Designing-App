import 'package:flutter/material.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibe_up/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool agree = false;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();

  /// REGISTER API V2
  Future registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if(!agree){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept Terms of Service")),
      );
      return;
    }

    var url = Uri.parse("http://192.168.1.8/scratch/admin_panel/api_v2/register.php");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "phone_number": phoneController.text,
        "role": "designer"
      }),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen(isDesigner: true)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Registration failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 20),

              Text(
                "Create Account",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Start your professional workspace",
                style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 16),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                    buildInput(
                        "Full Name",
                        "Alex Thompson",
                        Icons.person_rounded,
                        false,
                        nameController),

                    const SizedBox(height: 16),

                    buildInput(
                        "Email Address",
                        "alex@studio.com",
                        Icons.mail_rounded,
                        false,
                        emailController),

                    const SizedBox(height: 16),

                    buildInput(
                        "Username",
                        "alex123",
                        Icons.alternate_email_rounded,
                        false,
                        usernameController),

                    const SizedBox(height: 16),

                    buildInput(
                        "Phone",
                        "9876543210",
                        Icons.phone_rounded,
                        false,
                        phoneController),

                    const SizedBox(height: 16),

                    /// DOB
                    buildInput(
                        "Date of Birth",
                        "YYYY-MM-DD",
                        Icons.calendar_month_rounded,
                        false,
                        dobController),

                    const SizedBox(height: 16),

                    buildInput(
                        "Create Password",
                        "••••••••",
                        Icons.lock_rounded,
                        true,
                        passwordController),

                    const SizedBox(height: 15),

                    /// TERMS
                    Row(
                      children: [

                        Checkbox(
                          value: agree,
                          activeColor: AppTheme.primaryAccent,
                          checkColor: Colors.white,
                          side: BorderSide(color: AppTheme.textDim),
                          onChanged: (value){
                            setState(() {
                              agree = value!;
                            });
                          },
                        ),

                        Expanded(
                          child: Text(
                            "I agree to the Terms of Service",
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// CREATE ACCOUNT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryAccent.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          onPressed: registerUser,

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Create Account",
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          "Already have an account?",
                          style: GoogleFonts.dmSans(color: AppTheme.textDim),
                        ),

                        const SizedBox(width: 6),

                        GestureDetector(
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context)=> const LoginScreen(isDesigner: true),
                              ),
                            );
                          },
                          child: Text(
                            "Login here",
                            style: GoogleFonts.dmSans(
                              color: AppTheme.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInput(
      String label,
      String hint,
      IconData icon,
      bool obscure,
      TextEditingController controller) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.textDim),
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: AppTheme.textDim.withOpacity(0.5)),
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.5)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (label.toLowerCase().contains('email') && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            if (label.toLowerCase().contains('password') && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
