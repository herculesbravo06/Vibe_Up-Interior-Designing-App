import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/plan_save_screen.dart';
import 'package:vibe_up/screens/project/full_house_3d_screen.dart';

class FullFloorPlanScreen extends StatefulWidget {
  final String projectId;
  final String floorPlanUrl;
  final List<Map<String, dynamic>> designedRooms;

  const FullFloorPlanScreen({
    super.key,
    required this.projectId,
    required this.floorPlanUrl,
    required this.designedRooms,
  });

  @override
  State<FullFloorPlanScreen> createState() => _FullFloorPlanScreenState();
}

class _FullFloorPlanScreenState extends State<FullFloorPlanScreen> {
  bool _show3D = false;
  late List<Map<String, dynamic>> _rooms;
  final double _scaleFtToPx = 15.0; // 1 ft = 15 pixels

  @override
  void initState() {
    super.initState();
    // Initialize starting positions for each room in a grid layout to avoid overlap initially
    _rooms = List<Map<String, dynamic>>.from(widget.designedRooms.map((e) => Map<String, dynamic>.from(e)));
    double currentX = 50.0;
    double currentY = 50.0;
    double maxHeightInRow = 0.0;
    
    for (int i = 0; i < _rooms.length; i++) {
        final w = ((_rooms[i]['width_ft'] as num?)?.toDouble() ?? 12) * _scaleFtToPx;
        final h = ((_rooms[i]['length_ft'] as num?)?.toDouble() ?? 12) * _scaleFtToPx;
        
        _rooms[i]['pos_x'] = _rooms[i]['pos_x'] ?? currentX;
        _rooms[i]['pos_y'] = _rooms[i]['pos_y'] ?? currentY;

        currentX += w + 20; // 20px gap
        maxHeightInRow = h > maxHeightInRow ? h : maxHeightInRow;

        if (currentX > 500) { // wrap row
            currentX = 50.0;
            currentY += maxHeightInRow + 20;
            maxHeightInRow = 0.0;
        }
    }
  }

  double get _totalBudget {
    double total = 0;
    for (final room in _rooms) {
      total += (room['budget'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'bedroom': return Icons.bed_outlined;
      case 'kitchen': return Icons.kitchen_outlined;
      case 'living': return Icons.weekend_outlined;
      case 'bathroom': return Icons.bathtub_outlined;
      case 'dining': return Icons.restaurant_outlined;
      case 'office': return Icons.computer_outlined;
      case 'hallway': return Icons.meeting_room_outlined;
      case 'balcony': return Icons.balcony_outlined;
      default: return Icons.room_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'bedroom': return const Color(0xFF7B68EE);
      case 'kitchen': return const Color(0xFFFF7043);
      case 'living': return const Color(0xFF4CAF50);
      case 'bathroom': return const Color(0xFF29B6F6);
      case 'dining': return const Color(0xFFFFCA28);
      case 'office': return const Color(0xFF78909C);
      default: return AppTheme.primaryAccent;
    }
  }

  void _showEditRoomDialog(int roomIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final room = _rooms[roomIndex];
            final items = (room['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room['name']?.toUpperCase() ?? 'ROOM DETAILS',
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, letterSpacing: 1),
                            ),
                            Text(
                              '${items.length} CURATED ITEMS',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryAccent, letterSpacing: 2),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(_getIconForType(room['type'] ?? ''), color: AppTheme.primaryAccent, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              'NO ITEMS PLACED IN THIS SEGMENT',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDim, letterSpacing: 1),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final item = items[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.architecture_rounded, color: AppTheme.primaryAccent, size: 20),
                                  ),
                                  title: Text(
                                    item['name']?.toUpperCase() ?? 'INTERIOR ITEM',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, letterSpacing: 0.5),
                                  ),
                                  subtitle: Text(
                                    'VALUATION: ₹ ${item['price']}',
                                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDim, fontWeight: FontWeight.w600),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFFF6B6B), size: 22),
                                    onPressed: () {
                                      setModalState(() {
                                        items.removeAt(i);
                                        room['items'] = items;
                                        double newBudget = 0;
                                        for (var it in items) newBudget += (it['price'] as num?)?.toDouble() ?? 0;
                                        room['budget'] = newBudget;
                                        
                                        if (room['sceneData'] != null) {
                                          try {
                                            final Map<String, dynamic> sceneObj = jsonDecode(room['sceneData']);
                                            final sceneItems = sceneObj['items'] as List;
                                            if (i < sceneItems.length) {
                                              sceneItems.removeAt(i);
                                              room['sceneData'] = jsonEncode(sceneObj);
                                            }
                                          } catch(_) {}
                                        }
                                      });
                                      setState(() {}); // refresh parent UI
                                    },
                                  ),
                                ),
                              ).animate().fade(delay: (i * 100).ms).slideX(begin: 0.1);
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.white10)),
                        ),
                        child: Text('CLOSE SEGMENT', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.5)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          'ARCHITECTURAL MASTERPIECE',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                '${widget.designedRooms.length} SEGMENTS',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(
              'ORCHESTRATE YOUR SPACE',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryAccent,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Combined Visualization Area (Luxury Canvas)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Grid Background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),

                    // Interactive 2D Workspace
                    InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(500),
                      minScale: 0.1,
                      maxScale: 3.0,
                      constrained: false,
                      child: Container(
                        width: 1500,
                        height: 1500,
                        child: Stack(
                          children: _rooms.asMap().entries.map((entry) {
                            final index = entry.key;
                            final room = entry.value;
                            final type = room['type'] ?? 'living';
                            final color = _getColorForType(type);
                            
                            final wPx = ((room['width_ft'] as num?)?.toDouble() ?? 12) * _scaleFtToPx;
                            final hPx = ((room['length_ft'] as num?)?.toDouble() ?? 12) * _scaleFtToPx;
                            
                            return Positioned(
                              left: room['pos_x'],
                              top: room['pos_y'],
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    double newX = room['pos_x'] + details.delta.dx;
                                    double newY = room['pos_y'] + details.delta.dy;
                                    room['pos_x'] = (newX / 5).round() * 5.0; // Finer snapping
                                    room['pos_y'] = (newY / 5).round() * 5.0;
                                  });
                                },
                                child: Container(
                                  width: wPx,
                                  height: hPx,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: color.withOpacity(0.8), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)
                                    ],
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: color.withOpacity(0.2), width: 0.5),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(_getIconForType(type), color: color, size: wPx > 50 ? 20 : 12),
                                          if (wPx > 70 && hPx > 50) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              room['name']?.toUpperCase() ?? 'ROOM',
                                              style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Overlay Labels
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          'SYNTHESIZED BLUEPRINT',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.05),

          // Budget & Project Actions Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, -10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'VALUATION PORTFOLIO',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppTheme.textDim,
                      ),
                    ),
                    Text(
                      '₹ ${_totalBudget.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryAccent,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Main Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullHouse3DScreen(rooms: _rooms),
                            ),
                          );
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.view_in_ar_rounded, color: Colors.black, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                '3D MASTERPIECE',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: IconButton(
                        onPressed: () => _showEditRoomDialog(0), // Simplified: just open first room for demo or update logic
                        icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryAccent, size: 28),
                        tooltip: 'Manage Segments',
                      ),
                    ),
                  ],
                ).animate().fade(delay: 400.ms).slideX(begin: 0.1),

                const SizedBox(height: 16),

                // Save Project Button
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlanSaveScreen(
                            rooms: _rooms,
                            placedItems: _rooms.expand<Map<String, dynamic>>(
                              (r) => (r['items'] as List<Map<String, dynamic>>?) ?? [],
                            ).toList(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      foregroundColor: AppTheme.textPrimary,
                      elevation: 0,
                      side: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'PERSIST TO PORTFOLIO',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
