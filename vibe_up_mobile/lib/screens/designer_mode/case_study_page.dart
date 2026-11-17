import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseStudyPage extends StatelessWidget {

  final String title;
  final String description;
  final String image;

  const CaseStudyPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {

    Color primary = AppTheme.primaryAccent;

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Case Study",
          style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Icon(Icons.share_rounded, color: AppTheme.textDim),
          const SizedBox(width: 16),
          Icon(Icons.bookmark_border_rounded, color: AppTheme.textDim),
          const SizedBox(width: 16),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// CATEGORY
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Interior Design • 2023",
                style: GoogleFonts.dmSans(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1),
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            /// DESCRIPTION
            Text(
              description,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(image),
            ),

            const SizedBox(height: 30),

            /// CHALLENGE
            sectionTitle(Icons.lightbulb_rounded, "The Challenge"),

            const SizedBox(height: 12),

            Text(
              "The client acquired a penthouse with floor-to-ceiling windows creating a cold atmosphere. The goal was to introduce warmth without blocking views.",
              style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 30),

            /// SOLUTION
            sectionTitle(Icons.architecture_rounded, "The Solution"),

            const SizedBox(height: 10),

            solutionTile(
              "Natural Palette",
              "Terracotta ceramics and linen textiles were used.",
            ),

            solutionTile(
              "Zonal Lighting",
              "Layered warm lighting to mimic sunset indoors.",
            ),

            solutionTile(
              "Custom Millwork",
              "Floating cabinetry for storage without visual bulk.",
            ),

            const SizedBox(height: 30),

            /// RESULTS
            sectionTitle(Icons.auto_graph_rounded, "The Results"),

            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                resultBox("98%", "Client Satisfaction"),

                resultBox("40%", "Acoustic Improvement"),

                resultBox("12wk", "Timeline"),
              ],
            ),

            const SizedBox(height: 40),

            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    "START YOUR PROJECT",
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryAccent, size: 28),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget solutionTile(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppTheme.primaryAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc,
                    style: GoogleFonts.dmSans(
                        color: AppTheme.textDim,
                        fontSize: 14))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class resultBox extends StatelessWidget {

  final String value;
  final String label;

  const resultBox(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [

            Text(
              value,
              style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryAccent),
            ),

            const SizedBox(height: 8),

            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppTheme.textDim),
            ),
          ],
        ),
      ),
    );
  }
}
