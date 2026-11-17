import 'package:vibe_up/theme/app_theme.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:vibe_up/screens/catalogue/wishlist_screen.dart';

class CatalogueItemsScreen extends StatefulWidget {
  final String categoryName;
  const CatalogueItemsScreen({super.key, required this.categoryName});

  @override
  State<CatalogueItemsScreen> createState() => _CatalogueItemsScreenState();
}

class _CatalogueItemsScreenState extends State<CatalogueItemsScreen> {
  List<dynamic> _items = [];
  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isLoading = true;

  // Categorized image pools for visual accuracy
  static const Map<String, List<String>> _categorizedImages = {
    'sofa': [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
      'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=400',
      'https://images.unsplash.com/photo-1567016432779-094069958ea5?w=400',
    ],
    'table': [
      'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=400',
      'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
      'https://images.unsplash.com/photo-1530018607912-eff2daa1bac4?w=400',
    ],
    'lighting': [
      'https://images.unsplash.com/photo-1542728929-14a3ccd60698?w=400',
      'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=400',
      'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=400',
    ],
    'decor': [
      'https://images.unsplash.com/photo-1586105251261-72a756497a11?w=400',
      'https://images.unsplash.com/photo-1513161455079-7dc1e15efcd4?w=400',
      'https://images.unsplash.com/photo-1581783898377-1c85bf937427?w=400',
    ],
    'rugs': [
      'https://images.unsplash.com/photo-1600166898405-da9535204843?w=400',
      'https://images.unsplash.com/photo-1575414003591-ece8d0416c7a?w=400',
      'https://images.unsplash.com/photo-1589311142503-467f53f3e1a8?w=400',
    ],
    'beds': [
      'https://images.unsplash.com/photo-1505693415918-91e51bdd219b?w=400',
      'https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=400',
      'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=400',
    ],
  };

  // General furniture images for other categories
  static const List<String> _furnitureImages = [
    'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400',
    'https://images.unsplash.com/photo-1583847268964-b28ce8f31586?w=400',
    'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=400',
    'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=400',
    'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400',
    'https://images.unsplash.com/photo-1513161455079-7dc1e15efcd4?w=400',
    'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=400',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString('wishlist_items');
    if (itemsJson != null) {
      final decoded = jsonDecode(itemsJson) as List;
      if (mounted) {
        setState(() {
          _wishlistItems = List<Map<String, dynamic>>.from(decoded);
        });
      }
    }
  }

  Future<void> _addToWishlist(dynamic item, String imageUrl) async {
    final newItem = Map<String, dynamic>.from(item);
    newItem['image_url'] = imageUrl; // Guarantee the image is saved properly
    
    setState(() {
      _wishlistItems.add(newItem);
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist_items', jsonEncode(_wishlistItems));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Wishlist!')));
    }
  }

  Future<void> _loadItems() async {
    try {
      final items = await ApiService.getItems(category: widget.categoryName);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getImageForItem(dynamic item, int index) {
    // 1. Try to get image from API response if available
    if (item['images'] != null && item['images'] is List && (item['images'] as List).isNotEmpty) {
      final img = (item['images'] as List).first.toString();
      if (img.startsWith('http')) return img;
    }
    
    // 2. Select from the correct category pool
    String categoryKey = widget.categoryName.toLowerCase();
    
    // Exact match or fallback for plurals/singulars
    List<String>? pool;
    if (_categorizedImages.containsKey(categoryKey)) {
      pool = _categorizedImages[categoryKey];
    } else if (categoryKey.endsWith('s') && _categorizedImages.containsKey(categoryKey.substring(0, categoryKey.length - 1))) {
      pool = _categorizedImages[categoryKey.substring(0, categoryKey.length - 1)];
    } else if (!categoryKey.endsWith('s') && _categorizedImages.containsKey(categoryKey + 's')) {
      pool = _categorizedImages[categoryKey + 's'];
    }
    
    // Use the pool or general furniture images
    final currentPool = pool ?? _furnitureImages;
    final selectionIndex = index % currentPool.length;
    
    return currentPool[selectionIndex];
  }

  String _getDisplayName() {
    final names = {
      'sofa': 'Sofas & Seating',
      'table': 'Tables & Desks',
      'lighting': 'Lighting',
      'decor': 'Decor & Art',
      'storage': 'Storage & Shelving',
      'rugs': 'Rugs & Carpets',
    };
    return names[widget.categoryName] ?? widget.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getDisplayName()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No items in this category', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Check back soon for new arrivals!', style: TextStyle(color: AppTheme.textDim)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final imageUrl = _getImageForItem(item, index);
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            child: Image.network(
                              imageUrl,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 220,
                                color: AppTheme.cardColor,
                                child: const Icon(Icons.image, size: 48, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Item',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (item['material'] != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item['material'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        '${item['currency'] ?? 'INR'} ${double.tryParse(item['price'].toString())?.toStringAsFixed(2) ?? item['price']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: IconButton(
                                    icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                                    onPressed: () {
                                      _addToWishlist(item, imageUrl);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: (200 + index * 100).ms).slideY(begin: 0.1);
                  },
                ),
      bottomNavigationBar: _wishlistItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                    _loadWishlist(); // refresh in case items were removed
                  },
                  icon: const Icon(Icons.favorite),
                  label: Text('View Wishlist (${_wishlistItems.length})', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
    );
  }
}
