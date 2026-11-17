import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/screens/project/floor_plan_processing_screen.dart';

class FloorPlanUploadScreen extends StatefulWidget {
  const FloorPlanUploadScreen({super.key});

  @override
  State<FloorPlanUploadScreen> createState() => _FloorPlanUploadScreenState();
}

class _FloorPlanUploadScreenState extends State<FloorPlanUploadScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (picked != null) {
        // Validate extension
        final ext = picked.path.split('.').last.toLowerCase();
        if (ext != 'jpg' && ext != 'jpeg' && ext != 'png') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Only JPG and PNG files are accepted.')),
            );
          }
          return;
        }
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _submitFloorPlan() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'U10001';

      // 1. Upload floor plan image
      final uploadUri = Uri.parse('${ApiService.baseUrl}api/floor_plans.php');
      final request = http.MultipartRequest('POST', uploadUri);
      request.fields['user_id'] = userId;
      request.files.add(await http.MultipartFile.fromPath('floor_plan', _selectedImage!.path));

      final uploadResponse = await request.send();
      final responseBody = await uploadResponse.stream.bytesToString();
      final result = jsonDecode(responseBody);

      if (result['status'] == 'success') {
        final projectId = result['project_id'];
        final floorPlanUrl = result['floor_plan_url'];

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FloorPlanProcessingScreen(
                projectId: projectId,
                floorPlanUrl: floorPlanUrl,
                floorPlanFile: _selectedImage!,
              ),
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Blueprint Intake', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload Your Blueprint',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate().fade(duration: 400.ms),
              const SizedBox(height: 12),
              Text(
                'Provide a high-resolution JPG or PNG of your architectural floor plan. Our AI artisans will synthesize the geometry automatically.',
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
              ).animate().fade(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 48),

              // Image Preview / Upload Area (Luxury Design)
              Expanded(
                child: GestureDetector(
                  onTap: () => _showPickerOptions(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: _selectedImage != null
                            ? AppTheme.primaryAccent.withOpacity(0.4)
                            : Colors.white.withOpacity(0.06),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 20))
                      ],
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                // Luxury Change image overlay
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: GestureDetector(
                                    onTap: () => _showPickerOptions(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.refresh_rounded, color: AppTheme.primaryAccent, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'NEW SCAN',
                                            style: GoogleFonts.inter(
                                              color: AppTheme.primaryAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Zoom hint
                                Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                                      ),
                                      child: Text(
                                        'PINCH TO ZOOM • TAP TO RESCAN',
                                        style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryAccent.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.1)),
                                ),
                                child: const Icon(
                                  Icons.file_upload_outlined,
                                  size: 40,
                                  color: AppTheme.primaryAccent,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Select Blueprint',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'JPG, PNG • ARCHITECTURAL QUALITY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDim,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: _selectedImage != null && !_isUploading
                      ? _submitFloorPlan
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      const SizedBox(width: 14),
                      Text(
                        _isUploading ? 'SYNTHESIZING...' : 'ANALYZE BLUEPRINT',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Capture Source',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 32),
            _buildPickerItem(
              icon: Icons.photo_library_outlined,
              title: 'Archives',
              subtitle: 'Select from high-quality renders',
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
            _buildPickerItem(
              icon: Icons.camera_enhance_outlined,
              title: 'Live Scan',
              subtitle: 'Capture architecture via camera',
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryAccent),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }
}
