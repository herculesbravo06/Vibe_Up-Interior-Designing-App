import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'camera_screen.dart';
import 'ai_design_results_screen.dart';

class AiDesignSetupScreen extends StatefulWidget {
  final String? projectId;
  const AiDesignSetupScreen({super.key, this.projectId});

  @override
  State<AiDesignSetupScreen> createState() => _AiDesignSetupScreenState();
}

class _AiDesignSetupScreenState extends State<AiDesignSetupScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedStyle;
  String? _imagePath;
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _styles = [
    {'name': 'Modern', 'icon': Icons.weekend_outlined},
    {'name': 'Minimalist', 'icon': Icons.layers_clear_outlined},
    {'name': 'Scandinavian', 'icon': Icons.ac_unit_outlined},
    {'name': 'Japandi', 'icon': Icons.spa_outlined},
    {'name': 'Industrial', 'icon': Icons.factory_outlined},
    {'name': 'Luxury', 'icon': Icons.diamond_outlined},
    {'name': 'Contemporary', 'icon': Icons.auto_awesome_mosaic_outlined},
    {'name': 'Tech Office', 'icon': Icons.computer_outlined},
    {'name': 'Classic', 'icon': Icons.account_balance_outlined},
    {'name': 'Bohemian', 'icon': Icons.nature_people_outlined},
  ];

  Future<void> _pickGalleryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  Future<void> _captureRoomPhoto() async {
    final resultPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (resultPath != null) {
      setState(() => _imagePath = resultPath);
    }
  }

  void _generateDesign() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty && _selectedStyle == null && _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description, select a style, or upload an image.')),
      );
      return;
    }

    // Navigate to the results/loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiDesignResultsScreen(
          prompt: prompt,
          style: _selectedStyle,
          imagePath: _imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('AI Designer', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Create Your Vision',
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ).animate().fade().slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'Describe your dream space or upload a photo to let our AI generate bespoke luxury concepts.',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
              ).animate().fade(delay: 100.ms),
              const SizedBox(height: 40),

              // 1. Text Prompt
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                     child: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryAccent, size: 20),
                   ),
                   const SizedBox(width: 12),
                   Text(
                     'Describe your dream room',
                     style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                   ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptController,
                maxLines: 3,
                style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. "A minimalist living room with gold accents and velvet textures"',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.primaryAccent, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceDark.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 40),

              // 2. Style Selection
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                     child: const Icon(Icons.style_rounded, color: AppTheme.primaryAccent, size: 20),
                   ),
                   const SizedBox(width: 12),
                   Text(
                     'Select a Signature Style',
                     style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                   ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _styles.length,
                itemBuilder: (context, index) {
                  final style = _styles[index];
                  final isSelected = _selectedStyle == style['name'];
                  return InkWell(
                    onTap: () => setState(() => _selectedStyle = style['name']),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.goldGradient : AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryAccent : Colors.white.withOpacity(0.06),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            style['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.black : AppTheme.primaryAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              style['name'] as String,
                              style: GoogleFonts.inter(
                                color: isSelected ? Colors.black : AppTheme.textPrimary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: (200 + index * 40).ms).scale(begin: const Offset(0.98, 0.98));
                },
              ),
              const SizedBox(height: 40),

              // 3. Room Photo (Optional)
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                     child: const Icon(Icons.camera_rounded, color: AppTheme.primaryAccent, size: 20),
                   ),
                   const SizedBox(width: 12),
                   Text(
                     'Visual Context (Optional)',
                     style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                   ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a photo of your existing room for AI analysis and structural context.',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              
              if (_imagePath != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_imagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _imagePath = null),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                  Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: AppTheme.glassDecoration,
                        child: OutlinedButton.icon(
                          onPressed: _captureRoomPhoto,
                          icon: const Icon(Icons.camera_alt_rounded, size: 18),
                          label: Text('Capture', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            foregroundColor: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: AppTheme.glassDecoration,
                        child: OutlinedButton.icon(
                          onPressed: _pickGalleryImage,
                          icon: const Icon(Icons.image_rounded, size: 18),
                          label: Text('Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            foregroundColor: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 64),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateDesign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: AppTheme.primaryAccent.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded),
                      const SizedBox(width: 12),
                      Text(
                        'Generate Bespoke Design',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
