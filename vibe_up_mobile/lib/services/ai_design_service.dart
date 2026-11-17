import 'package:vibe_up/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiDesignService {
  AiDesignService();

  /// 1. Unified Design Plan from Node.js
  Future<Map<String, dynamic>?> generateDesignPlan({
    required String prompt,
    String? style,
    dynamic? roomImageBytes, // Kept for signature compatibility
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'U_00001';
      
      final fullPrompt = style != null ? "$prompt (Style: $style)" : prompt;
      
      final result = await ApiService.askAiNode(
        message: fullPrompt,
        userId: userId,
        vastu: true,
      );

      if (result['status'] == 'success') {
        // Adapt response to expected internal structure
        return {
          'enhanced_prompt': result['response'],
          'moodboard_elements': ['Luxury', 'Vastu Optimized', 'Modern'],
          'furniture_suggestions': [],
          'layout_recommendations': []
        };
      }
      return null;
    } catch (e) {
      print('AI Design Service Backend Error: $e');
      return null;
    }
  }

  /// 2. Unified Image Generation from Node.js (Stability AI)
  Future<List<String>> generateImageUrlsUnified(String prompt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'U_00001';
      
      final result = await ApiService.generateAiImageNode(
        prompt: prompt,
        userId: userId,
      );

      if (result['status'] == 'success' && result['data'] is List) {
        return List<String>.from(result['data']);
      }
      return [];
    } catch (e) {
      print('AI Image Generation error: $e');
      return [];
    }
  }

  // Backwards compatibility for the existing UI call
  List<String> generateImageUrls(String enhancedPrompt, {int variations = 3}) {
    // This is now handled asynchronously in results screen, but we return empty here 
    // to avoid breakage during the transition.
    return [];
  }
}
