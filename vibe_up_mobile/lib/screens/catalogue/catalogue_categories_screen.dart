import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/catalogue/catalogue_items_screen.dart';

class CatalogueCategoriesScreen extends StatefulWidget {
  const CatalogueCategoriesScreen({super.key});

  @override
  State<CatalogueCategoriesScreen> createState() => _CatalogueCategoriesScreenState();
}

class _CatalogueCategoriesScreenState extends State<CatalogueCategoriesScreen> {
  // Predefined categories with web preview images and icons
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'sofa',
      'display': 'Sofas & Seating',
      'icon': Icons.weekend,
      'color': Colors.indigo,
      'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&q=80&w=400',
    },
    {
      'name': 'table',
      'display': 'Tables & Desks',
      'icon': Icons.table_restaurant,
      'color': Colors.brown,
      'image': 'https://images.unsplash.com/photo-1530018607912-eff2daa1bac4?auto=format&fit=crop&q=80&w=400',
    },
    {
      'name': 'lighting',
      'display': 'Lighting',
      'icon': Icons.light,
      'color': Colors.amber,
      'image': 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?auto=format&fit=crop&q=80&w=400',
    },
    {
      'name': 'decor',
      'display': 'Decor & Art',
      'icon': Icons.color_lens,
      'color': Colors.purple,
      'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&q=80&w=400',
    },
    {
      'name': 'storage',
      'display': 'Storage & Shelving',
      'icon': Icons.kitchen,
      'color': Colors.teal,
      'image': 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&q=80&w=400',
    },
    {
      'name': 'rugs',
      'display': 'Rugs & Carpets',
      'icon': Icons.layers,
      'color': Colors.deepOrange,
      'image': 'https://images.unsplash.com/photo-1600166898405-da9535204843?auto=format&fit=crop&q=80&w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Catalogue'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Explore Items',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fade().slideX(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'Find the perfect pieces for your space from our curated collection.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ).animate().fade(delay: 200.ms).slideX(begin: -0.2),
              const SizedBox(height: 32),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
                children: List.generate(_categories.length, (index) {
                  final cat = _categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CatalogueItemsScreen(categoryName: cat['name']),
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category preview image
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              child: Image.network(
                                cat['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: (cat['color'] as Color).withOpacity(0.1),
                                  child: Icon(cat['icon'], size: 48, color: cat['color']),
                                ),
                              ),
                            ),
                          ),
                          // Category label
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  cat['display'],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: (300 + index * 50).ms).scale(),
                  );
                }),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
