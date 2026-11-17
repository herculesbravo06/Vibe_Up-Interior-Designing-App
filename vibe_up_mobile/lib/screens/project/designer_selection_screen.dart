import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/chat/chat_detail_screen.dart';

class DesignerSelectionScreen extends StatelessWidget {
  const DesignerSelectionScreen({super.key});

  final List<Map<String, dynamic>> _designers = const [
    {'name': 'Sarah Jenkins', 'rating': 4.9, 'style': 'Modern Minimalist', 'image': 'https://i.pravatar.cc/150?img=5'},
    {'name': 'Michael Chen', 'rating': 4.8, 'style': 'Industrial Vintage', 'image': 'https://i.pravatar.cc/150?img=11'},
    {'name': 'Emma Watson', 'rating': 4.9, 'style': 'Bohemian Chic', 'image': 'https://i.pravatar.cc/150?img=9'},
    {'name': 'David Miller', 'rating': 4.7, 'style': 'Classic Elegance', 'image': 'https://i.pravatar.cc/150?img=12'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Designers'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24.0),
        itemCount: _designers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final designer = _designers[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(designer['image']),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        designer['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        designer['style'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${designer['rating']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(designerName: designer['name'])));
                  },
                ),
              ],
            ),
          ).animate().fade(delay: (200 + index * 100).ms).slideY(begin: 0.1);
        },
      ),
    );
  }
}
