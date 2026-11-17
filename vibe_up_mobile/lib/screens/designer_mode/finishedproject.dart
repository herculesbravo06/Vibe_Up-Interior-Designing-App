import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_up/theme/app_theme.dart';
import 'case_study_page.dart';

class FinishedProjectsPage extends StatefulWidget {
  const FinishedProjectsPage({super.key});

  @override
  State<FinishedProjectsPage> createState() => _FinishedProjectsPageState();
}

class _FinishedProjectsPageState extends State<FinishedProjectsPage> {

  final List<Map<String, String>> projects = [

    {
      "image": "https://images.unsplash.com/photo-1556909212-d5b604d0c90d",
      "title": "Modern Minimalist Penthouse",
      "client": "Sarah Jenkins",
      "short": "Luxury penthouse redesign with clean minimal aesthetics.",
      "long":
      "This penthouse renovation focused on modern minimalism, open space planning, and natural lighting to create a calm luxury environment.",
      "rating": "5.0"
    },

    {
      "image": "https://images.unsplash.com/photo-1505691938895-1758d7feb511",
      "title": "Scandinavian Workspace",
      "client": "David Chen",
      "short": "Clean Scandinavian workspace with natural textures.",
      "long":
      "Designed to increase productivity, this Scandinavian office uses natural wood, neutral colors, and soft lighting.",
      "rating": "4.9"
    },

    {
      "image": "https://images.unsplash.com/photo-1492724441997-5dc865305da7",
      "title": "Wabi-Sabi Sanctuary",
      "client": "Elena Rodriguez",
      "short": "A peaceful Japanese inspired living environment.",
      "long":
      "Inspired by the Japanese Wabi-Sabi philosophy, this design celebrates imperfection with earthy textures and calming spaces.",
      "rating": "4.8"
    },
  ];

  List<bool> expanded = [false, false, false];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Finished Projects",
          style: GoogleFonts.playfairDisplay(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
        leading: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.search_rounded, color: AppTheme.textPrimary),
          )
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {

          final project = projects[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              GestureDetector(
                onTap: () {
                  setState(() {
                    expanded[index] = !expanded[index];
                  });
                },

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        project["image"]!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// TITLE + RATING
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                project["title"]!,
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                project["client"]!.toUpperCase(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppTheme.textDim,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              project["rating"]!,
                              style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  fontSize: 16),
                            )
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// SHORT DESCRIPTION
                    Text(
                      project["short"]!,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              /// EXPANDED AREA
              if (expanded[index]) ...[

                const SizedBox(height: 10),

                Text(
                  project["long"]!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.textDim,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                /// VIEW CASE STUDY BUTTON
                GestureDetector(
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CaseStudyPage(
                          title: project["title"]!,
                          description: project["long"]!,
                          image: project["image"]!,
                        ),
                      ),
                    );

                  },

                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "VIEW CASE STUDY",
                            style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white)
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
