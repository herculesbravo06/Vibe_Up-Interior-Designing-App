import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception('Gemini API Key not found in .env.');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system('''You are Vibe Up, a helpful AI interior design assistant. You help users visualize their dream spaces, choose styles, pick color palettes, and give layout advice based on their descriptions and uploaded photos.
When the user asks to generate, show, or visualize an image or design (e.g., "show me a modern kitchen"), you MUST provide exactly 10 working real-world reference image URLs representing top-tier designs matching their query.

DO NOT generate single AI images anymore. Provide them as a moodboard list using the Unsplash Source API or known real working design image URLs.
Format exactly like this so the app can render the images natively:
1. ![Modern Kitchen 1](https://source.unsplash.com/featured/?modern,kitchen)
2. ![Modern Kitchen 2](https://source.unsplash.com/featured/?kitchen,interior)
...etc.'''),
    );
  }

  void startChat({List<Content>? history}) {
    _chatSession = _model.startChat(history: history);
  }

  Future<String?> sendMessage(String text, {Uint8List? fileBytes, String? mimeType}) async {
    try {
      if (_chatSession == null) {
        startChat();
      }

      final contentParts = <Part>[TextPart(text)];
      if (fileBytes != null && mimeType != null) {
        contentParts.add(DataPart(mimeType, fileBytes));
      }

      final response = await _chatSession!.sendMessage(Content.multi(contentParts));
      return response.text;
    } catch (e) {
      print('Gemini API Error: $e');
      return 'Sorry, I encountered an error while processing your request. Please check your API key and connection.';
    }
  }
}
