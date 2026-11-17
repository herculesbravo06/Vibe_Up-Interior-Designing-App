import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/services/ai_design_service.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiDesignResultsScreen extends StatefulWidget {
  final String prompt;
  final String? style;
  final String? imagePath;

  const AiDesignResultsScreen({
    super.key,
    required this.prompt,
    this.style,
    this.imagePath,
  });

  @override
  State<AiDesignResultsScreen> createState() => _AiDesignResultsScreenState();
}

class _AiDesignResultsScreenState extends State<AiDesignResultsScreen> {
  final AiDesignService _aiService = AiDesignService();
  
  bool _isLoading = true;
  String _statusMessage = 'Analyzing your request...';
  
  Map<String, dynamic>? _designPlan;
  List<String> _imageUrls = [];
  List<String> _fallbackUrls = [];

  // Dynamic User ID
  String currentUserId = 'U_00001';

  @override
  void initState() {
    super.initState();
    _loadUserAndProcess();
  }

  Future<void> _loadUserAndProcess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          currentUserId = prefs.getString('user_id') ?? 'U_00001';
        });
      }
    } catch (e) {
      debugPrint("Error loading prefs: $e");
    }
    _processDesign();
  }

  Future<void> _processDesign() async {
    try {
      // 1. Prepare image bytes
      Uint8List? imageBytes;
      String? uploadedImageUrl;
      List<dynamic> backendLayoutTips = [];

      if (widget.imagePath != null) {
        setState(() => _statusMessage = 'Uploading room photo...');
        final file = File(widget.imagePath!);
        imageBytes = await file.readAsBytes();

        // UPLOAD TO BACKEND
        try {
          var uri = Uri.parse('${ApiService.baseUrl}api_v2/upload_room.php');
          var request = http.MultipartRequest('POST', uri);
          request.fields['user_id'] = currentUserId;
          request.files.add(await http.MultipartFile.fromPath('room_image', file.path));

          var streamedResponse = await request.send();
          var response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              uploadedImageUrl = data['image_url'];
              backendLayoutTips = data['layout_recommendations'] ?? [];
            }
          }
        } catch (e) {
          print('Error uploading to backend: $e');
        }
      }

      // 2. Ask Gemini for structured JSON
      setState(() => _statusMessage = 'Generating interior design plan...');
      final plan = await _aiService.generateDesignPlan(
        prompt: widget.prompt,
        style: widget.style,
        roomImageBytes: imageBytes,
      );

      if (plan == null) {
        throw Exception('Failed to generate design plan.');
      }
      
      // Inject backend layout tips if Gemini didn't provide enough or we want to merge them
      if (backendLayoutTips.isNotEmpty) {
        List<dynamic> currentLayouts = plan['layout_recommendations'] ?? [];
        for (var tip in backendLayoutTips) {
            currentLayouts.add({
                'title': tip['ai_suggestions'] ?? 'Backend Tip',
                'description': tip['placement_data'] ?? ''
            });
        }
        plan['layout_recommendations'] = currentLayouts;
      }

      final enhancedPrompt = plan['enhanced_prompt'] as String? ?? widget.prompt;

      // 3. Save the Design Request to Backend MySQL
      setState(() => _statusMessage = 'Saving design request to database...');
      String? requestId;
      try {
        final response = await http.post(
          Uri.parse('${ApiService.baseUrl}api_v2/generate_design.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': currentUserId,
            'original_prompt': widget.prompt,
            'enhanced_prompt': enhancedPrompt,
            'selected_style': widget.style ?? 'Custom',
            'uploaded_room_url': uploadedImageUrl // Although generate_design.php doesn't map this currently, it's good practice
          }),
        );
        
        if (response.statusCode == 200) {
          final dbData = jsonDecode(response.body);
          if (dbData['status'] == 'success') {
            requestId = dbData['request_id'];
          }
        }
      } catch (dbError) {
        print("Error saving to DB: $dbError");
      }

      // 4. Generate Images from the enhanced prompt
      setState(() => _statusMessage = 'Rendering 3D room variations...');
      final urls = await _aiService.generateImageUrlsUnified(enhancedPrompt);
      
      // Determine fallbacks based on a combination of original and enhanced prompts
      String fallbackFolder = 'living';
      final combinedPrompt = "${widget.prompt} $enhancedPrompt".toLowerCase();
      
      if (combinedPrompt.contains('bedroom') || combinedPrompt.contains('sleeping') || combinedPrompt.contains('suite') || combinedPrompt.contains('bed')) {
        fallbackFolder = 'bedroom';
      } else if (combinedPrompt.contains('kitchen') || combinedPrompt.contains('cooking') || combinedPrompt.contains('cabinet')) {
        fallbackFolder = 'kitchen';
      } else if (combinedPrompt.contains('bathroom') || combinedPrompt.contains('shower') || combinedPrompt.contains('washroom')) {
        fallbackFolder = 'bathroom';
      } else if (combinedPrompt.contains('office') || combinedPrompt.contains('work') || combinedPrompt.contains('study') || combinedPrompt.contains('desk')) {
        fallbackFolder = 'office';
      }
      
      final Map<String, List<String>> fallbackMap = {
        'bedroom': [
          'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=1024',
          'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=1024',
          'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=1024'
        ],
        'kitchen': [
          'https://images.unsplash.com/photo-1556912173-3bb406ef7e77?w=1024',
          'https://images.unsplash.com/photo-1556909212-d5b604ad9290?w=1024',
          'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=1024'
        ],
        'living': [
          'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1024',
          'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?w=1024',
          'https://images.unsplash.com/photo-1583847268964-b28ce8f31586?w=1024'
        ],
        'bathroom': [
          'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=1024',
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=1024',
          'https://images.unsplash.com/photo-1620626011761-9963d7521576?w=1024'
        ],
        'office': [
          'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=1024',
          'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=1024',
          'https://images.unsplash.com/photo-1504384308090-c89eecec538d?w=1024'
        ],
      };
      final fallbacks = fallbackMap[fallbackFolder]!;

      // 5. Save generated images to Backend
      if (requestId != null) {
        setState(() => _statusMessage = 'Saving variations to database...');
        for (int i = 0; i < urls.length; i++) {
          try {
             await http.post(
              Uri.parse('${ApiService.baseUrl}api_v2/save_generated_image.php'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'request_id': requestId,
                'image_url': urls[i],
                'prompt_used': enhancedPrompt,
                'variation_number': i + 1,
              }),
            );
          } catch (imgDbError) {
            print("Error saving generated image to DB: $imgDbError");
          }
        }
      }

      if (mounted) {
        setState(() {
          _designPlan = plan;
          _imageUrls = urls;
          _fallbackUrls = fallbacks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Generation Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate design. Check your connection or API key.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ).animate().fade(),
              const SizedBox(height: 12),
              Text(
                'This might take a minute.',
                style: TextStyle(color: Colors.grey.shade600),
              )
            ],
          ),
        ),
      );
    }

    if (_designPlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Design Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('Failed to generate design plan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              )
            ],
          ),
        ),
      );
    }

    // Extract JSON lists safely
    final moodboard = (_designPlan!['moodboard_elements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final furniture = (_designPlan!['furniture_suggestions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final layout = (_designPlan!['layout_recommendations'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.style ?? "Custom"} Design'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Image Generator Results ───
            SizedBox(
              height: 350,
              child: PageView.builder(
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: _imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.cardColor,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    Text(
                                      'AI Rendering...',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => CachedNetworkImage(
                              imageUrl: _fallbackUrls[index % _fallbackUrls.length],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, err) => Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Icon(Icons.architecture, color: Colors.grey, size: 48),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Variation ${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fade().slideY(begin: 0.1),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 2. AI Moodboard Generator ───
                  if (moodboard.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined, color: AppTheme.primaryAccent),
                        const SizedBox(width: 8),
                        Text('AI Moodboard', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moodboard.map((tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 13)),
                        backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                        side: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      )).toList(),
                    ).animate().fade(delay: 200.ms),
                    const SizedBox(height: 32),
                  ],

                  // ─── 3. AI Furniture Suggestion ───
                  if (furniture.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.chair_outlined, color: AppTheme.primaryAccent),
                        const SizedBox(width: 8),
                        Text('Furniture & Decor', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...furniture.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    item['type'] ?? 'Item',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  if (item['color'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item['color'],
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['style'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Placement: ${item['placement'] ?? 'Anywhere'}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList().animate().fade(delay: 400.ms).slideX(begin: 0.1),
                    const SizedBox(height: 32),
                  ],

                  // ─── 4. AI Room Layout Generator ───
                  if (layout.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.architecture_outlined, color: AppTheme.primaryAccent),
                        const SizedBox(width: 8),
                        Text('Layout Recommendations', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...layout.map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip['title'] ?? 'Layout Tip',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tip['description'] ?? '',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList().animate().fade(delay: 600.ms),
                    const SizedBox(height: 32),
                  ],
                  
                  // Bottom Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Start New Design', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
