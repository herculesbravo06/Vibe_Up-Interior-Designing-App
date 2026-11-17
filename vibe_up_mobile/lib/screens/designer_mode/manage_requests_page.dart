import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/request_service.dart';
import 'package:vibe_up/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'chat_page.dart';

class ManageRequestsPage extends StatefulWidget {
  final int initialTabIndex;

  const ManageRequestsPage({super.key, this.initialTabIndex = 0});

  @override
  State<ManageRequestsPage> createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _newRequests = [];
  List<Map<String, dynamic>> _liveRequests = [];
  List<Map<String, dynamic>> _oldRequests = [];
  Timer? _unreadTimer;
  Timer? _requestTimer;
  Map<String, int> _unreadCounts = {};
  bool _isLoading = true;

  final Color primary = AppTheme.primaryAccent;

  String currentDesignerId = ''; // designer table ID (e.g. D20001)
  String currentUserId = '';     // user table ID (e.g. U20001)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentDesignerId = prefs.getString('designer_id') ?? '';
      currentUserId = prefs.getString('user_id') ?? '';
    });
    _loadRequests();
    _fetchUnreadCounts();
    _unreadTimer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchUnreadCounts());
    // Poll for new requests every 5 seconds for realtime updates
    _requestTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadRequests());
  }

  Future<void> _fetchUnreadCounts() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}api_v2/get_unread_counts.php?user_id=$currentUserId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final unreadsJson = data['unread_counts'] as List;
          final Map<String, int> counts = {};
          for (var item in unreadsJson) {
            counts[item['sender_id']] = int.tryParse(item['count'].toString()) ?? 0;
          }
          if (mounted) {
            setState(() {
              _unreadCounts = counts;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching unread counts: $e");
    }
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    _requestTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    if (currentDesignerId.isEmpty) {
       final prefs = await SharedPreferences.getInstance();
       currentDesignerId = prefs.getString('designer_id') ?? '';
       currentUserId = prefs.getString('user_id') ?? '';
    }
    // Only show loading spinner on first load
    if (_isLoading && _newRequests.isEmpty && _liveRequests.isEmpty && _oldRequests.isEmpty) {
      setState(() => _isLoading = true);
    }
    final newR = await RequestService.getRequests(status: 'new', designerId: currentDesignerId);
    final liveR = await RequestService.getRequests(status: 'accepted', designerId: currentDesignerId);
    final oldR = await RequestService.getRequests(status: 'declined', designerId: currentDesignerId);
    if (mounted) {
      setState(() {
        _newRequests = newR;
        _liveRequests = liveR;
        _oldRequests = oldR;
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    final requestId = request['request_id'];
    if (requestId != null) {
      final success = await RequestService.updateRequestStatus(requestId.toString(), 'accepted');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accepted ${request['userName']}\'s request!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadRequests();
    }
  }

  Future<void> _declineRequest(Map<String, dynamic> request) async {
    final requestId = request['request_id'];
    if (requestId != null) {
      await RequestService.updateRequestStatus(requestId.toString(), 'declined');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request declined.'), backgroundColor: Colors.red),
        );
      }
      _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Manage Requests", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: AppTheme.textDim,
          indicatorColor: primary,
          labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.dmSans(),
          tabs: [
            Tab(text: 'New (${_newRequests.length})'),
            Tab(text: 'Live (${_liveRequests.length})'),
            Tab(text: 'Old (${_oldRequests.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(_newRequests, showActions: true),
                _buildRequestList(_liveRequests, showChat: true),
                _buildRequestList(_oldRequests),
              ],
            ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requests, {bool showActions = false, bool showChat = false}) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textDim),
            const SizedBox(height: 16),
            Text('No requests here', style: GoogleFonts.dmSans(fontSize: 16, color: AppTheme.textDim)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return _buildRequestCard(req, showActions: showActions, showChat: showChat);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req, {bool showActions = false, bool showChat = false}) {
    final userName = req['userName'] ?? 'User';
    final projectName = req['projectName'] ?? 'Project';
    final projectDetails = req['projectDetails'] ?? '';
    final designerName = req['designerName'] ?? 'Designer';
    final timestamp = req['timestamp'] ?? '';

    String timeAgo = '';
    if (timestamp.isNotEmpty) {
      final dt = DateTime.tryParse(timestamp);
      if (dt != null) {
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes} min ago';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours} hours ago';
        } else {
          timeAgo = '${diff.inDays} days ago';
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primary.withOpacity(0.15),
                  child: Text(
                    userName[0].toUpperCase(),
                    style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      if (timeAgo.isNotEmpty)
                        Text(timeAgo, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textDim)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    req['status']?.toString().toUpperCase() ?? 'NEW',
                    style: GoogleFonts.dmSans(color: primary, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Project info
            Text(
              projectName,
              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
            ),
            const SizedBox(height: 6),
            Text(
              projectDetails,
              style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () => _acceptRequest(req),
                        child: Text("Accept Request", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _declineRequest(req),
                      child: Text("Decline", style: GoogleFonts.dmSans(color: AppTheme.textDim)),
                    ),
                  ),
                ],
              ),
            ],

            if (showChat) ...[
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (_) => ChatPage(
                            clientName: userName,
                            projectTitle: projectName,
                            senderId: currentUserId,
                            receiverId: req['user_id']?.toString() ?? '',
                            userRole: 'designer',
                          ),
                          ),
                        ).then((_) => _fetchUnreadCounts()); 
                      },
                      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                      label: Text("Open Chat", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  if (_unreadCounts[req['user_id']?.toString()] != null && _unreadCounts[req['user_id']?.toString()]! > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF25D366), // WhatsApp Green Focus
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _unreadCounts[req['user_id']?.toString()]!.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
