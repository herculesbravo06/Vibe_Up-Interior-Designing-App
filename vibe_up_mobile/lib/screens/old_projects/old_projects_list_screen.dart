import 'package:vibe_up/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_up/screens/project/project_dimensions_screen.dart';
import 'package:vibe_up/screens/project/house_dimensions_screen.dart';
import 'package:vibe_up/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OldProjectsListScreen extends StatefulWidget {
  const OldProjectsListScreen({super.key});

  @override
  State<OldProjectsListScreen> createState() => _OldProjectsListScreenState();
}

class _OldProjectsListScreenState extends State<OldProjectsListScreen> {
  List<dynamic> _projects = [];
  bool _isLoading = true;

  // Room-type preview images from the web
  static const List<String> _projectImages = [
    'https://images.unsplash.com/photo-1583847268964-b28ce8f31586?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1540518614846-7eded433c457?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1556912173-3bb406ef7e77?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1600210492493-0946911123ea?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1631679706909-1844bbd07221?auto=format&fit=crop&q=80&w=400',
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      
      final projects = await ApiService.getUserProjects(userId);
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'draft': return 'Draft';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      case 'draft': return Colors.grey;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&q=80&w=300',
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.folder_open, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                      ),
                      const SizedBox(height: 24),
                      Text('No projects yet', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Start a new project to see it here!', style: TextStyle(color: AppTheme.textDim)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProjects,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final project = _projects[index];
                      final imageUrl = _projectImages[index % _projectImages.length];
                      final status = project['status'] ?? 'draft';
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
                            // Project preview image
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 180,
                                      color: AppTheme.cardColor,
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: 180,
                                      color: AppTheme.cardColor,
                                      child: const Icon(Icons.home, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                // Status badge overlay
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusLabel(status),
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          project['name'] ?? 'Untitled Project',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        project['created_at'] != null
                                            ? _formatDate(project['created_at'])
                                            : '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (project['description'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      project['description'],
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (project['total_estimated_cost'] != null && project['total_estimated_cost'] != '0.00') ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '${project['currency'] ?? 'INR'} ${project['total_estimated_cost']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                  if (project['designer_name'] != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 16, color: AppTheme.textDim),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Designer: ${project['designer_name']}',
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        final name = (project['name'] ?? '').toString().toUpperCase();
                                        final isFullHouse = name.contains('BHK') || name.contains('OFFICE') || name.contains('COMMERCIAL');
                                        
                                        if (isFullHouse) {
                                          // Redirect to House Setup / Dimensions for BHK/Office
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HouseDimensionsScreen(
                                                houseType: _extractTypeFromName(name),
                                                initialRooms: _extractRoomsFromProject(project),
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Redirect to Single Room Dimensions
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (_) => ProjectDimensionsScreen(projectData: project)
                                            )
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.edit_outlined),
                                      label: const Text('Update Project'),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Theme.of(context).primaryColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
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
                ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _extractTypeFromName(String name) {
    name = name.toUpperCase();
    if (name.contains('1 BHK')) return '1 BHK';
    if (name.contains('2 BHK')) return '2 BHK';
    if (name.contains('3 BHK')) return '3 BHK';
    if (name.contains('4 BHK')) return '4 BHK';
    if (name.contains('COMMERCIAL') || name.contains('OFFICE')) return 'Commercial Space';
    return '2 BHK'; // Default fallback
  }

  List<Map<String, dynamic>> _extractRoomsFromProject(Map<String, dynamic> project) {
    // If the project already has multiple rooms in its metadata (e.g. from a custom field or JOIN)
    // currently the API returns room_name/width/length for ONE room.
    
    // Fallback: Generate standard rooms for the type but inject the one we know 
    // or just return the list of rooms if the API was updated.
    
    // For now, let's create a minimal list based on the house type
    // and use the dimensions from the project if it matches a room name.
    
    String type = _extractTypeFromName(project['name'] ?? '');
    List<Map<String, dynamic>> rooms = [];
    
    // Standard templateRooms logic (similar to HouseSetupScreen)
    if (type == 'Commercial Space') {
      rooms.add({'name': 'Main Hall', 'type': 'living'});
      rooms.add({'name': 'Office 1', 'type': 'office'});
      rooms.add({'name': 'Washroom', 'type': 'bathroom'});
    } else {
      rooms.add({'name': 'Living Room', 'type': 'living'});
      rooms.add({'name': 'Kitchen', 'type': 'kitchen'});
      int b = int.tryParse(type.split(' ')[0]) ?? 2;
      for (int i = 1; i <= b; i++) rooms.add({'name': 'Bedroom $i', 'type': 'bedroom'});
      for (int i = 1; i <= (b > 1 ? 2 : 1); i++) rooms.add({'name': 'Bathroom $i', 'type': 'bathroom'});
    }

    // Pre-fill the specific room data if it matches
    for (var r in rooms) {
      if (r['name'] == project['room_name']) {
        r['width_ft'] = double.tryParse(project['room_width']?.toString() ?? '12')?.toInt() ?? 12;
        r['length_ft'] = double.tryParse(project['room_length']?.toString() ?? '12')?.toInt() ?? 12;
      } else {
        r['width_ft'] = 12;
        r['length_ft'] = 12;
      }
    }
    
    return rooms;
  }
}
