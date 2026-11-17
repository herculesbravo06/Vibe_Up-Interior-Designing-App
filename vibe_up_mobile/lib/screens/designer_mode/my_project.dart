import 'dart:async';
import 'package:vibe_up/theme/app_theme.dart';
import 'manage_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'proj_desc.dart';
import 'designer_dashboard.dart';
import 'designer_profile_page.dart';
import 'package:vibe_up/services/request_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProject extends StatefulWidget {
  const MyProject({super.key});

  @override
  State<MyProject> createState() => _MyProjectState();
}

class _MyProjectState extends State<MyProject> {
  String _userName = 'Designer';
  List<Map<String, dynamic>> _acceptedProjects = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Poll every 5 seconds for realtime updates
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await RequestService.getRequests(status: 'accepted');
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Designer';
        _acceptedProjects = projects;
        _isLoading = false;
      });
    }
  }

  /// Format a timestamp string into a readable date
  String _formatDeadline(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'TBD';
    try {
      final dt = DateTime.parse(timestamp);
      // Set a deadline 30 days from the request date
      final deadline = dt.add(const Duration(days: 30));
      return DateFormat('MMM dd, yyyy').format(deadline);
    } catch (_) {
      return 'TBD';
    }
  }

  /// Pick a project image based on index
  String _getProjectImage(int index) {
    final images = [
      "https://images.unsplash.com/photo-1556909212-d5b604d0c90d",
      "https://images.unsplash.com/photo-1505691938895-1758d7feb511",
      "https://images.unsplash.com/photo-1492724441997-5dc865305da7",
      "https://images.unsplash.com/photo-1600210492486-724fe5c67fb0",
      "https://images.unsplash.com/photo-1616594039964-ae9021a400a0",
    ];
    return images[index % images.length];
  }

  /// Pick a color based on index
  Color _getProjectColor(int index) {
    final colors = [Colors.teal, Colors.deepPurple, Colors.amber, Colors.indigo, Colors.pink];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    Color primary = AppTheme.primaryAccent;

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: Icon(Icons.menu_rounded, color: primary),
        centerTitle: true,
        title: Text(
          "My Projects",
          style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _acceptedProjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_rounded, size: 80, color: AppTheme.textDim.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        "No projects yet",
                        style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDim),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Accept a request to see it here!",
                        style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _acceptedProjects.length,
                    itemBuilder: (context, index) {
                      final project = _acceptedProjects[index];
                      final projectName = project['projectName'] ?? 'Untitled Project';
                      final clientName = project['userName'] ?? 'Unknown Client';
                      final projectDetails = project['projectDetails'] ?? '';
                      final deadline = _formatDeadline(project['timestamp']);
                      final image = _getProjectImage(index);
                      final color = _getProjectColor(index);

                      return ProjectCard(
                        title: projectName,
                        category: "Interior Design",
                        client: clientName,
                        deadline: deadline,
                        status: "In Progress",
                        color: color,
                        image: image,
                        projectDetails: projectDetails,
                      );
                    },
                  ),
                ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.surfaceDark,
        currentIndex: 1,
        selectedItemColor: primary,
        unselectedItemColor: AppTheme.textDim,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.dmSans(),

        onTap: (index) {
          /// HOME
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DesignerDashboard(),
              ),
            );
          }

          /// PROJECTS - already here
          if (index == 1) {}

          /// CHAT
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageRequestsPage(),
              ),
            );
          }

          /// PROFILE
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DesignerProfilePage(
                  name: _userName,
                  role: "Interior Designer",
                  location: "New York, NY",
                  image:
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuCmgc-L7Xh5OpO93HdAv5V_UYeUiWsch2uhk9QfQQKfKIJEe8V8fei9BjlfwX38RaMQwHeLacrwsa75ilTON1ppTMNFDZPMxgKJD3tbFmpjkAK863tQk48TuumWt2FfSlXUoBVw4jQefy2klD0kDI2vmAWtvkS9bRfivN532eAZg9lrs0wDfByx9BsE_pyI7bNbqRb7wplYczrNT44IO6vqCXyDTU2k9aA7JXbAMgw0n48Y0XSyZhH7O2NKUBoEe4ORnABgx6NRGPI",
                  projects: _acceptedProjects.length,
                  experience: "8+",
                  rating: 4.9,
                ),
              ),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {

  final String title;
  final String category;
  final String client;
  final String deadline;
  final String status;
  final Color color;
  final String image;
  final String projectDetails;

  const ProjectCard({
    super.key,
    required this.title,
    required this.category,
    required this.client,
    required this.deadline,
    required this.status,
    required this.color,
    required this.image,
    this.projectDetails = '',
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: color.withOpacity(0.1),
                child: Center(
                  child: Icon(Icons.image, size: 60, color: color.withOpacity(0.4)),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(title,
                    style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),

                const SizedBox(height: 4),

                Text(status.toUpperCase(),
                    style: GoogleFonts.dmSans(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),

                if (projectDetails.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    projectDetails,
                    style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 18, color: AppTheme.textDim),
                    const SizedBox(width: 8),
                    Text(client, style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textDim),
                    const SizedBox(width: 8),
                    Text(deadline, style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjDesc(
                              title: title,
                              category: category,
                              client: client,
                              deadline: deadline,
                              status: status,
                              image: image,
                            ),
                          ),
                        );
                      },

                      child: Text(
                        "OPEN PROJECT DETAILS",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
