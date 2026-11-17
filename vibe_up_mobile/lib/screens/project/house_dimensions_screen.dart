import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/room_tiles_screen.dart';

class HouseDimensionsScreen extends StatefulWidget {
  final String houseType;
  final List<Map<String, dynamic>> initialRooms;

  const HouseDimensionsScreen({
    super.key,
    required this.houseType,
    required this.initialRooms,
  });

  @override
  State<HouseDimensionsScreen> createState() => _HouseDimensionsScreenState();
}

class _HouseDimensionsScreenState extends State<HouseDimensionsScreen> {
  late List<Map<String, dynamic>> _rooms;
  late List<TextEditingController> _widthControllers;
  late List<TextEditingController> _lengthControllers;

  @override
  void initState() {
    super.initState();
    _rooms = List<Map<String, dynamic>>.from(widget.initialRooms.map((e) => Map<String, dynamic>.from(e)));
    _widthControllers = [];
    _lengthControllers = [];

    for (var r in _rooms) {
      final w = r['width_ft'] ?? 12;
      final l = r['length_ft'] ?? 12;
      r['width_ft'] = w;
      r['length_ft'] = l;
      r['approximate_area_sqft'] = w * l;
      
      _widthControllers.add(TextEditingController(text: w.toString()));
      _lengthControllers.add(TextEditingController(text: l.toString()));
    }
  }

  @override
  void dispose() {
    for (var c in _widthControllers) c.dispose();
    for (var c in _lengthControllers) c.dispose();
    super.dispose();
  }

  void _submit() {
    for (int i = 0; i < _rooms.length; i++) {
      int w = int.tryParse(_widthControllers[i].text) ?? 12;
      int l = int.tryParse(_lengthControllers[i].text) ?? 12;
      _rooms[i]['width_ft'] = w;
      _rooms[i]['length_ft'] = l;
      _rooms[i]['approximate_area_sqft'] = w * l;
      _rooms[i]['isDesigned'] = false;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomTilesScreen(
          projectId: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a macro house ID
          floorPlanUrl: 'whole_house', // identifier for full house mode
          detectedRooms: _rooms,
          houseType: widget.houseType, // Pass houseType back to room tiles
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${widget.houseType} Dimensions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Text(
                'Enter the dimensions for each room. A default of 12x12 is provided.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1E1E2A),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.meeting_room_outlined, color: AppTheme.primaryAccent, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                _rooms[index]['name'],
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _widthControllers[index],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Width (ft)',
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.black26,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _lengthControllers[index],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Length (ft)',
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.black26,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: (index * 50).ms).slideY(begin: 0.1);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppTheme.primaryAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _submit,
                child: Text('Save & Start Designing', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
