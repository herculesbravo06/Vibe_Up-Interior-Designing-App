import 'package:vibe_up/theme/app_theme.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistJson = prefs.getString('wishlist_items');
    if (wishlistJson != null) {
      final List<dynamic> decoded = jsonDecode(wishlistJson);
      setState(() {
        _wishlistItems = List<Map<String, dynamic>>.from(decoded);
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removeFromWishlist(int index) async {
    setState(() {
      _wishlistItems.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist_items', jsonEncode(_wishlistItems));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from wishlist')),
      );
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in _wishlistItems) {
      final priceStr = item['price']?.toString() ?? '0';
      final price = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      total += price;
    }
    return total;
  }

  Future<void> _generatePdf() async {
    if (_wishlistItems.isEmpty) return;

    final pdf = pw.Document();
    final total = _calculateTotal();
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('VibeUp - Estimate / Wishlist', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 30),
              
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                headerHeight: 25,
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                },
                headers: ['Item No.', 'Item Details', 'Estimated Price'],
                data: List<List<String>>.generate(
                  _wishlistItems.length,
                  (row) {
                    final item = _wishlistItems[row];
                    final name = item['name'] ?? item['item_name'] ?? 'Unknown Item';
                    final category = item['category'] ?? '';
                    final priceStr = item['price']?.toString() ?? '0';
                    final price = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                    
                    return [
                      (row + 1).toString(),
                      '$name\n[$category]',
                      formatCurrency.format(price),
                    ];
                  },
                ),
              ),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 10),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total Estimate: ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(formatCurrency.format(total), style: pw.TextStyle(fontSize: 18, color: PdfColors.green800, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 50),
              pw.Text('Note: This is an approximate estimate based on catalogue list prices.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    // Prompt user to save/share the PDF file
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'vibeup_wishlist_estimate.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: AppTheme.textDim),
                      const SizedBox(height: 16),
                      Text('Your wishlist is empty', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text('Add items from the catalogue to see them here', style: TextStyle(color: AppTheme.textDim)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = _wishlistItems[index];
                    final name = item['name'] ?? item['item_name'] ?? 'Unknown';
                    final price = item['price']?.toString() ?? 'Ask for price';
                    final image = item['image'] ?? item['image_url'] ?? '';
                    final desc = item['description'] ?? item['details'] ?? 'No description available';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: image.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: image.startsWith('http') ? image : 'http://192.168.1.8/scratch/admin_panel/$image',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: AppTheme.cardColor, width: 80, height: 80, child: const Icon(Icons.image, color: Colors.grey)),
                                      errorWidget: (context, url, error) => Container(color: AppTheme.cardColor, width: 80, height: 80, child: const Icon(Icons.broken_image, color: Colors.grey)),
                                    )
                                  : Container(color: AppTheme.cardColor, width: 80, height: 80, child: const Icon(Icons.image, color: Colors.grey)),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    desc,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$$price',
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            // Remove button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removeFromWishlist(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _wishlistItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Total', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_calculateTotal()),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _generatePdf,
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Download PDF'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
