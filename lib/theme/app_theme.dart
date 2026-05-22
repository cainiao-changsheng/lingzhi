import 'package:flutter/material.dart';

class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF6366F1); // 紫色蓝
  static const Color secondaryColor = Color(0xFFF59E0B); // 暖金色
  static const Color accentColor = Color(0xFF10B981); // 绿色
  static const Color errorColor = Color(0xFFEF4444); // 红色

  // 背景色 - 星空深色主题
  static const Color backgroundColor = Color(0xFF0F172A); // 深蓝黑
  static const Color surfaceColor = Color(0xFF1E293B); // 深灰蓝
  static const Color cardColor = Color(0xFF334155); // 卡片灰蓝

  // 文字色
  static const Color textPrimary = Color(0xFFF1F5F9); // 亮白
  static const Color textSecondary = Color(0xFF94A3B8); // 灰白
  static const Color textDisabled = Color(0xFF64748B); // 深灰

  // 边框色
  static const Color borderColor = Color(0xFF475569); // 中灰
  static const Color dividerColor = Color(0xFF334155); // 分割线

  // 特殊效果色
  static const Color shimmerColor = Color(0x1AFFFFFF); // 微光效果
  static const Color overlayColor = Color(0x801E293B); // 遮罩层

  // 卡片边框色
  static const Color musicCardBorder = Color(0xFFF59E0B); // 暖金
  static const Color taskCardBorder = Color(0xFF8B5CF6); // 紫色
  static const Color confirmCardBorder = Color(0xFF10B981); // 绿色
  static const Color imageDisplayCardBorder = Color(0xFF3B82F6); // 蓝色
  static const Color imageGenerationCardBorder = Color(0xFFF97316); // 橙色
  static const Color imageRecognitionCardBorder = Color(0xFF06B6D4); // 青色

  // 渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
  );

  // 阴影
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x336366F1),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  // 圆角
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // 间距
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // 字体大小
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;

  // 图标大小
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 28.0;
  static const double iconSizeXL = 32.0;

  // 获取主题数据
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: fontSizeL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeXXXL,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: fontSizeM,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: fontSizeL,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeM,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeS,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeM,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: fontSizeXS,
          fontWeight: FontWeight.w400,
          color: textDisabled,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        hintStyle: const TextStyle(color: textDisabled),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.all(spacingM),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: spacingM,
      ),
      buttonTheme: const ButtonThemeData(
        padding: EdgeInsets.symmetric(vertical: spacingS, horizontal: spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadiusMedium)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: spacingS,
            horizontal: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(
            vertical: spacingS,
            horizontal: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: spacingS,
            horizontal: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: iconSizeM,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceColor,
      ),
    );
  }

  // 获取文本样式
  static TextStyle get titleStyle => const TextStyle(
        fontSize: fontSizeXXL,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get subtitleStyle => const TextStyle(
        fontSize: fontSizeL,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get bodyStyle => const TextStyle(
        fontSize: fontSizeM,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  static TextStyle get captionStyle => const TextStyle(
        fontSize: fontSizeS,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get buttonStyle => const TextStyle(
        fontSize: fontSizeM,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  // 获取卡片样式
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: cardShadow,
      );

  static BoxDecoration get musicCardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        border: Border.all(color: musicCardBorder, width: 2),
        boxShadow: cardShadow,
      );

  static BoxDecoration get taskCardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        border: Border.all(color: taskCardBorder, width: 2),
        boxShadow: cardShadow,
      );

  static BoxDecoration get confirmCardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        border: Border.all(color: confirmCardBorder, width: 2),
        boxShadow: cardShadow,
      );

  // 获取毛玻璃效果
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: overlayColor,
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      );

  // 获取播放控制条样式
  static BoxDecoration get playerBarDecoration => BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      );
}