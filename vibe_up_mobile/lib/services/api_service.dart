import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 192.168.1.8 for physical device connecting to local network
  static const String baseUrl = 'http://192.168.1.8/scratch/admin_panel/';

  // --- Authentication --- //
  
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/auth.php'),
      body: jsonEncode({
        'action': 'login_user',
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> registerUser(String name, String email, String password, {String? phone, String? dob}) async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/auth.php'),
      body: jsonEncode({
        'action': 'register_user',
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (dob != null) 'dob': dob,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // --- Catalogue --- //
  
  static Future<List<dynamic>> getSyncedCatalogue() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}api/catalogue.php?action=sync')).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      if(data['status'] == 'success') return data['data'];
    } catch (e) {
      print('Catalogue sync error: $e');
    }
    return []; // Return empty if sync fails, UI will handle fallback to static if needed
  }


  static Future<List<dynamic>> getItems({String? category}) async {
    String url = '${baseUrl}api/catalogue.php?action=items';
    if (category != null) url += '&category=$category';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if(data['status'] == 'success') return data['data'];
    return [];
  }

  // --- Designers --- //

  static Future<List<dynamic>> getDesigners() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}api/designers.php')).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') return data['data'];
    } catch (e) {
      print('Error fetching designers: $e');
    }
    return []; // No more hardcoded fallbacks for real-time sync
  }


  static final List<Map<String, dynamic>> _fallbackDesigners = [
    {
      'id': 'd1',
      'name': 'Sarah Jenkins',
      'specialty': 'Modern Minimalist',
      'rating': 4.9,
      'experience_years': 8,
      'profile_pic_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      'bio': 'Passionate about creating clean, functional spaces that breathe.',
    },
    {
      'id': 'd2',
      'name': 'Michael Chen',
      'specialty': 'Industrial Chic',
      'rating': 4.7,
      'experience_years': 5,
      'profile_pic_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'bio': 'Focusing on raw materials and urban aesthetics.',
    }
  ];

  static Future<Map<String, dynamic>?> getDesignerDetails(String designerId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}api/designers.php?id=$designerId')).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') return data['data'];
    } catch (e) {}
    return null;
  }

  // --- User Projects --- //

  static Future<List<dynamic>> getUserProjects(String userId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}api/projects.php?user_id=$userId')).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if(data['status'] == 'success') return data['data'];
    } catch (e) {
      print('Error fetching projects: $e');
    }
    return []; // No more hardcoded fallbacks
  }


  static final List<Map<String, dynamic>> _fallbackProjects = [
    {
      'id': 'p1',
      'name': 'Modern Beach House',
      'description': 'A complete redesign of the living area focusing on natural light and coastal vibes.',
      'status': 'in_progress',
      'currency': 'INR',
      'total_estimated_cost': '1250000',
      'designer_name': 'Sarah Jenkins',
      'room_height': '10.0',
      'room_width': '15.0',
      'room_length': '20.0',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'p2',
      'name': 'Industrial Loft Kitchen',
      'description': 'Exposed brick, matte black finishes, and warm wood accents.',
      'status': 'completed',
      'currency': 'INR',
      'total_estimated_cost': '820000',
      'designer_name': 'Michael Chen',
      'room_height': '9.0',
      'room_width': '12.0',
      'room_length': '12.0',
      'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    },
    {
      'id': 'p3',
      'name': 'Minimalist Studio',
      'description': 'Space-saving furniture and neutral tones to maximize the small floor plan.',
      'status': 'draft',
      'currency': 'INR',
      'total_estimated_cost': '300000',
      'room_height': '8.5',
      'room_width': '10.0',
      'room_length': '12.0',
      'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    }
  ];

  static Future<Map<String, dynamic>> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/projects.php'),
        body: jsonEncode(projectData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {'status': 'error', 'message': 'Server returned ${response.statusCode}'};
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProject(Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/projects.php'),
        body: jsonEncode(projectData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        return {'status': 'error', 'message': 'Server returned ${response.statusCode}'};
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Feedback --- //
  
  static Future<Map<String, dynamic>> submitAppFeedback({
    String? userId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/feedback.php'),
      body: jsonEncode({
        'type': 'app',
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitDesignerFeedback({
    String? userId,
    required String designerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = userId ?? prefs.getString('user_id');
      
      final response = await http.post(
        Uri.parse('${baseUrl}api/feedback.php'),
        body: jsonEncode({
          'type': 'designer',
          'user_id': effectiveUserId,
          'designer_id': designerId,
          'rating': rating,
          'comment': comment,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(response.body);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('vibe_up_feedbacks') ?? [];
      final feedback = {
        'type': 'designer',
        'user_id': userId,
        'user_name': prefs.getString('user_name') ?? 'Client',
        'designer_id': designerId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      };
      existing.add(jsonEncode(feedback));
      await prefs.setStringList('vibe_up_feedbacks', existing);
      return {'status': 'success'};
    }
  }

  static Future<List<dynamic>> getDesignerFeedback(String designerId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api/feedback.php?designer_id=$designerId'),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') return data['data'];
    } catch (e) {}
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('vibe_up_feedbacks') ?? [];
    return existing
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .where((f) => f['designer_id'] == designerId)
        .toList();
  }

  // --- Design Requests (API-backed) --- //

  static Future<Map<String, dynamic>> createDesignRequest({
    required String userId,
    required String designerId,
    required String projectName,
    String? projectDescription,
    String? projectId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api_v2/requests.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'create',
          'user_id': userId,
          'designer_id': designerId,
          'project_name': projectName,
          'project_description': projectDescription ?? '',
          'project_id': projectId,
        }),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> getDesignRequests({
    String? designerId,
    String? userId,
    String? status,
  }) async {
    try {
      String url = '${baseUrl}api_v2/requests.php?action=list';
      if (designerId != null) url += '&designer_id=$designerId';
      if (userId != null) url += '&user_id=$userId';
      if (status != null) url += '&status=$status';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Handle both 'data' and 'requests' keys for compatibility
        final list = data['data'] ?? data['requests'];
        if (list != null) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
    } catch (e) {}
    return [];
  }

  static Future<Map<String, dynamic>> updateRequestStatus({
    required String requestId,
    required String newStatus,
    String? actorId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api_v2/requests.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'update_status',
          'request_id': requestId,
          'status': newStatus,
          'actor_id': actorId,
        }),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Admin Dashboard --- //

  static Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api_v2/admin.php?action=dashboard'),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') return data['data'];
    } catch (e) {}
    return {};
  }

  static Future<List<dynamic>> getAdminUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api_v2/admin.php?action=users'),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') return data['data'];
    } catch (e) {}
    return [];
  }

  static Future<List<dynamic>> getActivityLogs({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api_v2/admin.php?action=logs&limit=$limit'),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') return data['data'];
    } catch (e) {}
    return [];
  }

  static Future<Map<String, dynamic>> getDesignerStats(String designerId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}api_v2/get_designer_stats.php?designer_id=$designerId')).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data != null) return data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
    return {'status': 'error', 'message': 'Unknown error'};
  }



  // --- AI Chat Sessions --- //

  static Future<Map<String, dynamic>> createAiChatSession(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api_v2/ai_chats.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'create_session', 'user_id': userId}),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> getAiChatSessions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api_v2/ai_chats.php?action=list_sessions&user_id=$userId'),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      print('Error fetching AI sessions: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getAiChatMessages(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api_v2/ai_chats.php?action=get_messages&session_id=$sessionId'),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      print('Error fetching AI messages: $e');
    }
    return [];
  }

  static Future<bool> saveAiChatMessage(String sessionId, String role, String message, {String? imageUrl}) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api_v2/ai_chats.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'save_message',
          'session_id': sessionId,
          'role': role,
          'message': message,
          'image_url': imageUrl,
        }),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteAiChatSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api_v2/ai_chats.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'delete_session', 'session_id': sessionId}),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // --- Heartbeat --- //
  
  static Future<void> sendHeartbeat(String userId) async {
    if (userId.isEmpty) return;
    try {
      await http.post(
        Uri.parse('${baseUrl}api/heartbeat.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Fail silently for heartbeat
    }
  }
  // --- Node.js VR Backend Sync --- //
  static const String nodeBaseUrl = 'http://192.168.1.8:5000/api/';

  static Future<Map<String, dynamic>> saveRoomLayout(String projectId, List<dynamic> layoutData) async {
    try {
      print('VR: Saving layout to ${nodeBaseUrl}rooms with ${layoutData.length} items...');
      final response = await http.post(
        Uri.parse('${nodeBaseUrl}rooms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'project_id': int.tryParse(projectId) ?? 1,
          'layout_data': layoutData,
        }),
      ).timeout(const Duration(seconds: 30));
      print('VR: Response status=${response.statusCode}');
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        return {'success': false, 'message': body['message'] ?? 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      print('VR: Save error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRoomLayout(String layoutId) async {
    try {
       final response = await http.get(Uri.parse('${nodeBaseUrl}rooms/$layoutId')).timeout(const Duration(seconds: 5));
       return jsonDecode(response.body);
    } catch (e) {
       return {'success': false, 'message': e.toString()};
    }
  }

  // --- Node.js AI Assistant Sync --- //
  
  static Future<Map<String, dynamic>> askAiNode({
    required String message,
    required String userId,
    List<dynamic> history = const [],
    bool vastu = true,
    bool voiceOutput = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${nodeBaseUrl}ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'userId': userId,
          'messages': history,
          'vastu': vastu,
          'voiceOutput': voiceOutput,
        }),
      ).timeout(const Duration(seconds: 20));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> generateAiImageNode({
    required String prompt,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${nodeBaseUrl}ai/generate-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'userId': userId,
        }),
      ).timeout(const Duration(seconds: 45));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

}

