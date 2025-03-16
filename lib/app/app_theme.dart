import 'package:flutter/material.dart';

// ธีมสีหลักสำหรับแอปทั้งหมด
class AppTheme {
  // สีหลัก (Primary colors)
  static const MaterialColor primarySwatch = Colors.blueGrey;
  static final Color primaryColor = Colors.blueGrey.shade800;
  static final Color primaryColorDark = Colors.blueGrey.shade900;
  static final Color primaryColorLight = Colors.blueGrey.shade700;

  // สีรอง (Accent/Secondary colors)
  static final Color accentColor = Colors.teal.shade400; // สีตัดที่ดูสดใส
  static final Color secondaryColor = Colors.teal.shade600;

  // สีพื้นหลัง (Background colors)
  static final Color scaffoldBackgroundColor = Color(0xFF121212); // สีพื้นหลังเกือบดำ
  static final Color backgroundColor = Color(0xFF1E1E1E); // สีพื้นหลังดำอมเทา
  static final Color cardColor = Colors.grey.shade900;
  static final Color dialogBackgroundColor = Color(0xFF252525);

  // สีข้อความ (Text colors)
  static const Color textColorPrimary = Colors.white;
  static final Color textColorSecondary = Colors.grey.shade300;
  static final Color textColorHint = Colors.grey.shade500;
  static final Color textColorDisabled = Colors.grey.shade700;

  // สีไอคอน (Icon colors)
  static const Color iconColorPrimary = Colors.white;
  static final Color iconColorSecondary = Colors.grey.shade400;

  // สีขอบ (Border colors)
  static final Color borderColor = Colors.grey.shade800;
  static final Color dividerColor = Colors.grey.shade800;

  // สีปุ่ม (Button colors)
  static final Color buttonPrimaryColor = Colors.blueGrey.shade700;
  static final Color buttonSecondaryColor = Colors.teal.shade600;
  static final Color buttonDisabledColor = Colors.grey.shade800;

  // สีสถานะ (Status colors)
  static final Color successColor = Colors.green.shade400;
  static final Color errorColor = Colors.red.shade400;
  static final Color warningColor = Colors.amber.shade400;
  static final Color infoColor = Colors.blue.shade400;

  // ========== Gradient ที่คุณเลือกไว้ ==========
  static final Gradient mainGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.blueGrey.shade900,
      Colors.blueGrey.shade800,
      Colors.grey.shade900,
    ],
  );

  // Gradient เพิ่มเติมที่เข้ากับธีม
  static final Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.blueGrey.shade800,
      Colors.teal.shade800,
    ],
  );

  static final Gradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.teal.shade400,
      Colors.teal.shade700,
    ],
  );

  // ========== ThemeData สำหรับใช้งานใน MaterialApp ==========
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Cloud',
    brightness: Brightness.dark,
    primarySwatch: primarySwatch,
    primaryColor: primaryColor,
    primaryColorDark: primaryColorDark,
    primaryColorLight: primaryColorLight,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,
    dialogBackgroundColor: dialogBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
      error: errorColor,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textColorPrimary),
      bodyMedium: TextStyle(color: textColorPrimary),
      titleLarge: TextStyle(color: textColorPrimary),
      titleMedium: TextStyle(color: textColorPrimary),
      labelLarge: TextStyle(color: textColorPrimary),
    ),
    iconTheme: IconThemeData(
      color: iconColorPrimary,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: buttonPrimaryColor,
      disabledColor: buttonDisabledColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColorDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPrimaryColor,
        foregroundColor: textColorPrimary,
        disabledBackgroundColor: buttonDisabledColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: BorderSide(color: borderColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: backgroundColor,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accentColor),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}