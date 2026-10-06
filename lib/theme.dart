import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Steller's Jay palette. Scene: course evaluators and shoppers scanning a
/// marketplace demo on phones in lit rooms; light surfaces, charcoal chrome.
/// Strategy: Restrained (tinted neutrals + one accent) with committed
/// charcoal headers as the identity carrier.
abstract final class Steller {
  // Brand
  static const deepBlue = Color(0xFF1C396B);
  static const azure = Color(0xFF2F80ED); // graphics, borders, focus (>=3:1)
  static const azureInk = Color(0xFF1D66CC); // azure as small text on light (AA)
  static const sky = Color(0xFF5AA9E6);
  static const amber = Color(0xFFE8A33D); // CTA background
  static const amberInk = Color(0xFF96601A); // amber as text/icon on light (AA)
  static const rust = Color(0xFFC0503C); // error

  // Neutrals, tinted toward the brand blue
  static const charcoal = Color(0xFF14171C); // dark surfaces
  static const ink = Color(0xFF3D4654); // body text on light
  static const blueGray = Color(0xFF64728A); // secondary text on light (AA)
  static const background = Color(0xFFF6F8FB);
  static const surface = Color(0xFFF9FBFE); // cards, fields, bubbles
  static const surface2 = Color(0xFFEFF4FB); // chips, wells, second layer
  static const border = Color(0xFFE4EAF4);
  static const onDark = Color(0xFFEEF3FA); // text on charcoal / deep blue
  static const onDarkMuted = Color(0xFF9FB0C6); // captions on charcoal (AA)
  static const disabled = Color(0xFFC6CEDC);
  static const onDisabled = Color(0xFF5B6678);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Steller.deepBlue,
    primary: Steller.deepBlue,
    onPrimary: Steller.onDark,
    secondary: Steller.azure,
    onSecondary: Steller.onDark,
    surface: Steller.surface,
    onSurface: Steller.ink,
    error: Steller.rust,
    onError: Steller.onDark,
    outline: Steller.border,
    brightness: Brightness.light,
  );

  const inputBorderRadius = BorderRadius.all(Radius.circular(12));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Steller.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Steller.charcoal,
      foregroundColor: Steller.onDark,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Steller.onDark,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Steller.charcoal,
      contentTextStyle: const TextStyle(fontSize: 14, color: Steller.onDark),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Steller.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Steller.charcoal,
      ),
      contentTextStyle: const TextStyle(fontSize: 14, height: 1.5, color: Steller.ink),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Steller.azure,
      selectionColor: Color(0x4D2F80ED),
      selectionHandleColor: Steller.deepBlue,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Steller.azure),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Steller.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Steller.blueGray, fontSize: 15),
      errorStyle: const TextStyle(fontSize: 12.5, color: Steller.rust),
      border: const OutlineInputBorder(borderRadius: inputBorderRadius, borderSide: BorderSide(color: Steller.border)),
      enabledBorder: const OutlineInputBorder(borderRadius: inputBorderRadius, borderSide: BorderSide(color: Steller.border)),
      focusedBorder: const OutlineInputBorder(borderRadius: inputBorderRadius, borderSide: BorderSide(color: Steller.azure, width: 1.6)),
      errorBorder: const OutlineInputBorder(borderRadius: inputBorderRadius, borderSide: BorderSide(color: Steller.rust, width: 1.2)),
      focusedErrorBorder: const OutlineInputBorder(borderRadius: inputBorderRadius, borderSide: BorderSide(color: Steller.rust, width: 1.6)),
      disabledBorder: const OutlineInputBorder(borderRadius: inputBorderRadius, borderSide: BorderSide(color: Steller.disabled)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Steller.deepBlue,
        foregroundColor: Steller.onDark,
        disabledBackgroundColor: Steller.disabled,
        disabledForegroundColor: Steller.blueGray,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Steller.deepBlue,
        disabledForegroundColor: Steller.disabled,
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: Steller.deepBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Steller.azureInk),
    ),
    cardTheme: CardThemeData(
      color: Steller.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Steller.border),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Steller.surface2,
      labelStyle: const TextStyle(color: Steller.deepBlue, fontSize: 12, fontWeight: FontWeight.w600),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(color: Steller.border, thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: Steller.blueGray),
    iconTheme: const IconThemeData(color: Steller.blueGray),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Steller.charcoal, letterSpacing: -0.4),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Steller.charcoal, letterSpacing: -0.3),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Steller.charcoal),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Steller.charcoal),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Steller.charcoal),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Steller.ink, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Steller.ink, height: 1.45),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Steller.blueGray),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Steller.ink),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Steller.blueGray),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Steller.blueGray, letterSpacing: 1.1),
    ),
  );
}
