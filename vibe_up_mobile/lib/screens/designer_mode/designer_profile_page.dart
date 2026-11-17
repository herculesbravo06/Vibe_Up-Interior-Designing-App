import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/screens/auth/login_screen.dart';

class DesignerProfilePage extends StatelessWidget {

  final String name;
  final String role;
  final String location;
  final String image;
  final int projects;
  final String experience;
  final num rating;

  const DesignerProfilePage({
    super.key,
    required this.name,
    required this.role,
    required this.location,
    required this.image,
    required this.projects,
    required this.experience,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {

    Color primary = AppTheme.primaryAccent;

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: Text("Designer Profile", style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                AuthService.logout(context);
              },
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 10),

            /// PROFILE IMAGE
            Stack(
              children: [

                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(image),
                  ),
                ),

                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            /// NAME
            Text(
              name,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary
              ),
            ),

            const SizedBox(height: 4),

            Text(
              role.toUpperCase(),
              style: GoogleFonts.dmSans(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_rounded, size: 18, color: AppTheme.textDim),
                const SizedBox(width: 4),
                Text(location, style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 15))
              ],
            ),

            const SizedBox(height: 20),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [

                  statBox("$projects", "Projects"),
                  statBox(experience, "Years"),
                  statBox("$rating ⭐", "Rating"),

                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ABOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "About Me",
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Passionate about creating functional, beautiful spaces that reflect the unique personality of my clients. Specializing in high-end residential and boutique commercial projects with a focus on sustainability and timeless elegance.",
                style: GoogleFonts.dmSans(color: AppTheme.textSecondary, height: 1.5),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildChip("Modern Minimalist"),
                  _buildChip("Sustainable Design"),
                  _buildChip("Color Theory"),
                  _buildChip("Urban Industrial"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// PORTFOLIO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Portfolio Preview",
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: const [

                portfolioImage("https://images.unsplash.com/photo-1616594039964-ae9021a400a0"),
                portfolioImage("https://images.unsplash.com/photo-1600210492486-724fe5c67fb0"),
                portfolioImage("https://images.unsplash.com/photo-1505691938895-1758d7feb511"),
                portfolioImage("https://images.unsplash.com/photo-1600607687939-ce8a6c25118c"),

              ],
            ),

            const SizedBox(height: 20),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)
                      )
                  ),
                  onPressed: () {},
                  child: Text(
                    "BOOK A CONSULTATION",
                    style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget statBox(String value, String title) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryAccent)),
            const SizedBox(height: 4),
            Text(title,
                style: GoogleFonts.dmSans(
                    color: AppTheme.textDim,
                    fontSize: 12))
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 13),
      ),
    );
  }
}

class portfolioImage extends StatelessWidget {

  final String image;

  const portfolioImage(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(image, fit: BoxFit.cover),
    );
  }
}
