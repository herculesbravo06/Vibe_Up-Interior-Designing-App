import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String clientName;
  final String projectTitle;
  final String? senderId;
  final String? receiverId;
  final String? userRole; // 'user' or 'designer'

  const ChatPage({
    super.key,
    required this.clientName,
    required this.projectTitle,
    this.senderId,
    this.receiverId,
    this.userRole,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> messages = [];
  String? _selectedFilePath;
  Timer? _timer;

  String currentSenderId = ''; 
  String currentReceiverId = '';
  String currentRole = 'user';

  final Color _brandOrange = AppTheme.primaryAccent;
  final Color _bgLight = AppTheme.background;
  final Color _bubbleSent = AppTheme.primaryAccent.withOpacity(0.15);

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentSenderId = widget.senderId ?? prefs.getString('user_id') ?? '';
      currentReceiverId = widget.receiverId ?? '';
      currentRole = widget.userRole ?? prefs.getString('role') ?? 'user';
    });
    
    _loadHistory(initial: true);
    // Poll every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory({bool initial = false}) async {
    if (currentSenderId.isEmpty || currentReceiverId.isEmpty) return;
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}api_v2/get_chat_history.php?user_a=$currentSenderId&user_b=$currentReceiverId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> rawMessages = data['data'];
          
          List<Map<String, dynamic>> parsedMessages = rawMessages.map((m) {
            return {
              'text': m['message_text'],
              'sender': m['sender_id'] == currentSenderId ? 'me' : 'other',
              'time': m['timestamp'],
              'fileUrl': m['file_url'],
              'fileType': m['file_type'],
              'sender_id': m['sender_id'],
            };
          }).toList();
          
          if (mounted) {
            bool hasSending = messages.isNotEmpty && messages.first['time'] == "Sending...";
            // Update state if count changed, if it's the initial load, or if we have a pending "Sending..." message
            if (initial || parsedMessages.length != messages.length || hasSending) {
              setState(() {
                messages = parsedMessages.reversed.toList();
              });
            }
          }
        } else {
          debugPrint("History error: ${data['message']}");
          if (mounted && messages.isNotEmpty && messages.first['time'] == "Sending...") {
             _handleSendFailure(data['message'] ?? "Failed to load history");
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty && _selectedFilePath == null) return;

    final String? filePathToUpload = _selectedFilePath;
    
    // 1. Optimistic UI Update (Immediate response)
    setState(() {
      messages.insert(0, {
        "text": text,
        "sender": "me", 
        "imagePath": filePathToUpload,
        "time": "Sending...",
      });
      messageController.clear();
      _selectedFilePath = null;
    });

    _scrollToBottom();

    // 2. Async API call (Non-blocking)
    _performSendMessage(text, filePathToUpload);
  }

  Future<void> _performSendMessage(String text, String? filePathToUpload) async {
    try {
      http.StreamedResponse? sResp;
      http.Response? resp;
      bool success = false;

      if (filePathToUpload != null) {
        var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}api_v2/send_message.php'));
        request.fields['sender_id'] = currentSenderId;
        request.fields['receiver_id'] = currentReceiverId;
        request.fields['message_text'] = text;
        request.files.add(await http.MultipartFile.fromPath('file', filePathToUpload));
        sResp = await request.send();
        if (sResp.statusCode == 200) success = true;
      } else {
        resp = await http.post(
          Uri.parse('${ApiService.baseUrl}api_v2/send_message.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sender_id': currentSenderId,
            'receiver_id': currentReceiverId,
            'message_text': text,
          }),
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data['status'] == 'success') success = true;
        }
      }

      if (success) {
        // Refresh history to confirm message was sent
        _loadHistory();
      } else {
        String msg = "Failed to send message";
        if (resp != null) {
          try {
             final data = jsonDecode(resp.body);
             if (data['message'] != null) msg = data['message'];
          } catch(_) {}
        }
        _handleSendFailure(msg);
      }
    } catch (e) {
      debugPrint("Send error: $e");
      _handleSendFailure(e.toString());
    }
  }

  void _handleSendFailure(String error) {
    if (mounted) {
      setState(() {
        messages.removeWhere((m) => m['time'] == 'Sending...');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$error (S:$currentSenderId R:$currentReceiverId)"), backgroundColor: Colors.red),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  String _formatTime(String timeStr) {
    if (timeStr == "Sending...") return timeStr;
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      int h = dt.hour;
      int m = dt.minute;
      String ampm = h >= 12 ? 'pm' : 'am';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:${m.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return timeStr.split(' ').last;
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, {bool isLocal = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: isLocal 
                ? Image.file(File(imageUrl)) 
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMessage(Map msg) {
    bool isMe = msg['sender'] == 'me';

    final text = msg['text'] ?? '';
    final timeStr = msg['time'] ?? '';
    final formattedTime = _formatTime(timeStr);
    
    final fileUrl = msg['fileUrl'];
    final fileType = msg['fileType'];
    final imagePath = msg['imagePath'];

    final bool isImage = (fileUrl != null && (
      (fileType != null && fileType.startsWith('image/')) || 
      (fileUrl.toLowerCase().endsWith('.jpg') || fileUrl.toLowerCase().endsWith('.jpeg') || fileUrl.toLowerCase().endsWith('.png') || fileUrl.toLowerCase().endsWith('.webp'))
    ));
    final bool isPdf = (fileUrl != null && (
      (fileType != null && (fileType.startsWith('application/pdf') || fileType == 'pdf')) || 
      (fileUrl.toLowerCase().endsWith('.pdf'))
    ));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? _bubbleSent : AppTheme.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isImage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showFullScreenImage(context, '${ApiService.baseUrl}$fileUrl'),
                      borderRadius: BorderRadius.circular(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: '${ApiService.baseUrl}$fileUrl',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(width: 200, height: 200, color: Colors.grey[300]),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                ),
              if (isPdf)
                Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text("Document.pdf", style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      )
                    ],
                  ),
                ),
              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showFullScreenImage(context, imagePath, isLocal: true),
                      borderRadius: BorderRadius.circular(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imagePath),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                
              if (text.isNotEmpty)
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    text,
                    style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 16),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formattedTime,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textDim),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all_rounded, size: 14, color: Colors.blueAccent),
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 1,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _brandOrange.withOpacity(0.15),
              child: Icon(Icons.person_rounded, color: _brandOrange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clientName,
                    style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "online",
                    style: GoogleFonts.dmSans(fontSize: 13, color: _brandOrange, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.videocam_rounded, color: _brandOrange), onPressed: () {}),
          IconButton(icon: Icon(Icons.call_rounded, color: _brandOrange), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: _brandOrange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.business_center_rounded, size: 16, color: _brandOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Project: ${widget.projectTitle}",
                    style: GoogleFonts.dmSans(fontSize: 14, color: _brandOrange, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: messages.length,
              itemBuilder: (_, i) => buildMessage(messages[i]),
            ),
          ),
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 4),
            child: Column(
              children: [
                 if (_selectedFilePath != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedFilePath!.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image, 
                          color: _brandOrange, 
                          size: 24
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedFilePath!.split('/').last.split('\\').last, 
                            style: const TextStyle(color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                          onPressed: () => setState(() { _selectedFilePath = null; }),
                        )
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: messageController,
                                maxLines: 5,
                                minLines: 1,
                                style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  hintText: "Type a message...",
                                  hintStyle: GoogleFonts.dmSans(color: AppTheme.textDim),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  setState(() { _selectedFilePath = result.files.single.path; });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(color: _brandOrange, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: sendMessage,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
