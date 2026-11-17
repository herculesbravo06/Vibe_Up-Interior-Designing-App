import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/services/api_service.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String categoryName;
  const CategoryItemsScreen({super.key, required this.categoryName});

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  static const List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1532372320572-cda25653a26d?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1586105251261-72a756497a11?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1501045661006-fcebe0257c3f?q=80&w=200&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
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

  String _getImageUrl(dynamic item, int index) {
    if (item['images'] != null && item['images'] is List && (item['images'] as List).isNotEmpty) {
      final img = (item['images'] as List).first.toString();
      if (img.startsWith('http')) return img;
    }
    return _fallbackImages[index % _fallbackImages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.primaryAccent.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No items found', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final imageUrl = _getImageUrl(item, index);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.textDim.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDetail,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? 'Item ${index + 1}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['material'] ?? 'Premium quality',
                                  style: const TextStyle(color: AppTheme.textDim, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item['currency'] ?? 'INR'} ${double.tryParse(item['price'].toString())?.toStringAsFixed(2) ?? item['price']}',
                                      style: const TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Icon(Icons.add_shopping_cart, color: AppTheme.textLight.withOpacity(0.7)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: (100 + index * 80).ms).slideX(begin: 0.1);
                  },
                ),
    );
  }
}
