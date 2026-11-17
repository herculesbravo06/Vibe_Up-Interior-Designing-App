import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vibe_up/theme/app_theme.dart';

class PanoramaTourScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const PanoramaTourScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<PanoramaTourScreen> createState() => _PanoramaTourScreenState();
}

class _PanoramaTourScreenState extends State<PanoramaTourScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Force Landscape for the immersive 3D tour
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initWebView();
  }

  @override
  void dispose() {
    // Reset to Portrait when leaving the tour
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        'Print',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data['event'] == 'ready') {
              if (mounted) setState(() => _isLoading = false);
            }
          } catch (e) {
            // ignore
          }
        },
      );

    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    setState(() => _isLoading = true);
    try {
      String fileText = await rootBundle.loadString('assets/3d_model_viewer.html');
      
      // Inject the category ID so the procedural engine knows which house to build
      String injectedHtml = fileText.replaceFirst(
        "const categoryId = 'INJECT_CATEGORY_ID_HERE';",
        "const categoryId = '${widget.categoryId}';",
      );
      
      final uri = Uri.dataFromString(
        injectedHtml,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
        base64: true, // prevents truncation by '#' characters in CSS/JS hex colors
      );
      
      await _controller.loadRequest(uri);
      
      // Safety timeout in case JS bridge fails - reduced for snappier performance
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate 3D Model')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // The 3D Engine View
          WebViewWidget(controller: _controller),
          
          // "Return to App" Custom Button Header
          Positioned(
            top: 50,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
              label: Text(
                'Return to App',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          
          // HUD Info
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                '${widget.categoryTitle} - Orbit View',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
          
          // Initial Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryAccent),
                    const SizedBox(height: 20),
                    Text(
                      'Procedurally generating 3D house...',
                      style: GoogleFonts.inter(color: AppTheme.primaryAccent, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Constructing walls, floors, and furniture',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            
          // Instruction overlay (fades out)
          if (!_isLoading)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: 0.0),
                duration: const Duration(seconds: 4),
                curve: Curves.easeInQuint,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pinch, color: AppTheme.primaryAccent),
                        const SizedBox(width: 12),
                        Text(
                          'Pinch to Zoom, Drag to Orbit',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
