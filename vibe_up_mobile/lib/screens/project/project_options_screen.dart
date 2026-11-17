import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/ai_chat_help_screen.dart';
import 'package:vibe_up/screens/project/designer_list_screen.dart';
import 'package:vibe_up/screens/project/diy_workspace_screen.dart';

class ProjectOptionsScreen extends StatelessWidget {
  final String? projectId;
  final Map<String, dynamic>? projectData;
  const ProjectOptionsScreen({super.key, this.projectId, this.projectData});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(title: const Text('Choose Assistant', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('How would you like to design your space?', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
            const SizedBox(height: 32),
            _buildOptionCard(context, title: 'Use AI for Help', icon: Icons.smart_toy_outlined, onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatHelpScreen()));
            }),
            const SizedBox(height: 16),
            _buildOptionCard(context, title: 'Chat with Designer', icon: Icons.person_search_outlined, onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => DesignerListScreen(projectId: projectId)));
            }),
            const SizedBox(height: 16),
            _buildOptionCard(context, title: 'Do It Yourself (DIY AR)', icon: Icons.view_in_ar_outlined, onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => DiyWorkspaceScreen(projectId: projectId, projectData: projectData)));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: AppTheme.primaryAccent),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textDim, size: 16),
          ],
        ),
      ),
    );
  }
}
