import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_up/screens/project/ar_confirmation_screen.dart';
import 'package:vibe_up/services/gemini_service.dart';

class AiHelpScreen extends StatefulWidget {
  const AiHelpScreen({super.key});

  @override
  State<AiHelpScreen> createState() => _AiHelpScreenState();
}

class _AiHelpScreenState extends State<AiHelpScreen> {
  final TextEditingController _promptController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hi! I am the Vibe Up AI powered by Gemini. Please upload a photo of your room or describe your preferred style, and I will help you with design concepts.',
      'image': null,
    }
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _promptController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    
    final currentImage = _selectedImage;
    setState(() {
      _messages.insert(0, {
        'isUser': true,
        'text': text,
        'image': currentImage?.path,
      });
      _selectedImage = null;
      _isLoading = true;
    });
    
    _promptController.clear();

    Uint8List? fileBytes;
    String? mimeType;
    if (currentImage != null) {
      fileBytes = await currentImage.readAsBytes();
      mimeType = 'image/jpeg';
    }

    final response = await _geminiService.sendMessage(
      text.isEmpty ? "What can you tell me about this image?" : text, 
      fileBytes: fileBytes, 
      mimeType: mimeType
    );

    setState(() {
      _isLoading = false;
      _messages.insert(0, {
        'isUser': false,
        'text': response ?? 'Sorry, I could not process that request.',
        'image': (text.toLowerCase().contains('generate') || text.toLowerCase().contains('design')) 
            ? 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&q=80&w=400' 
            : null,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Design Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ArConfirmationScreen(source: 'AI')));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['isUser'];
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                          bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg['image'] != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isUser 
                                  ? Image.file(File(msg['image']))
                                  : Image.network(msg['image']),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            msg['text'],
                            style: TextStyle(
                              color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 15,
                            ),
                          ),
                          if (msg['image'] != null) ...[
                             const SizedBox(height: 12),
                             ElevatedButton.icon(
                               onPressed: () {
                                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ArConfirmationScreen(source: 'AI')));
                               },
                               icon: const Icon(Icons.view_in_ar),
                               label: const Text('View in AR'),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: isUser ? Colors.white : Theme.of(context).primaryColor,
                                 foregroundColor: isUser ? Theme.of(context).primaryColor : Colors.white,
                               ),
                             )
                          ]
                        ],
                      ),
                    ),
                  ).animate().fade().slideY(begin: 0.1);
                },
              ),
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ]
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_photo_alternate_outlined, color: _selectedImage != null ? Colors.green : Theme.of(context).primaryColor),
                      onPressed: _pickImage,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        decoration: InputDecoration(
                          hintText: 'Describe your room...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
