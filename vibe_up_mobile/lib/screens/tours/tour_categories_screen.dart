import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/tours/panorama_tour_screen.dart';

class TourCategoriesScreen extends StatelessWidget {
  const TourCategoriesScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {
      'id': '1bhk',
      'title': '1 BHK Apartment',
      'description': 'Compact & functional living',
      'icon': Icons.weekend_outlined,
      'stats': '4 Rooms',
    },
    {
      'id': '2bhk',
      'title': '2 BHK Apartment',
      'description': 'Perfect for small families',
      'icon': Icons.family_restroom_outlined,
      'stats': '5 Rooms',
    },
    {
      'id': '3bhk',
      'title': '3 BHK Apartment',
      'description': 'Spacious urban living',
      'icon': Icons.king_bed_outlined,
      'stats': '6 Rooms',
    },
    {
      'id': '4bhk',
      'title': '4 BHK Premium',
      'description': 'Luxury family residence',
      'icon': Icons.chair_outlined,
      'stats': '8 Rooms',
    },
    {
      'id': '5bhk',
      'title': '5 BHK Villa',
      'description': 'Expansive grand living',
      'icon': Icons.villa_outlined,
      'stats': '10 Rooms',
    },
    {
      'id': 'office',
      'title': 'Commercial Office',
      'description': 'Modern workspace setting',
      'icon': Icons.business_center_outlined,
      'stats': '5 Areas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: AppTheme.glassDecoration,
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sample Tours',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Experience 360°',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fade().slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  Text(
                    'Step inside pre-designed, fully furnished virtual spaces.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.textDim,
                    ),
                  ).animate().fade(delay: 100.ms),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return _buildCategoryCard(context, cat, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PanoramaTourScreen(
                  categoryId: category['id'],
                  categoryTitle: category['title'],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.premiumCardDecoration.copyWith(
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.2)),
                  ),
                  child: Icon(category['icon'], color: AppTheme.primaryAccent, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['description'],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textDim,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Text(
                          category['stats'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textDim),
              ],
            ),
          ),
        ),
      ).animate().fade(delay: (200 + index * 100).ms).slideY(begin: 0.1),
    );
  }
}
