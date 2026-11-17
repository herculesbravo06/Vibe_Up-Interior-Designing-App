import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:vibe_up/screens/project/house_dimensions_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HouseSetupScreen extends StatefulWidget {
  const HouseSetupScreen({super.key});

  @override
  State<HouseSetupScreen> createState() => _HouseSetupScreenState();
}

class _HouseSetupScreenState extends State<HouseSetupScreen> {
  final List<String> _options = [
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4 BHK',
    '4+ BHK',
    'Commercial Space'
  ];

  void _onOptionSelected(String option) {
    // Auto-generate room list based on selection
    List<Map<String, dynamic>> initialRooms = [
      {'name': 'Living Room', 'type': 'living'},
      {'name': 'Kitchen', 'type': 'kitchen'},
    ];

    int bedroomCount = 0;
    int bathroomCount = 1;

    switch (option) {
      case '1 BHK': bedroomCount = 1; bathroomCount = 1; break;
      case '2 BHK': bedroomCount = 2; bathroomCount = 2; break;
      case '3 BHK': bedroomCount = 3; bathroomCount = 3; break;
      case '4 BHK': bedroomCount = 4; bathroomCount = 4; break;
      case '4+ BHK': bedroomCount = 5; bathroomCount = 4; break;
      case 'Commercial Space': 
        initialRooms.clear();
        initialRooms.add({'name': 'Main Hall', 'type': 'living'});
        initialRooms.add({'name': 'Office 1', 'type': 'office'});
        initialRooms.add({'name': 'Washroom', 'type': 'bathroom'});
        bedroomCount = 0;
        bathroomCount = 0;
        break;
    }

    for (int i = 1; i <= bedroomCount; i++) {
      initialRooms.add({'name': 'Bedroom $i', 'type': 'bedroom'});
    }
    for (int i = 1; i <= bathroomCount; i++) {
      initialRooms.add({'name': 'Bathroom $i', 'type': 'bathroom'});
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HouseDimensionsScreen(
          houseType: option,
          initialRooms: initialRooms,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('House Setup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Select House Type',
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fade().slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Let\'s build your virtual layout based on standard templates.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    return _buildHKCard(
                      title: _options[index],
                      icon: _getIconForOption(_options[index]),
                      delay: 200 + (index * 100),
                      onTap: () => _onOptionSelected(_options[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForOption(String opt) {
    if (opt.contains('1')) return Icons.looks_one_outlined;
    if (opt.contains('2')) return Icons.looks_two_outlined;
    if (opt.contains('3')) return Icons.looks_3_outlined;
    if (opt.contains('4')) return Icons.looks_4_outlined;
    if (opt.contains('Commercial')) return Icons.business_outlined;
    return Icons.domain_outlined;
  }

  Widget _buildHKCard({required String title, required IconData icon, required int delay, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 36, color: AppTheme.primaryAccent),
            ),
            const SizedBox(height: 14),
            Text(title, style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ).animate().fade(delay: delay.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
