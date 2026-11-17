import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Warm Dusk Palette — Midnight Slate + Coral Rose ───
  static const Color background    = Color(0xFF0F0F1A); // deep midnight slate-blue
  static const Color surfaceDark   = Color(0xFF17172A); // elevated slate
  static const Color cardColor     = Color(0xFF1E1E35); // card navy
  static const Color cardColorLight= Color(0xFF252545); // lighter card
  static const Color primaryAccent = Color(0xFFFF6B6B); // coral-rose
  static const Color accentLight   = Color(0xFFFF9494); // soft blush
  static const Color accentDark    = Color(0xFFE04F4F); // deep rose
  static const Color secondaryAccent= Color(0xFFFFB347); // warm amber (tags/chips)
  static const Color textPrimary   = Color(0xFFEEEEF5); // near-white with blue tint
  static const Color textSecondary = Color(0xFF9999BB); // muted purple-grey
  static const Color textDim       = Color(0xFF666688); // dim muted
  static const Color dividerColor  = Color(0xFF252540); // subtle divider
  static const Color errorColor    = Color(0xFFFF5252); // vivid red
  static const Color successColor  = Color(0xFF4ECCA3); // teal-green (premium feel)

  // Backward-compatible aliases (old core/theme.dart names)
  static const Color backgroundDetail = surfaceDark;
  static const Color textLight        = textPrimary;
  static const Color accentColor      = primaryAccent;
  static const Color surfaceColor     = surfaceDark;

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFE04F4F), Color(0xFFFF9494)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Keep goldGradient alias for backward compat (now coral)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFF9494), Color(0xFFFF6B6B), Color(0xFFE04F4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A16), Color(0xFF0F0F1A), Color(0xFF17172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF222238), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmDuskGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1A0F1F), Color(0xFF17172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Decorations ───
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryAccent.withOpacity(0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
  );

  // Renamed from goldBorderCard — kept as alias
  static BoxDecoration get goldBorderCard => accentBorderCard;

  static BoxDecoration get accentBorderCard => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: primaryAccent.withOpacity(0.18), width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryAccent.withOpacity(0.08),
        blurRadius: 20,
        spreadRadius: -2,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ─── Light Theme (mirrors dark for consistency) ───
  static ThemeData get lightTheme => darkTheme;

  // ─── Dark Theme (Primary) ───
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryAccent,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: cardColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        onSecondary: Colors.black,
      ),
      textTheme: TextTheme(
        // Headings — Playfair Display (editorial, elegant)
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 34, fontWeight: FontWeight.w700,
          color: textPrimary, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28, fontWeight: FontWeight.w700,
          color: textPrimary, letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleSmall: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        // Body — DM Sans (modern, clean)
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14, color: textSecondary,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12, color: textDim,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        labelMedium: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w600, color: primaryAccent,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.dmSans(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryAccent.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600, fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.dmSans(color: textDim, fontSize: 14),
        labelStyle: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
        prefixIconColor: textDim,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryAccent,
        unselectedItemColor: textDim,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor, thickness: 1, space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryAccent.withOpacity(0.15),
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Colors.white.withOpacity(0.07)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColorLight,
        contentTextStyle: GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
      ),
    );
  }
}
