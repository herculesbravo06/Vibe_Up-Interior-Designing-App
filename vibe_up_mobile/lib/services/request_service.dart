import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class RequestService {
  /// Save a new request — writes directly to API
  static Future<bool> saveRequest({
    required String designerId,
    required String projectName,
    required String projectDetails,
    String? projectId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    if (userId == null) return false;

    final result = await ApiService.createDesignRequest(
      userId: userId,
      designerId: designerId,
      projectName: projectName,
      projectDescription: projectDetails,
      projectId: projectId,
    );

    return result['status'] == 'success';
  }

  /// Get all requests matching filters from the API
  static Future<List<Map<String, dynamic>>> getRequests({
    String? status,
    String? designerId,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? prefs.getString('user_id');
    final effectiveDesignerId = designerId ?? (prefs.getString('user_role') == 'designer' ? prefs.getString('designer_id') : null);

    if (effectiveUserId == null && effectiveDesignerId == null) return [];

    final apiRequests = await ApiService.getDesignRequests(
      // If we are looking for a designer's requests, don't pass userId (which would filter for requests they MADE as a client)
      userId: designerId != null || (prefs.getString('user_role') == 'designer') ? null : effectiveUserId,
      designerId: effectiveDesignerId,
      status: status == 'new' ? 'pending' : status,
    );

    return apiRequests.map((r) => {
      'userName': r['user_name'] ?? 'Client',
      'projectName': r['project_name'] ?? 'No Title',
      'projectDetails': r['project_description'] ?? '',
      'designerName': r['designer_name'] ?? 'Designer',
      'status': r['status'] == 'pending' ? 'new' : r['status'],
      'timestamp': r['created_at'] ?? '',
      'request_id': r['id'] ?? '',
      'user_id': r['user_id'] ?? '',
      'designer_id': r['designer_id'] ?? '',
      'designer_user_id': r['designer_user_id'] ?? '',
    }).toList();
  }

  /// Update the status of a request via the API
  static Future<bool> updateRequestStatus(String requestId, String newStatus) async {
    final apiStatus = newStatus == 'new' ? 'pending' : newStatus;
    
    final result = await ApiService.updateRequestStatus(
      requestId: requestId, 
      newStatus: apiStatus
    );

    return result['status'] == 'success';
  }
}
