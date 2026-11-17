import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/catalogue/category_items_screen.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'title': 'Movable Furniture', 'icon': Icons.chair_alt, 'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&q=80&w=300'},
    {'title': 'Decor & Art', 'icon': Icons.format_paint, 'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&q=80&w=300'},
    {'title': 'Lighting', 'icon': Icons.light, 'image': 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?auto=format&fit=crop&q=80&w=300'},
    {'title': 'Rugs & Carpets', 'icon': Icons.layers, 'image': 'https://images.unsplash.com/photo-1600166898405-da9535204843?auto=format&fit=crop&q=80&w=300'},
    {'title': 'Storage Options', 'icon': Icons.inventory_2, 'image': 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&q=80&w=300'},
    {'title': 'Plants & Greenery', 'icon': Icons.eco, 'image': 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?auto=format&fit=crop&q=80&w=300'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Catalogue', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryItemsScreen(categoryName: cat['title']))),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: CachedNetworkImage(
                        imageUrl: cat['image'],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppTheme.cardColor,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryAccent)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.primaryAccent.withOpacity(0.08),
                          child: Icon(cat['icon'], size: 40, color: AppTheme.primaryAccent),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          cat['title'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fade(delay: (100 + index * 80).ms).scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
        },
      ),
    );
  }
}
