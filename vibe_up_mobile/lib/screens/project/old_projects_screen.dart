import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/new_project_wizard.dart';

class OldProjectsScreen extends StatelessWidget {
  const OldProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Project History', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?q=80&w=1000&auto=format&fit=crop',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.white.withOpacity(0.05),
                          child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 2)),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                            'COMPLETED',
                            style: GoogleFonts.inter(color: AppTheme.primaryAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Modern Minimalism ${index + 1}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const Icon(Icons.more_vert_rounded, color: AppTheme.textDim, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Archived on Oct ${12 + index}, 2025', style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 13)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final project = {
                              'id': 'P00${index + 1}',
                              'name': 'Project ${index + 1}',
                              'room_height': '3.0',
                              'room_width': '8.0',
                              'room_length': '8.0',
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewProjectWizard(projectData: project)
                              )
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                            foregroundColor: AppTheme.primaryAccent,
                            elevation: 0,
                            side: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ).animate().fade(delay: (index * 150).ms).slideY(begin: 0.1),
          );
        },
      ),
    );
  }
}
