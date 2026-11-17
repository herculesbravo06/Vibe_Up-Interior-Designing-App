import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/budget_estimation_screen.dart';

class DesignerChatScreen extends StatelessWidget {
  final String designerName;
  const DesignerChatScreen({super.key, required this.designerName});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(radius: 14, backgroundColor: AppTheme.primaryAccent, child: Icon(Icons.person, size: 18, color: Colors.black)),
            const SizedBox(width: 12),
            Text(designerName),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.forum_outlined, size: 48, color: AppTheme.textDim),
                  const SizedBox(height: 16),
                  Text('Chat with $designerName.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Share images or PDFs for references.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textDim)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.cardColor,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.attach_file, color: AppTheme.primaryAccent), onPressed: () {}),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: AppTheme.backgroundDetail,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: AppTheme.primaryAccent, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.send, color: Colors.black), onPressed: () {}),
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
