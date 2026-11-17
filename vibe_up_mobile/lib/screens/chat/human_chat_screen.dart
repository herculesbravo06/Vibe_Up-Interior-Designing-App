import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class HumanChatScreen extends StatefulWidget {
  final String designerName;
  final String? senderId;
  final String? receiverId;

  const HumanChatScreen({
    super.key,
    required this.designerName,
    this.senderId,
    this.receiverId,
  });

  @override
  State<HumanChatScreen> createState() => _HumanChatScreenState();
}

class _HumanChatScreenState extends State<HumanChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  String? _selectedFilePath;
  Timer? _timer;

  String currentUserId = ''; 
  String targetDesignerId = '';

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = widget.senderId ?? prefs.getString('user_id') ?? '';
      targetDesignerId = widget.receiverId ?? '';
    });
    _loadHistory();
    // Poll every 3 seconds for new messages
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}api_v2/get_chat_history.php?user_a=$currentUserId&user_b=$targetDesignerId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> rawMessages = data['data'];
          
          List<Map<String, dynamic>> parsedMessages = rawMessages.map((m) {
            return {
              'text': m['message_text'],
              'sender': m['sender_id'] == currentUserId ? 'user' : 'designer',
              'time': m['timestamp'],
              'fileUrl': m['file_url'],
              'fileType': m['file_type'],
            };
          }).toList();
          
          if (mounted) {
            bool hasSending = _messages.isNotEmpty && _messages.first['time'] == "Sending...";
            // Only update if count changed or a message is pending
            if (parsedMessages.length != _messages.length || hasSending) {
              setState(() {
                _messages = parsedMessages.reversed.toList();
              });
            }
          }
        } else {
          debugPrint("History error: ${data['message']}");
          if (mounted && _messages.isNotEmpty && _messages.first['time'] == "Sending...") {
            _handleSendFailure(data['message'] ?? "Failed to load history");
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty && _selectedFilePath == null) return;

    final String? filePathToUpload = _selectedFilePath;

    // 1. Optimistic UI Update
    setState(() {
      _messages.insert(0, {
        'text': text,
        'imagePath': filePathToUpload,
        'time': 'Sending...',
        'sender': 'user',
      });
      _msgController.clear();
      _selectedFilePath = null;
    });
    
    _scrollToBottom();

    // 2. Async operation (Non-blocking)
    _performSendMessage(text, filePathToUpload);
  }

  Future<void> _performSendMessage(String text, String? filePathToUpload) async {
    try {
      http.StreamedResponse? sResp;
      http.Response? resp;
      bool success = false;

      if (filePathToUpload != null) {
        var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}api_v2/send_message.php'));
        request.fields['sender_id'] = currentUserId;
        request.fields['receiver_id'] = targetDesignerId;
        request.fields['message_text'] = text;
        request.files.add(await http.MultipartFile.fromPath('file', filePathToUpload));
        sResp = await request.send();
        if (sResp.statusCode == 200) success = true;
      } else {
        resp = await http.post(
          Uri.parse('${ApiService.baseUrl}api_v2/send_message.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sender_id': currentUserId,
            'receiver_id': targetDesignerId,
            'message_text': text,
          }),
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data['status'] == 'success') success = true;
        }
      }

      if (success) {
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
      // Remove the "Sending..." message if it's still there
      setState(() {
        _messages.removeWhere((m) => m['time'] == 'Sending...');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$error (S:$currentUserId R:$targetDesignerId)"), backgroundColor: Colors.red),
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
                : Image.network(
                    imageUrl,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50, color: Colors.white),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.designerName, style: const TextStyle(fontSize: 16)),
            const Text("Online now", style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { _loadHistory(); }, 
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  bool isMe = msg['sender'] == 'user';
                  
                  final text = msg['text'] ?? '';
                  final imagePath = msg['imagePath'];
                  final time = msg['time'] ?? '';

                  final bool isPdf = (msg['fileType'] != null && (msg['fileType'].startsWith('application/pdf') || msg['fileType'] == 'pdf')) || 
                                     (msg['fileUrl'] != null && msg['fileUrl'].toLowerCase().endsWith('.pdf')) ||
                                     (imagePath != null && imagePath.toLowerCase().endsWith('.pdf'));

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFF2460D) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                          bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (isPdf)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6.0),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Document.pdf", 
                                      style: TextStyle(fontWeight: FontWeight.w500, color: isMe ? Colors.white : Colors.black87)
                                    ),
                                  )
                                ],
                              ),
                            )
                          else if (msg['fileUrl'] != null || imagePath != null)
                            GestureDetector(
                              onTap: () {
                                if (imagePath != null) {
                                  _showFullScreenImage(context, imagePath, isLocal: true);
                                } else if (msg['fileUrl'] != null) {
                                  _showFullScreenImage(context, '${ApiService.baseUrl}${msg['fileUrl']}');
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imagePath != null
                                    ? Image.file(
                                        File(imagePath),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      )
                                    : Image.network(
                                        '${ApiService.baseUrl}${msg['fileUrl']}',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      ),
                                ),
                              ),
                            ),
                          if (text.isNotEmpty)
                            Text(
                              text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 15,
                              ),
                            ),
                          if (time.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0),
                  );
                },
              ),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              child: Column(
                children: [
                   if (_selectedFilePath != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2460D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedFilePath!.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image, 
                            color: const Color(0xFFF2460D), 
                            size: 20
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFilePath!.split('/').last.split('\\').last, 
                              style: const TextStyle(color: Color(0xFFF2460D)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() { _selectedFilePath = null; }),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Color(0xFFF2460D)),
                        onPressed: _pickFile,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF2460D),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
