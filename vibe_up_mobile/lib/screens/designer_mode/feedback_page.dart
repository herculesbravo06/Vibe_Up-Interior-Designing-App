import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:intl/intl.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _isLoading = true;
  List<dynamic> _reviews = [];
  double _averageRating = 0.0;
  Map<int, int> _ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};


  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
    
    // Setup real-time polling every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadFeedback(isSilent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFeedback({bool isSilent = false}) async {
    try {
      if (!isSilent && mounted) {
        setState(() => _isLoading = true);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final designerId = prefs.getString('user_id');

      if (designerId != null) {
        final reviews = await ApiService.getDesignerFeedback(designerId);
        
        if (mounted) {
          setState(() {
            _reviews = reviews;
            _calculateStats();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateStats() {
    if (_reviews.isEmpty) return;

    double totalRating = 0;
    _ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var review in _reviews) {
      int rating = int.tryParse(review['rating']?.toString() ?? '5') ?? 5;
      totalRating += rating;
      if (_ratingCounts.containsKey(rating)) {
        _ratingCounts[rating] = _ratingCounts[rating]! + 1;
      }
    }

    _averageRating = totalRating / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Management Overview",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: AppTheme.glassDecoration,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryAccent, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: AppTheme.glassDecoration,
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppTheme.primaryAccent, size: 20),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _loadFeedback,
              color: AppTheme.primaryAccent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Service Performance", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),
                    
                    /// RATING CARD (Luxury Redesign)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Row(
                        children: [
                          /// LEFT SIDE
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => AppTheme.goldGradient.createShader(bounds),
                                    child: Text(
                                      _reviews.isEmpty ? "0.0" : _averageRating.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text("/ 5.0",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.primaryAccent.withOpacity(0.7),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (index) {
                                  if (index < _averageRating.floor()) {
                                    return const Icon(Icons.star_rounded, color: AppTheme.primaryAccent, size: 22);
                                  } else if (index < _averageRating && _averageRating % 1 != 0) {
                                    return const Icon(Icons.star_half_rounded, color: AppTheme.primaryAccent, size: 22);
                                  } else {
                                    return Icon(Icons.star_border_rounded, color: AppTheme.textDim.withOpacity(0.3), size: 22);
                                  }
                                }),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "BASED ON ${_reviews.length} CLIENTS",
                                style: GoogleFonts.inter(
                                    color: AppTheme.textDim,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1),
                              )
                            ],
                          ),
                          const SizedBox(width: 32),
                          /// RIGHT SIDE BARS
                          Expanded(
                            child: Column(
                              children: [
                                _ratingBar("5", _reviews.isEmpty ? 0 : (_ratingCounts[5]! / _reviews.length)),
                                _ratingBar("4", _reviews.isEmpty ? 0 : (_ratingCounts[4]! / _reviews.length)),
                                _ratingBar("3", _reviews.isEmpty ? 0 : (_ratingCounts[3]! / _reviews.length)),
                                _ratingBar("2", _reviews.isEmpty ? 0 : (_ratingCounts[2]! / _reviews.length)),
                                _ratingBar("1", _reviews.isEmpty ? 0 : (_ratingCounts[1]! / _reviews.length)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.1),
                    
                    const SizedBox(height: 32),
                    
                    /// FILTER BUTTONS
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterButton("All Reviews", true),
                          const SizedBox(width: 12),
                          _filterButton("Top Rated", false),
                          const SizedBox(width: 12),
                          _filterButton("Recent", false),
                        ],
                      ),
                    ).animate().fade(delay: 200.ms),
                    
                    const SizedBox(height: 40),
                    
                    /// TITLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Client Success Stories",
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const Icon(Icons.sort_rounded, color: AppTheme.primaryAccent, size: 22)
                      ],
                    ).animate().fade(delay: 300.ms),
                    
                    const SizedBox(height: 20),
                    
                    /// REVIEW CARDS
                    if (_reviews.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Column(
                            children: [
                              Icon(Icons.rate_review_outlined, size: 48, color: AppTheme.textDim.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text("No feedback received yet.",
                                  style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._reviews.asMap().entries.map((entry) {
                        final index = entry.key;
                        final review = entry.value;
                        return _reviewCard(
                          review['user_name'] ?? 'Anonymous Client',
                          'PREMIUM PROJECT', 
                          review['comment'] ?? '',
                          _formatDate(review['created_at']),
                          'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=800', 
                          double.tryParse(review['rating']?.toString() ?? '5') ?? 5.0,
                          index,
                        );
                      }).toList(),
                    const SizedBox(height: 100)
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return 'Recent';
    }
  }

  /// REVIEW CARD (Luxury Redesign)
  Widget _reviewCard(
    String name,
    String project,
    String reviewText,
    String date,
    String image,
    double rating,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.2), offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE WITH OVERLAYS
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.05),
                    child: const Icon(Icons.image_rounded, color: AppTheme.textDim, size: 40),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.primaryAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              )
            ],
          ),
          /// TEXT CONTENT
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text(
                      date.toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textDim, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  project,
                  style: GoogleFonts.inter(
                      color: AppTheme.primaryAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 14),
                Text(
                  reviewText,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "VIEW PROJECT DETAILS →",
                    style: GoogleFonts.poppins(
                        color: AppTheme.primaryAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ).animate().fade(delay: (400 + index * 100).ms).slideY(begin: 0.1);
  }

  /// FILTER BUTTON
  Widget _filterButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? AppTheme.primaryAccent : AppTheme.textDim.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            color: active ? Colors.black : AppTheme.textDim,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }

  /// RATING BAR
  Widget _ratingBar(String star, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(star, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDim, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: AppTheme.primaryAccent,
                minHeight: 6,
              ),
            ),
          )
        ],
      ),
    );
  }
}
