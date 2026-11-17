import 'package:vibe_up/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/screens/project/room_tiles_screen.dart';

class RoomValidationScreen extends StatefulWidget {
  final String projectId;
  final String floorPlanUrl;
  final List<Map<String, dynamic>> detectedRooms;

  const RoomValidationScreen({
    super.key,
    required this.projectId,
    required this.floorPlanUrl,
    required this.detectedRooms,
  });

  @override
  State<RoomValidationScreen> createState() => _RoomValidationScreenState();
}

class _RoomValidationScreenState extends State<RoomValidationScreen> {
  late List<Map<String, dynamic>> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = List<Map<String, dynamic>>.from(widget.detectedRooms.map((e) => Map<String, dynamic>.from(e)));
  }

  void _editRoom(int index) {
    final room = _rooms[index];
    final nameCtrl = TextEditingController(text: room['name']);
    final widthCtrl = TextEditingController(text: room['width_ft'].toString());
    final lengthCtrl = TextEditingController(text: room['length_ft'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text('Edit Room', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Room Name'),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: widthCtrl,
              decoration: const InputDecoration(labelText: 'Width (ft)'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: lengthCtrl,
              decoration: const InputDecoration(labelText: 'Length (ft)'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _rooms[index]['name'] = nameCtrl.text;
                _rooms[index]['width_ft'] = int.tryParse(widthCtrl.text) ?? 12;
                _rooms[index]['length_ft'] = int.tryParse(lengthCtrl.text) ?? 12;
                _rooms[index]['approximate_area_sqft'] = _rooms[index]['width_ft'] * _rooms[index]['length_ft'];
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addRoom() {
    setState(() {
      _rooms.add({
        'name': 'New Room',
        'type': 'bedroom',
        'approximate_area_sqft': 144,
        'width_ft': 12,
        'length_ft': 12,
        'isDesigned': false,
      });
    });
    _editRoom(_rooms.length - 1);
  }

  void _deleteRoom(int index) {
    setState(() {
      _rooms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Confirm Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add missing room',
            onPressed: _addRoom,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Please verify the detected rooms and dimensions. You can add, edit, or delete rooms before proceeding to the 3D designer.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final r = _rooms[index];
                  return Card(
                    color: const Color(0xFF1E1E2E),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(r['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${r['width_ft']}ft x ${r['length_ft']}ft (${r['approximate_area_sqft']} sqft)', style: const TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => _editRoom(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteRoom(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _rooms.isEmpty
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomTilesScreen(
                              projectId: widget.projectId,
                              floorPlanUrl: widget.floorPlanUrl,
                              detectedRooms: _rooms,
                            ),
                          ),
                        );
                      },
                child: const Text('Confirm & Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
