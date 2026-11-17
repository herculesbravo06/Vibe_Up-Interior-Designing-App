import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'dart:async';

class NotificationService {
  static Timer? _pollTimer;
  static Function(int)? _onUnreadCountChanged;

  /// Start polling for notifications
  static void startPolling(String userId, {Function(int)? onUnreadCountChanged}) {
    _onUnreadCountChanged = onUnreadCountChanged;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchUnreadCount(userId);
    });
    _fetchUnreadCount(userId); // immediate first call
  }

  static void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  static Future<void> _fetchUnreadCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}api_v2/notifications.php?user_id=$userId&unread_only=1'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final count = data['unread_count'] ?? 0;
          _onUnreadCountChanged?.call(count);
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Fetch all notifications for a user
  static Future<List<Map<String, dynamic>>> getNotifications(String userId, {bool unreadOnly = false}) async {
    try {
      String url = '${ApiService.baseUrl}api_v2/notifications.php?user_id=$userId';
      if (unreadOnly) url += '&unread_only=1';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      // Return empty on error
    }
    return [];
  }

  /// Mark a single notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}api_v2/notifications.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'mark_read', 'notification_id': notificationId}),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}api_v2/notifications.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'mark_all_read', 'user_id': userId}),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get unread count
  static Future<int> getUnreadCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}api_v2/notifications.php?user_id=$userId&unread_only=1'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['unread_count'] ?? 0;
        }
      }
    } catch (e) {
      // Silently fail
    }
    return 0;
  }
}
