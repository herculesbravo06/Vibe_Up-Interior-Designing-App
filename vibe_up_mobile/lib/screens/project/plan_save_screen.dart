import 'package:vibe_up/theme/app_theme.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/main_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PlanSaveScreen extends StatefulWidget {
  final Uint8List? capturedImage;
  final Uint8List? topViewImage;
  final List<Map<String, dynamic>>? placedItems;
  final List<Map<String, dynamic>>? rooms;
  final String? glbBase64;

  const PlanSaveScreen({
    super.key,
    this.capturedImage,
    this.topViewImage,
    this.placedItems,
    this.rooms,
    this.glbBase64,
  });

  @override
  State<PlanSaveScreen> createState() => _PlanSaveScreenState();
}

class _PlanSaveScreenState extends State<PlanSaveScreen> {
  bool _isSaving = false;
  String? _savedPath;

  double get _totalBudget {
    if (widget.placedItems == null) return 0;
    double total = 0;
    for (final item in widget.placedItems!) {
      total += (item['price'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<void> _saveAsJpeg() async {
    if (widget.capturedImage == null && widget.topViewImage == null) {
      _showSnack('No image data found to save.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final List<XFile> filesToShare = [];

      if (widget.capturedImage != null) {
        final path = '${tempDir.path}/vibeup_design_3d.jpg';
        final file = File(path);
        await file.writeAsBytes(widget.capturedImage!);
        filesToShare.add(XFile(path, mimeType: 'image/jpeg'));
      }

      if (widget.topViewImage != null) {
        final path = '${tempDir.path}/vibeup_design_topview.jpg';
        final file = File(path);
        await file.writeAsBytes(widget.topViewImage!);
        filesToShare.add(XFile(path, mimeType: 'image/jpeg'));
      }

      if (filesToShare.isNotEmpty) {
        // Use share_plus to allow user to save or send
        await Share.shareXFiles(
          filesToShare,
          text: 'My Interior Design from Vibe Up',
        );
        _showSnack('✓ Prepare to save/share your designs');
      }
    } catch (e) {
      _showSnack('Error saving JPEG: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAs3DModel() async {
    if (widget.glbBase64 == null || widget.glbBase64!.isEmpty) {
      _showSnack('3D model data is not available.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/vibeup_design_3d.glb';
      final file = File(path);
      await file.writeAsBytes(base64Decode(widget.glbBase64!));

      await Share.shareXFiles(
        [XFile(path, mimeType: 'model/gltf-binary')],
        text: 'My 3D Interior Design from Vibe Up',
      );
      _showSnack('✓ Prepare to handle your 3D model');
    } catch (e) {
      _showSnack('Error saving 3D model: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAsPdf() async {
    setState(() => _isSaving = true);
    try {
      final pdf = pw.Document();
      final items = widget.placedItems ?? [];

      final topViewImage = widget.topViewImage != null ? pw.MemoryImage(widget.topViewImage!) : null;
      final perspectiveImage = widget.capturedImage != null ? pw.MemoryImage(widget.capturedImage!) : null;

      // ─── PDF Header Helper ───
      pw.Widget buildHeader(String title) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Vibe Up', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFD4AF37))),
                pw.Text(title, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 20),
          ],
        );
      }

      // ─── Page 1: 3D Perspective View ───
      if (perspectiveImage != null) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(35),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildHeader('3D Perspective Design'),
                  pw.Expanded(
                    child: pw.Container(
                      width: double.infinity,
                      decoration: pw.BoxDecoration(
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 10, verticalRadius: 10,
                        child: pw.Image(perspectiveImage, fit: pw.BoxFit.contain),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Note: This is an AI-generated 3D preview of your spatial arrangement.', 
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
                ],
              );
            },
          ),
        );
      }

      // ─── Page 2: Top View (Floor Plan) ───
      if (topViewImage != null) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(35),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildHeader('2D Top View Floor Plan'),
                  pw.Expanded(
                    child: pw.Container(
                      width: double.infinity,
                      decoration: pw.BoxDecoration(
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 10, verticalRadius: 10,
                        child: pw.Image(topViewImage, fit: pw.BoxFit.contain),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('This view provides a precise overview of furniture placement and floor coverage.', 
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                ],
              );
            },
          ),
        );
      }

      // ─── Page 3: Billing Details & Furniture List ───
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(35),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildHeader('Project Billing & Estimates'),
                
                if (widget.rooms != null && widget.rooms!.isNotEmpty)
                  ...widget.rooms!.map((room) {
                    final roomItems = (room['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                    final roomTotal = (room['budget'] as num?)?.toDouble() ?? 0;
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(room['name']?.toUpperCase() ?? 'ROOM SEGMENT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              pw.Text('₹ ${roomTotal.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColor.fromInt(0xFFD4AF37))),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        if (roomItems.isEmpty)
                          pw.Padding(padding: const pw.EdgeInsets.only(left: 20, bottom: 20), child: pw.Text('No items placed.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)))
                        else
                          pw.Table(
                            border: pw.TableBorder.all(color: PdfColors.grey100, width: 0.5),
                            children: [
                              ...roomItems.asMap().entries.map((entry) {
                                final i = entry.key;
                                final item = entry.value;
                                return pw.TableRow(
                                  children: [
                                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${i+1}', style: const pw.TextStyle(fontSize: 9))),
                                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(item['name'] ?? 'Item', style: const pw.TextStyle(fontSize: 9))),
                                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('₹ ${item['price']}', style: const pw.TextStyle(fontSize: 9))),
                                  ],
                                );
                              }),
                            ],
                          ),
                        pw.SizedBox(height: 24),
                      ],
                    );
                  }).toList()
                else if (items.isNotEmpty)
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(0.8),
                      1: const pw.FlexColumnWidth(3.5),
                      2: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFD4AF37)),
                        children: [
                          _tableCell('#', isHeader: true),
                          _tableCell('Equipment / Furniture Name', isHeader: true),
                          _tableCell('Approx. Price (₹)', isHeader: true),
                        ],
                      ),
                      ...items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        final name = item['name'] ?? item['type'] ?? 'Interior Item';
                        final price = (item['price'] as num?)?.toDouble() ?? 0;
                        return pw.TableRow(
                          decoration: i % 2 == 0 ? null : const pw.BoxDecoration(color: PdfColors.grey100),
                          children: [
                            _tableCell('${i + 1}'),
                            _tableCell(name),
                            _tableCell(price.toStringAsFixed(2)),
                          ],
                        );
                      }),
                    ],
                  )
                else
                  pw.Center(child: pw.Text('No items placed in this design.')),
                
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL PROJECT VALUATION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('₹ ${_totalBudget.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFD4AF37))),
                  ],
                ),
                
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey200),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Important Disclaimer:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'This document serves as an approximate cost estimation based on standard catalogue prices. Actual prices may vary depending on material selection, delivery charges, and professional installation fees.',
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ),
              ]
            );
          }
        )
      );

      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/vibeup_design_report.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/pdf')],
        subject: 'Vibe Up Design Report',
      );

      _showSnack('✓ Prepare to share your design PDF');
    } catch (e) {
      _showSnack('Error saving PDF: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.black : PdfColors.grey800,
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        title: Text('Design Portfolio', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Preview Thumbnail
              if (widget.capturedImage != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3), width: 1.5),
                    image: DecorationImage(
                      image: MemoryImage(widget.capturedImage!),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15))
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                      ),
                    ),
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.check_circle_rounded, color: AppTheme.primaryAccent, size: 32),
                  ),
                ).animate().fade().scale(duration: 600.ms, curve: Curves.easeOutBack)
              else
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Center(
                    child: Icon(Icons.auto_awesome_rounded, size: 48, color: AppTheme.primaryAccent.withOpacity(0.5)),
                  ),
                ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

              const SizedBox(height: 32),
              Text(
                'Creation Finalized',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ).animate().fade().slideY(begin: 0.2),
              const SizedBox(height: 12),
              Text(
                'Your luxury interior vision is ready. Export your concept as a high-fidelity report or a 3D assets.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ).animate().fade(delay: 200.ms),

              const SizedBox(height: 48),

              if (_isSaving)
                const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent))
              else
                Column(
                  children: [
                    _buildLuxuryExportCard(
                      title: 'Professional Dossier',
                      subtitle: 'Comprehensive PDF report with 2D/3D layouts',
                      icon: Icons.picture_as_pdf_rounded,
                      delay: 300,
                      onTap: _saveAsPdf,
                    ),
                    const SizedBox(height: 20),
                    _buildLuxuryExportCard(
                      title: 'Gallery Composition',
                      subtitle: 'Premium high-resolution perspective render',
                      icon: Icons.auto_awesome_motion_rounded,
                      delay: 400,
                      onTap: _saveAsJpeg,
                    ),
                    const SizedBox(height: 20),
                    _buildLuxuryExportCard(
                      title: 'Digital Asset (GLB)',
                      subtitle: 'Universal 3D format for spatial viewing',
                      icon: Icons.unfold_more_rounded,
                      delay: 500,
                      onTap: _saveAs3DModel,
                    ),
                  ],
                ),

              const SizedBox(height: 48),

              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () {
                    // Navigate back to the relevant project screen or home
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainNavigation()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    foregroundColor: AppTheme.textPrimary,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text('RETURN TO BLUEPRINT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13)),
                ),
              ).animate().fade(delay: 600.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryExportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int delay,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: AppTheme.primaryAccent),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDim, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textDim),
          ],
        ),
      ).animate().fade(delay: delay.ms).slideX(begin: 0.1),
    );
  }
}
