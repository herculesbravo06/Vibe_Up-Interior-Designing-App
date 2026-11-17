import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  String? _userId;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? 'User';
      _emailController.text = prefs.getString('user_email') ?? '';
      _usernameController.text = _nameController.text.split(' ').first;
      _userId = prefs.getString('user_id');
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryAccent.withOpacity(0.7),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A16), Color(0xFF0F0F1A), Color(0xFF12121E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              title: Text(
                'Profile',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppTheme.textPrimary,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: _isEditing
                        ? AppTheme.primaryAccent.withOpacity(0.12)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEditing
                          ? AppTheme.primaryAccent.withOpacity(0.3)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                      size: 20,
                      color: _isEditing ? AppTheme.primaryAccent : AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      if (_isEditing) {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully!')),
                          );
                        }
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ─── Avatar with gradient ring ───
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryAccent,
                                    AppTheme.secondaryAccent.withOpacity(0.6),
                                    AppTheme.primaryAccent.withOpacity(0.4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryAccent.withOpacity(0.2),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: AppTheme.cardColor,
                                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=68'),
                              ),
                            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                            if (_isEditing)
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.background, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryAccent.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                ).animate().scale(delay: 200.ms),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        _nameController.text,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Email
                      Text(
                        _emailController.text,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppTheme.textDim,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.15)),
                        ),
                        child: Text(
                          'Interior Enthusiast',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryAccent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ─── Section Header ───
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Personal Information',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Fields
                      _buildField('Username', _usernameController, Icons.alternate_email_rounded, _isEditing)
                          .animate().fade(delay: 100.ms).slideY(begin: 0.08),
                      const SizedBox(height: 12),
                      _buildField('Full Name', _nameController, Icons.person_outline_rounded, _isEditing)
                          .animate().fade(delay: 180.ms).slideY(begin: 0.08),
                      const SizedBox(height: 12),
                      _buildField('Email', _emailController, Icons.email_outlined, false)
                          .animate().fade(delay: 260.ms).slideY(begin: 0.08),
                      const SizedBox(height: 12),
                      _buildReadOnlyField('Date of Birth', '1995-05-12', Icons.cake_outlined)
                          .animate().fade(delay: 340.ms).slideY(begin: 0.08),
                      const SizedBox(height: 12),
                      _buildReadOnlyField('Password', '••••••••', Icons.lock_outline_rounded)
                          .animate().fade(delay: 420.ms).slideY(begin: 0.08),

                      const SizedBox(height: 32),

                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isEditing = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile Updated!')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Save Changes',
                              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ).animate().fade(delay: 500.ms),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, bool enabled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? AppTheme.primaryAccent.withOpacity(0.25)
              : Colors.white.withOpacity(0.05),
          width: enabled ? 1.5 : 1,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            color: enabled ? AppTheme.primaryAccent.withOpacity(0.8) : AppTheme.textDim,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? AppTheme.primaryAccent.withOpacity(0.7) : AppTheme.textDim,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textDim, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppTheme.textDim,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
