import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/assistance_selection_screen.dart';
import 'package:vibe_up/screens/project/full_floor_plan_screen.dart';

class RoomTilesScreen extends StatefulWidget {
  final String projectId;
  final String floorPlanUrl;
  final List<Map<String, dynamic>> detectedRooms;
  final String? houseType;

  const RoomTilesScreen({
    super.key,
    required this.projectId,
    required this.floorPlanUrl,
    required this.detectedRooms,
    this.houseType,
  });

  @override
  State<RoomTilesScreen> createState() => _RoomTilesScreenState();
}

class _RoomTilesScreenState extends State<RoomTilesScreen> {
  late List<Map<String, dynamic>> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = widget.detectedRooms.map((r) {
      return {
        ...r,
        'isDesigned': false,
      };
    }).toList();
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'bedroom':
        return Icons.bed_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'living':
        return Icons.weekend_outlined;
      case 'bathroom':
        return Icons.bathtub_outlined;
      case 'dining':
        return Icons.restaurant_outlined;
      case 'office':
        return Icons.computer_outlined;
      case 'hallway':
        return Icons.meeting_room_outlined;
      case 'balcony':
        return Icons.balcony_outlined;
      case 'storage':
        return Icons.inventory_2_outlined;
      default:
        return Icons.room_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'bedroom':
        return const Color(0xFF7B68EE);
      case 'kitchen':
        return const Color(0xFFFF7043);
      case 'living':
        return const Color(0xFF4CAF50);
      case 'bathroom':
        return const Color(0xFF29B6F6);
      case 'dining':
        return const Color(0xFFFFCA28);
      case 'office':
        return const Color(0xFF78909C);
      case 'hallway':
        return const Color(0xFFAB47BC);
      case 'balcony':
        return const Color(0xFF26A69A);
      case 'storage':
        return const Color(0xFF8D6E63);
      default:
        return AppTheme.primaryAccent;
    }
  }

  int get _designedCount => _rooms.where((r) => r['isDesigned'] == true).length;

  void _onRoomTap(int index) async {
    final room = _rooms[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssistanceSelectionScreen(
          projectId: widget.projectId,
          projectName: room['name'],
          projectData: {
            'room_type': room['type'],
            'room_name': room['name'],
            'approximate_area_sqft': room['approximate_area_sqft'],
            'width_ft': room['width_ft'] ?? 12,
            'length_ft': room['length_ft'] ?? 12,
          },
          isFloorPlanMode: true,
        ),
      ),
    );

    // Mark room as designed when user returns
    if (mounted) {
      if (result != null && result is Map && result['success'] == true) {
        setState(() {
          _rooms[index]['isDesigned'] = true;
          _rooms[index]['items'] = result['items'];
          _rooms[index]['budget'] = result['budget'];
          _rooms[index]['sceneData'] = result['sceneData'];
        });
      } else if (result == true) {
        setState(() {
          _rooms[index]['isDesigned'] = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Blueprint Layout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textDim),
            tooltip: 'Revise Dimensions',
          ),
          const SizedBox(width: 8),
          if (_designedCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 12),
                    const SizedBox(width: 8),
                    Text(
                      '$_designedCount/${_rooms.length} DONE',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF4CAF50),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artisan Blueprint',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(
                  'We\'ve synthesized ${_rooms.length} distinct spaces. Select a room to begin the bespoke design journey.',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                ).animate().fade(delay: 100.ms),
              ],
            ),
          ),

          // Room Tiles Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                final type = room['type'] ?? 'general';
                final name = room['name'] ?? 'Room ${index + 1}';
                final area = room['approximate_area_sqft'] ?? 0;
                final isDesigned = room['isDesigned'] == true;
                final color = _getColorForType(type);

                return GestureDetector(
                  onTap: () => _onRoomTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDesigned
                          ? const LinearGradient(
                              colors: [Color(0xFF1B2A1E), Color(0xFF121212)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : AppTheme.cardGradient,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDesigned
                            ? const Color(0xFF4CAF50).withOpacity(0.4)
                            : Colors.white.withOpacity(0.06),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _getIconForType(type),
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              // Room Name
                              Text(
                                name.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              // Area
                              Text(
                                '$area SQ FT',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: isDesigned ? const Color(0xFF4CAF50).withOpacity(0.7) : AppTheme.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Designed badge
                        if (isDesigned)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.done_all_rounded, size: 12, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: (100 * index).ms).scale(begin: const Offset(0.9, 0.9), duration: 500.ms, curve: Curves.easeOutBack);
              },
            ),
          ),

          // Bottom Action Panel
          Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, -10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _designedCount > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullFloorPlanScreen(
                                  projectId: widget.projectId,
                                  floorPlanUrl: widget.floorPlanUrl,
                                  designedRooms: _rooms,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white.withOpacity(0.05),
                      disabledForegroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: _designedCount > 0 ? 8 : 0,
                      shadowColor: AppTheme.primaryAccent.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.architecture_rounded, size: 22),
                        const SizedBox(width: 14),
                        Text(
                          'MASTERPIECE VIEW',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_designedCount == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'DESIGN AT LEAST ONE ROOM TO FINALIZE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textDim, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ).animate().fadeIn(),
              ],
            ),
          ).animate().slideY(begin: 0.2),
        ],
      ),
    );
  }
}
