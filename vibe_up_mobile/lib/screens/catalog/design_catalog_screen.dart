import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/utils/catalog_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vibe_up/services/api_service.dart';


class DesignCatalogScreen extends StatefulWidget {
  const DesignCatalogScreen({super.key});

  @override
  State<DesignCatalogScreen> createState() => _DesignCatalogScreenState();
}

class _DesignCatalogScreenState extends State<DesignCatalogScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _activeSubCategory;
  final Set<String> _wishlist = {};


  void _onCategoryTap(String subName) {
    setState(() {
      _activeSubCategory = _activeSubCategory == subName ? null : subName;
    });
  }

  void _toggleWishlist(String id) {
    setState(() {
      if (_wishlist.contains(id)) {
        _wishlist.remove(id);
      } else {
        _wishlist.add(id);
      }
    });
  }

  double get _totalPrice {
    double total = 0;
    for (var cat in _categories) {
      for (var sub in cat['sub']) {
        for (var item in sub['items']) {
          if (_wishlist.contains(item['id'])) {
            total += (item['price'] as num).toDouble();
          }
        }
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadSyncData();
  }

  Future<void> _loadSyncData() async {
    try {
      final syncData = await ApiService.getSyncedCatalogue();
      if (syncData.isNotEmpty) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(syncData);
          _tabController = TabController(length: _categories.length, vsync: this);
          _isLoading = false;
        });
      } else {
        // Fallback to local data if API fails or returns empty
        setState(() {
          _categories = CatalogData.categories;
          _tabController = TabController(length: _categories.length, vsync: this);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _categories = CatalogData.categories;
        _tabController = TabController(length: _categories.length, vsync: this);
        _isLoading = false;
        _errorMessage = "Using offline catalogue.";
      });
    }
  }


  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Design Catalogue',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
          bottom: _tabController == null ? null : TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryAccent,
          labelColor: AppTheme.primaryAccent,
          unselectedLabelColor: Colors.white60,
          tabs: _categories.map((cat) => Tab(
            icon: Icon(_getIconForCategory(cat['title'])),
            text: cat['title'],
          )).toList(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent))
        : Column(
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  color: Colors.orange.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.orange, fontSize: 10)),
                ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              
              if (_tabController != null)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _categories.map((cat) => _buildCategoryView(cat)).toList(),
                  ),
                ),
            ],
          ),


      floatingActionButton: _wishlist.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCheckoutDialog(),
              backgroundColor: AppTheme.primaryAccent,
              icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.black),
              label: Text(
                'Total: ₹${_totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildCategoryView(Map<String, dynamic> category) {
    final List subCats = category['sub'];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subCats.length,
      itemBuilder: (context, index) {
        final sub = subCats[index];
        final bool isExpanded = _activeSubCategory == sub['name'];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _onCategoryTap(sub['name']),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sub['name'],
                      style: GoogleFonts.poppins(
                        color: isExpanded ? AppTheme.primaryAccent : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: isExpanded ? AppTheme.primaryAccent : Colors.white54,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: (sub['items'] as List).length,
                itemBuilder: (context, i) {
                  final item = sub['items'][i];
                  return _buildItemCard(item, category['title']);
                },
              ),
            if (!isExpanded)
              const Divider(color: Colors.white10),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, String type) {
    final String name = item['name'];
    final int price = item['price'];
    final String id = item['id'];
    final bool isWishlisted = _wishlist.contains(id);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWishlisted ? AppTheme.primaryAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: (item['images'] != null && (item['images'] as List).isNotEmpty)
                      ? Image.network(
                          (item['images'] as List)[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getIconForItem(name),
                            color: AppTheme.primaryAccent,
                            size: 40,
                          ),
                        )
                      : Image.asset(
                          _getImageForItem(name, type),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getIconForItem(name),
                            color: AppTheme.primaryAccent,
                            size: 40,
                          ),
                        ),

                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹$price',
                      style: GoogleFonts.inter(
                        color: AppTheme.primaryAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Approx. Pricing',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              onPressed: () => _toggleWishlist(id),
              icon: Icon(
                isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isWishlisted ? Colors.redAccent : Colors.white24,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Design Estimate', 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryAccent, size: 50),
              const SizedBox(height: 20),
              Text(
                'You have selected ${_wishlist.length} items for your design wishlist.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimated Total:', style: GoogleFonts.inter(color: Colors.white70)),
                    Text('₹${_totalPrice.toStringAsFixed(0)}', 
                      style: GoogleFonts.poppins(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
      const SizedBox(height: 10),
              Text(
                '*Prices are approximate market rates in India.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add More', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _generatePDF();
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.black),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryAccent),
            label: const Text('Download PDF', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final List<Map<String, dynamic>> selectedItems = [];
    
    for (var cat in _categories) {
      for (var sub in cat['sub']) {
        for (var item in sub['items']) {
          if (_wishlist.contains(item['id'])) {
            selectedItems.add(item);
          }
        }
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('VibeUp Interior Design Estimate', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Item Name', 'Category', 'Approx. Price (INR)'],
                data: selectedItems.map((item) {
                  // Find category name
                  String catName = 'Interior';
                  for (var cat in _categories) {
                    for (var sub in cat['sub']) {
                      if (sub['items'].contains(item)) {
                        catName = sub['name'];
                      }
                    }
                  }
                  return [item['name'], catName, 'Rs. ${item['price']}'];
                }).toList(),
              ),
              pw.Divider(),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Estimated Total: Rs. ${_totalPrice.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text('Note: This is an approximate estimate based on market rates in India. Final pricing may vary based on materials, customization, and brand selection.'),
              pw.SizedBox(height: 20),
              pw.Text('VibeUp AI - Transform Your Space', style: pw.TextStyle(color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  IconData _getIconForCategory(String title) {
    if (title.contains('Construction')) return Icons.home_work_rounded;
    if (title.contains('Interior')) return Icons.chair_rounded;
    if (title.contains('Exterior')) return Icons.park_rounded;
    return Icons.category_rounded;
  }

  IconData _getIconForItem(String name) {

    if (name.contains('Sofa')) return Icons.chair_rounded;
    if (name.contains('Bed')) return Icons.bed_rounded;
    if (name.contains('Room')) return Icons.crop_square_rounded;
    if (name.contains('Door')) return Icons.door_front_door_rounded;
    if (name.contains('Window')) return Icons.window_rounded;
    if (name.contains('Table')) return Icons.table_restaurant_rounded;
    if (name.contains('Tree') || name.contains('Bush') || name.contains('Palm')) return Icons.park_outlined;
    if (name.contains('Pool')) return Icons.pool_rounded;
    if (name.contains('Kitchen') || name.contains('Cabinet')) return Icons.kitchen_rounded;
    return Icons.category_outlined;
  }

  String _getImageForItem(String name, String type) {
    final n = name.toLowerCase();
    if (n.contains('sofa') || n.contains('armchair') || n.contains('couch')) return 'assets/catalog/sofa.png';
    if (n.contains('bed')) return 'assets/catalog/bed.png';
    if (n.contains('tree') || n.contains('palm') || n.contains('bush') || n.contains('plant')) return 'assets/catalog/tree.png';
    if (type == 'Construction') return 'assets/catalog/house_frame.png';
    return 'assets/catalog/item_placeholder.png';
  }
}
