import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/budget_estimation_screen.dart';
import 'package:vibe_up/services/gemini_service.dart';

class AiChatHelpScreen extends StatefulWidget {
  const AiChatHelpScreen({super.key});

  @override
  State<AiChatHelpScreen> createState() => _AiChatHelpScreenState();
}

class _AiChatHelpScreenState extends State<AiChatHelpScreen> {
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {'role': 'ai', 'text': 'Hello! Upload a JPEG/JPG/PDF of your room or tell me what style you\'re going for, and I\'ll help you visualize concepts!', 'image': null, 'file': null}
  ];
  final _controller = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _selectedFile = null;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _selectedImage = null;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null && _selectedFile == null) return;
    
    final currentImage = _selectedImage;
    final currentFile = _selectedFile;
    
    setState(() {
      _messages.add({
        'role': 'user', 
        'text': text,
        'image': currentImage?.path,
        'file': currentFile?.name,
      });
      _selectedImage = null;
      _selectedFile = null;
      _isLoading = true;
    });
    
    _controller.clear();

    Uint8List? fileBytes;
    String? mimeType;
    
    if (currentImage != null) {
      fileBytes = await currentImage.readAsBytes();
      mimeType = 'image/jpeg';
    } else if (currentFile != null) {
      fileBytes = await File(currentFile.path!).readAsBytes();
      mimeType = 'application/pdf';
    }

    final response = await _geminiService.sendMessage(
      text.isEmpty ? (currentImage != null ? "What can you tell me about this image?" : "Please analyze this file.") : text, 
      fileBytes: fileBytes, 
      mimeType: mimeType
    );

    setState(() {
      _isLoading = false;
      _messages.add({
        'role': 'ai',
        'text': response ?? 'Sorry, I could not process that request.',
        'image': (text.toLowerCase().contains('generate') || text.toLowerCase().contains('concept')) 
            ? 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&q=80&w=400' 
            : null,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: AppTheme.primaryAccent),
            SizedBox(width: 8),
            Text('AI Assistant'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetEstimationScreen()));
            },
            child: const Text('Finish', style: TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAi = msg['role'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isAi ? AppTheme.cardColor : AppTheme.primaryAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isAi ? AppTheme.textDim.withOpacity(0.1) : AppTheme.primaryAccent, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        if (msg['file'] != null && !isAi) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDetail,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Colors.red),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    msg['file']?.toString() ?? '',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (msg['image'] != null && !isAi) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(msg['image'])),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (msg['image'] != null && isAi) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(msg['image']),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(msg['text'] ?? '', style: TextStyle(fontSize: 16, color: isAi ? AppTheme.textLight : AppTheme.primaryAccent)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppTheme.primaryAccent),
            ),
          if (_selectedImage != null || _selectedFile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.cardColor,
              child: Row(
                children: [
                   if (_selectedImage != null)
                     ClipRRect(
                       borderRadius: BorderRadius.circular(8),
                       child: Image.file(File(_selectedImage!.path), height: 50, width: 50, fit: BoxFit.cover),
                     ),
                   if (_selectedFile != null)
                     const Icon(Icons.insert_drive_file, size: 40, color: AppTheme.primaryAccent),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       _selectedImage != null ? 'Image Selected' : _selectedFile!.name,
                       style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   IconButton(
                     icon: const Icon(Icons.close, color: Colors.grey),
                     onPressed: () {
                       setState(() {
                         _selectedImage = null;
                         _selectedFile = null;
                       });
                     },
                   )
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.cardColor,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryAccent),
                      onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                      icon: const Icon(Icons.image_outlined, color: AppTheme.primaryAccent),
                      onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  IconButton(
                      icon: const Icon(Icons.attach_file, color: AppTheme.primaryAccent),
                      onPressed: _pickFile,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask for suggestions or images...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: AppTheme.backgroundDetail,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: AppTheme.primaryAccent, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
