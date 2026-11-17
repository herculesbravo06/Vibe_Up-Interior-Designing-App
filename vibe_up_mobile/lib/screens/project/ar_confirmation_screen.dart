import 'package:vibe_up/theme/app_theme.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/project/plan_save_screen.dart';
import 'package:vibe_up/screens/project/assistance_selection_screen.dart';
import 'package:vibe_up/screens/old_projects/old_projects_list_screen.dart';
import 'package:vibe_up/screens/main_navigation.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class ArConfirmationScreen extends StatefulWidget {
  final String source;
  final String? projectId;
  final String? topViewBase64;
  final String? view3DBase64;
  final List<Map<String, dynamic>>? placedItems;
  final String? sceneData;
  final String? glbBase64;
  final bool isFloorPlanMode;
  final String? roomName;

  const ArConfirmationScreen({
    super.key,
    required this.source,
    this.projectId,
    this.topViewBase64,
    this.view3DBase64,
    this.placedItems,
    this.sceneData,
    this.glbBase64,
    this.isFloorPlanMode = false,
    this.roomName,
  });

  @override
  State<ArConfirmationScreen> createState() => _ArConfirmationScreenState();
}

class _ArConfirmationScreenState extends State<ArConfirmationScreen> {
  bool _showTopView = false;
  bool _isExporting = false;
  bool _isFinalizing = false;

  Uint8List? _decode64Image(String? base64Url) {
    if (base64Url == null || !base64Url.contains(',')) return null;
    try {
      return base64Decode(base64Url.split(',').last);
    } catch (_) {
      return null;
    }
  }

  double get _totalBudget {
    if (widget.placedItems == null) return 0;
    double total = 0;
    for (final item in widget.placedItems!) {
      total += (item['price'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<void> _exportAsJpeg() async {
    setState(() => _isExporting = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final List<XFile> files = [];
      final bytes3D = _decode64Image(widget.view3DBase64);
      final bytesTop = _decode64Image(widget.topViewBase64);
      
      if (bytes3D != null) {
        final path = '${tempDir.path}/vibeup_3d_view.jpg';
        await File(path).writeAsBytes(bytes3D);
        files.add(XFile(path, mimeType: 'image/jpeg'));
      }
      if (bytesTop != null) {
        final path = '${tempDir.path}/vibeup_top_view.jpg';
        await File(path).writeAsBytes(bytesTop);
        files.add(XFile(path, mimeType: 'image/jpeg'));
      }
      if (files.isNotEmpty) {
        await Share.shareXFiles(files, text: 'My Interior Design from Vibe Up');
      } else {
        _showSnack('No images available to export');
      }
    } catch (e) {
      _showSnack('Export failed: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAs3DModel() async {
    if (widget.glbBase64 == null || widget.glbBase64!.isEmpty) {
      _showSnack('3D model not available');
      return;
    }
    setState(() => _isExporting = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final bytes = base64Decode(widget.glbBase64!);
      final path = '${tempDir.path}/vibeup_design.glb';
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(path, mimeType: 'model/gltf-binary')],
        text: 'My 3D Interior Design from Vibe Up - Open in any 3D viewer app',
      );
    } catch (e) {
      _showSnack('3D export failed: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.redAccent : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topViewBytes = _decode64Image(widget.topViewBase64);
    final view3DBytes = _decode64Image(widget.view3DBase64);
    final items = widget.placedItems ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.roomName != null ? 'Review: ${widget.roomName}' : 'Spatial Review',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // ─── 3D / Top View Toggle (Luxury Design) ───
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!_showTopView && view3DBytes != null)
                      Image.memory(view3DBytes, fit: BoxFit.cover).animate().fadeIn()
                    else if (_showTopView && topViewBytes != null)
                      Image.memory(topViewBytes, fit: BoxFit.contain).animate().fadeIn()
                    else
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.blur_on_rounded, size: 64, color: AppTheme.primaryAccent),
                            const SizedBox(height: 16),
                            Text('Preparing Visualization...', style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 13)),
                          ],
                        ),
                      ),

                    // Luxury View toggle
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _viewToggleButton('3D PERSPECTIVE', !_showTopView, () => setState(() => _showTopView = false)),
                              const SizedBox(width: 4),
                              _viewToggleButton('FLOOR PLAN', _showTopView, () => setState(() => _showTopView = true)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Label
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryAccent, size: 12),
                            const SizedBox(width: 8),
                            Text(
                              _showTopView ? '2D BLUEPRINT' : 'LUXE 3D RENDER',
                              style: GoogleFonts.inter(color: AppTheme.primaryAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05),

          // ─── Budget Details ───
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, -10))
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Investment Estimate', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                          child: Text('${items.length} PIECES', style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('Artisan atelier is empty', style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 16),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final name = item['name'] ?? item['type'] ?? 'Interior Asset';
                          final price = (item['price'] as num?)?.toDouble() ?? 0;
                          return Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(color: AppTheme.primaryAccent, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500))),
                              Text('₹ ${price.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            ],
                          );
                        },
                      ),

                    const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Total', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      Text(
                        '₹ ${_totalBudget.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ─── Luxury Export Controls ───
                  Row(
                    children: [
                      _buildMiniAction(Icons.image_outlined, 'JPEG', _exportAsJpeg),
                      const SizedBox(width: 12),
                      _buildMiniAction(Icons.picture_as_pdf_outlined, 'REPORT', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PlanSaveScreen(
                          capturedImage: _decode64Image(widget.view3DBase64),
                          topViewImage: _decode64Image(widget.topViewBase64),
                          placedItems: widget.placedItems,
                        )));
                      }),
                      const SizedBox(width: 12),
                      _buildMiniAction(Icons.view_in_ar_rounded, 'MODEL', _exportAs3DModel),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Primary Call to Action ───
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isFinalizing ? null : () async {
                        setState(() => _isFinalizing = true);
                        try {
                          // Save project to database
                          Map<String, dynamic> result;
                          if (widget.projectId != null) {
                            result = await ApiService.updateProject({
                              'project_id': widget.projectId,
                              'scene_data': widget.sceneData,
                              'budget': _totalBudget,
                              'status': 'completed',
                            });
                          } else {
                            // Create new project if no ID exists
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getString('user_id') ?? '';
                            result = await ApiService.createProject({
                              'user_id': userId,
                              'name': widget.roomName ?? 'DIY Design',
                              'scene_data': widget.sceneData,
                              'budget': _totalBudget,
                              'status': 'completed',
                              'source': 'DIY',
                            });
                          }

                          if (!mounted) return;

                          if (result['status'] == 'error') {
                            if (mounted) _showSnack('Save failed: ${result['message']}', isError: true);
                            setState(() => _isFinalizing = false);
                            return;
                          }

                          if (!mounted) return;

                          _showSnack('Design saved successfully!');

                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          Navigator.pushAndRemoveUntil(
                            context, 
                            MaterialPageRoute(builder: (_) => const MainNavigation()),
                            (route) => false,
                          );
                        } catch (e) {
                          if (mounted) _showSnack('Save failed: $e');
                        } finally {
                          if (mounted) setState(() => _isFinalizing = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: _isFinalizing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                ),
                                const SizedBox(width: 12),
                                Text('SAVING...', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13)),
                              ],
                            )
                          : Text(
                              widget.isFloorPlanMode ? 'SAVE & RETURN TO FLOOR PLAN' : 'CONFIRM & FINALIZE DESIGN',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13),
                            ),
                    ),
                  ),
                ],
              ),
             ),
            ),
          ).animate().slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildMiniAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: _isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryAccent),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textDim, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? Colors.black : AppTheme.textDim,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
