import 'package:flutter/material.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjDesc extends StatelessWidget {

  final String title;
  final String category;
  final String client;
  final String deadline;
  final String status;
  final String image;

  const ProjDesc({
    super.key,
    required this.title,
    required this.category,
    required this.client,
    required this.deadline,
    required this.status,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Project Details",
          style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("CLIENT",
                      style: GoogleFonts.dmSans(
                          color: AppTheme.primaryAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),

                  const SizedBox(height: 8),

                  Text(title,
                      style: GoogleFonts.playfairDisplay(
                          color: AppTheme.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(Icons.person_rounded,color: AppTheme.primaryAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(client,
                          style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 16)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Information",
                  style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),

              child: Column(
                children: [

                  infoRow("Room Type", category),

                  infoRow("Status", status.toUpperCase()),

                  infoRow("Deadline", deadline),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget infoRow(String title,String value){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(title,
              style: GoogleFonts.dmSans(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),

          Text(value,
              style: GoogleFonts.dmSans(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold)),

        ],
      ),
    );
  }
}
