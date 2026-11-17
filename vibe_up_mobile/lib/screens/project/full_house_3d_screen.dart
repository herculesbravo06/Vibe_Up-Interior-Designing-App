import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/plan_save_screen.dart';

class FullHouse3DScreen extends StatefulWidget {
  final List<Map<String, dynamic>> rooms;

  const FullHouse3DScreen({super.key, required this.rooms});

  @override
  State<FullHouse3DScreen> createState() => _FullHouse3DScreenState();
}

class _FullHouse3DScreenState extends State<FullHouse3DScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _glbBase64;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E1E2A))
      ..addJavaScriptChannel(
        'Print',
        onMessageReceived: (message) async {
          try {
            final data = jsonDecode(message.message);
            if (data['event'] == 'ready') {
              _injectHouseLayout();
            } else if (data['event'] == 'exportGLB') {
              await _handleGlbExport(data['data']);
            } else if (data['event'] == 'saveGLB') {
              _glbBase64 = data['data'];
              _navigateToSave();
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadFlutterAsset('assets/3d_house_viewer.html');
  }

  void _injectHouseLayout() {
    final jsonData = jsonEncode(jsonEncode(widget.rooms));
    _controller.runJavaScript('window.buildHouse($jsonData);');
  }

  Future<void> _handleGlbExport(String base64Data) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final bytes = base64Decode(base64Data);
      final path = '${tempDir.path}/vibeup_whole_house.glb';
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(path, mimeType: 'model/gltf-binary')],
        text: 'My Custom VibeUp Whole House 3D Model',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerExport() {
    setState(() => _isLoading = true);
    _controller.runJavaScript('window.exportGLB();');
  }

  List<Map<String, dynamic>> get _allItems {
    final List<Map<String, dynamic>> all = [];
    for (final room in widget.rooms) {
      final items = (room['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      all.addAll(items);
    }
    return all;
  }

  void _navigateToSave() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanSaveScreen(
          placedItems: _allItems,
          glbBase64: _glbBase64,
        ),
      ),
    );
  }

  void _onSaveDesign() {
    // Try to capture GLB first, then navigate
    _controller.runJavaScript('''
      import('three/addons/exporters/GLTFExporter.js').then(module => {
        const GLTFExporter = module.GLTFExporter;
        const exporter = new GLTFExporter();
        const exportGroup = new THREE.Group();
        scene.traverse(child => { 
          if (child.isMesh && !child.name.includes('grid') && !child.name.includes('Helper')) {
            exportGroup.add(child.clone()); 
          }
        });
        exporter.parse(
          exportGroup,
          (result) => {
            const blob = new Blob([result], { type: 'model/gltf-binary' });
            const reader = new FileReader();
            reader.onload = () => {
              Print.postMessage(JSON.stringify({ event: 'saveGLB', data: reader.result.split(',')[1] }));
            };
            reader.readAsDataURL(blob);
          },
          (error) => { Print.postMessage(JSON.stringify({ event: 'saveGLB', data: '' })); },
          { binary: true }
        );
      }).catch(() => { Print.postMessage(JSON.stringify({ event: 'saveGLB', data: '' })); });
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Masterpiece Visualization',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, letterSpacing: 0.5),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryAccent, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              onPressed: _isLoading ? null : _triggerExport,
              icon: const Icon(Icons.ios_share_rounded, color: AppTheme.primaryAccent, size: 20),
              tooltip: 'Export 3D Asset',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 3),
                  const SizedBox(height: 20),
                  Text(
                    'Constructing 3D Model...',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          
          // Floating Premium Control Bar
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _onSaveDesign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_as_rounded, color: Colors.black, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Finalize Design',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fade().slideY(begin: 0.3),
          ),
        ],
      ),
    );
  }
}
