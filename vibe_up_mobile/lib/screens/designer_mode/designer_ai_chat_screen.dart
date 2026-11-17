import 'package:vibe_up/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/services/gemini_service.dart';

class DesignerAiChatScreen extends StatefulWidget {
  const DesignerAiChatScreen({super.key});

  @override
  State<DesignerAiChatScreen> createState() => _DesignerAiChatScreenState();
}

class _DesignerAiChatScreenState extends State<DesignerAiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();

  static Color _primary = AppTheme.primaryAccent;
  static Color _darkBg = AppTheme.background;
  static Color _sidebarBg = AppTheme.surfaceDark;
  static Color _cardDark = AppTheme.cardColor;
  static Color _aiBubble = AppTheme.cardColor;
  static Color _userBubble = AppTheme.primaryAccent;

  String _designerId = '';
  String _currentSessionId = '';
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSendingMessage = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _designerId = prefs.getString('designer_id') ?? prefs.getString('user_id') ?? '';
    await _loadSessions();
    if (_sessions.isEmpty) {
      await _createNewChat();
    } else {
      await _loadSession(_sessions.first['id']);
    }
  }

  Future<void> _loadSessions() async {
    final sessions = await ApiService.getAiChatSessions(_designerId);
    if (mounted) setState(() => _sessions = sessions);
  }

  Future<void> _loadSession(String sessionId) async {
    setState(() {
      _currentSessionId = sessionId;
      _isLoading = true;
    });
    final messages = await ApiService.getAiChatMessages(sessionId);
    if (mounted) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _createNewChat({bool fromDrawer = false}) async {
    final result = await ApiService.createAiChatSession(_designerId);
    if (result['status'] == 'success') {
      final sessionId = result['session_id'];
      await _loadSessions();
      await _loadSession(sessionId);
      // Add welcome message
      await ApiService.saveAiChatMessage(
        sessionId, 'ai',
        'Hello! I\'m your AI Design Assistant powered by Gemini. I can help you with:\n\n'
        '🎨 **Mood Board** — Describe a style and I\'ll create one\n'
        '🪑 **Furniture Suggestions** — Tell me about a room for curated picks\n'
        '🖼️ **Design Generation** — Say "generate" + your vision for images\n'
        '📐 **Layout Tips** — Upload a room photo for spatial advice\n'
        '💡 **Style Advice** — Ask me anything about interior design!\n\n'
        'How can I help you today?',
      );
      await _loadSession(sessionId);
    }
    if (mounted && fromDrawer) Navigator.of(context).pop(); // Close drawer
  }

  Future<void> _deleteSession(String sessionId) async {
    await ApiService.deleteAiChatSession(sessionId);
    await _loadSessions();
    if (_currentSessionId == sessionId) {
      if (_sessions.isNotEmpty) {
        await _loadSession(_sessions.first['id']);
      } else {
        await _createNewChat();
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final currentImage = _selectedImage;
    setState(() {
      _messages.add({
        'role': 'user',
        'message': text,
        'image_url': currentImage?.path,
        '_isLocal': true,
      });
      _selectedImage = null;
      _isSendingMessage = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Save user message to DB
    await ApiService.saveAiChatMessage(_currentSessionId, 'user', text);

    // Prepare image bytes
    Uint8List? fileBytes;
    String? mimeType;
    if (currentImage != null) {
      fileBytes = await currentImage.readAsBytes();
      mimeType = 'image/jpeg';
    }

    // Get AI response
    final response = await _geminiService.sendMessage(
      text.isEmpty ? "What can you tell me about this image?" : text,
      fileBytes: fileBytes,
      mimeType: mimeType,
    );

    final aiText = response ?? 'Sorry, I could not process that request.';

    // Save AI response to DB
    await ApiService.saveAiChatMessage(_currentSessionId, 'ai', aiText);

    if (mounted) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'message': aiText,
          'image_url': null,
        });
        _isSendingMessage = false;
      });
      _scrollToBottom();
      // Refresh sessions to update sidebar title
      _loadSessions();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  String _timeAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _sidebarBg,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: _primary, size: 22),
            const SizedBox(width: 8),
            Text('AI Design Assistant', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment, color: _primary),
            tooltip: 'New Chat',
            onPressed: () async {
              await _createNewChat();
            },
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _primary))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 64, color: _primary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('Start a conversation', style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['role'] == 'user';
                          return _buildMessageBubble(msg, isUser);
                        },
                      ),
          ),

          // Typing indicator
          if (_isSendingMessage)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _aiBubble,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _typingDot(0),
                        const SizedBox(width: 4),
                        _typingDot(1),
                        const SizedBox(width: 4),
                        _typingDot(2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Image preview
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _sidebarBg,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_selectedImage!.path), height: 50, width: 50, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Text('Image selected', style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _sidebarBg,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: _primary, size: 22),
                    onPressed: _captureImage,
                  ),
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: _selectedImage != null ? Colors.green : _primary, size: 22),
                    onPressed: _pickImage,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _darkBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 15),
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Ask about designs, mood boards...',
                          hintStyle: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isSendingMessage ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: _sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: _primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Chat History', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppTheme.textDim),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // New Chat Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ]
                ),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _createNewChat(fromDrawer: true);
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('New Chat', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),

            // Sessions list
            Expanded(
              child: _sessions.isEmpty
                  ? Center(child: Text('No chats yet', style: TextStyle(color: AppTheme.textDim)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final isActive = session['id'] == _currentSessionId;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? _primary.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isActive ? Border.all(color: _primary.withOpacity(0.3)) : null,
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              color: isActive ? _primary : Colors.white38,
                              size: 20,
                            ),
                            title: Text(
                              session['title'] ?? 'New Chat',
                              style: GoogleFonts.dmSans(
                                color: isActive ? AppTheme.textPrimary : AppTheme.textDim,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _timeAgo(session['updated_at']),
                              style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 11),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 18),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: _cardDark,
                                    title: Text('Delete Chat', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                    content: Text('Are you sure you want to delete this chat?', style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _deleteSession(session['id']);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              _loadSession(session['id']);
                              Navigator.of(context).pop(); // Close drawer
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
        decoration: BoxDecoration(
          color: isUser ? _userBubble : _aiBubble,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
            bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Role label
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.auto_awesome,
                  color: isUser ? Colors.white70 : _primary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'You' : 'AI Assistant',
                  style: GoogleFonts.dmSans(
                    color: isUser ? Colors.white70 : _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Image
            if (msg['image_url'] != null && msg['image_url'].toString().isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: msg['_isLocal'] == true
                    ? Image.file(File(msg['image_url']), height: 200, fit: BoxFit.cover)
                    : Image.network(
                        msg['image_url'],
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
              ),
              const SizedBox(height: 8),
            ],

            // Message text
            if (msg['message'] != null && msg['message'].toString().isNotEmpty)
              SelectableText(
                msg['message'],
                style: GoogleFonts.dmSans(
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),

            // Timestamp
            if (msg['created_at'] != null) ...[
              const SizedBox(height: 6),
              Text(
                _timeAgo(msg['created_at']),
                style: GoogleFonts.dmSans(color: isUser ? Colors.white.withOpacity(0.5) : AppTheme.textDim, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _typingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.4 + value * 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
