import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../services/chat_history_service.dart';
import '../../services/gemini_service.dart';
import '../../theme/app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final String designerName;
  const ChatDetailScreen({super.key, required this.designerName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHistoryService _historyService = ChatHistoryService();
  final GeminiService _geminiService = GeminiService();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  Uint8List? _selectedFileBytes;
  String? _selectedMimeType;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.loadChatHistory();
    if (history.isNotEmpty) {
      setState(() {
        _messages = history;
      });
      // Re-initialize gemini session with history
      List<Content> geminiHistory = [];
      for (var msg in _messages.reversed) {
         if (msg['text'] != null) {
            if (msg['isMe']) {
              geminiHistory.add(Content.text(msg['text']));
            } else {
              geminiHistory.add(Content.model([TextPart(msg['text'])]));
            }
         }
      }
      _geminiService.startChat(history: geminiHistory);
    } else {
      _geminiService.startChat();
      setState(() {
        _messages.add({
          'isMe': false,
          'text': 'Hi! I am ${widget.designerName}, your Vibe Up assistant. How can I help you design your space today?',
        });
      });
      _historyService.saveChatHistory(_messages);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileBytes = result.files.single.bytes;
        final ext = result.files.single.extension?.toLowerCase();
        if (ext == 'pdf') {
          _selectedMimeType = 'application/pdf';
        } else if (ext == 'jpg' || ext == 'jpeg') {
          _selectedMimeType = 'image/jpeg';
        } else if (ext == 'png') {
          _selectedMimeType = 'image/png';
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty && _selectedFileBytes == null) return;

    final bytesToSend = _selectedFileBytes;
    final mimeToSend = _selectedMimeType;

    setState(() {
      _messages.insert(0, {
        'isMe': true, 
        'text': text.isNotEmpty ? text : 'Sent an attachment',
        'hasAttachment': bytesToSend != null
      });
      _msgController.clear();
      _selectedFileBytes = null;
      _selectedMimeType = null;
      _isLoading = true;
    });
    
    _historyService.saveChatHistory(_messages);
    _scrollToBottom();

    final response = await _geminiService.sendMessage(
      text.isNotEmpty ? text : 'Please analyze this attachment.',
      fileBytes: bytesToSend,
      mimeType: mimeToSend,
    );

    setState(() {
      _isLoading = false;
      if (response != null) {
        _messages.insert(0, {
          'isMe': false,
          'text': response,
        });
        _historyService.saveChatHistory(_messages);
      }
    });
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await _historyService.clearHistory();
              setState(() {
                _messages.clear();
                _geminiService.startChat();
                _messages.add({
                  'isMe': false,
                  'text': 'Chat history cleared. How can I help you?',
                });
                _historyService.saveChatHistory(_messages);
              });
            },
          )
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
                  final isMe = msg['isMe'];
                  final hasAttachment = msg['hasAttachment'] ?? false;
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasAttachment)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.attachment, size: 16, color: Colors.white70),
                                  SizedBox(width: 4),
                                  Text('Attachment included', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ),
                          Builder(
                            builder: (context) {
                              final text = msg['text'] ?? '';
                              // Regex to find markdown images ![alt](url) or raw pollinations/unsplash URLs
                              final RegExp imageRegex = RegExp(r'(?:!\[.*?\]\((.*?)\))|(https://(?:image\.pollinations\.ai|source\.unsplash\.com)[^\s>\])]+)');
                              final matches = imageRegex.allMatches(text);
                              
                              if (matches.isNotEmpty) {
                                List<Widget> children = [];
                                int lastMatchEnd = 0;
                                
                                for (final match in matches) {
                                  // Add text before the image
                                  if (match.start > lastMatchEnd) {
                                    children.add(Text(
                                      text.substring(lastMatchEnd, match.start),
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                        fontSize: 15,
                                      ),
                                    ));
                                  }
                                  
                                  // Add the image
                                  final imageUrl = match.group(1) ?? match.group(2);
                                  if (imageUrl != null) {
                                    children.add(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            imageUrl,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  lastMatchEnd = match.end;
                                }
                                
                                // Add remaining text
                                if (lastMatchEnd < text.length) {
                                  children.add(Text(
                                    text.substring(lastMatchEnd),
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: 15,
                                    ),
                                  ));
                                }
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: children,
                                );
                              }
                              
                              // Default plain text rendering
                              return Text(
                                text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: 15,
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0),
                  );
                },
              ),
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
                   if (_selectedFileBytes != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.file_present, color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('File attached', style: TextStyle(color: AppTheme.accentColor))),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() { _selectedFileBytes = null; _selectedMimeType = null; }),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Theme.of(context).primaryColor),
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
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: _isLoading ? null : _sendMessage,
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
