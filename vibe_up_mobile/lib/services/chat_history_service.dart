import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryService {
  final String chatKey;

  ChatHistoryService({this.chatKey = 'vibe_up_chat_history'});

  // Save the chat history list
  Future<void> saveChatHistory(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(messages);
    await prefs.setString(chatKey, encodedData);
  }

  // Load the chat history list
  Future<List<Map<String, dynamic>>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(chatKey);
    
    if (encodedData != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(encodedData);
        return decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        print('Error parsing chat history: $e');
        return [];
      }
    }
    return [];
  }

  // Clear chat history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chatKey);
  }
}
