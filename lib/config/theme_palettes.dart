import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:luji_app/config/constants.dart';

/// Material 3 主题配置
class AppTheme {
  /// 亮色主题
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Constants.PRIMARY_COLOR,
          primary: Constants.PRIMARY_COLOR,
        ),
        scaffoldBackgroundColor: Constants.BG_COLOR,
        primaryColor: Constants.PRIMARY_COLOR,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        dividerColor: Constants.LINE_COLOR,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Constants.TEXT_DEFAULT_COLOR,
            fontSize: 34.sp,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.transparent,
          hintStyle: TextStyle(
            color: Constants.TEXT_LIGHT_COLOR,
            fontSize: 28.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Constants.TEXT_DEFAULT_COLOR,
            fontSize: 36.sp,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Constants.TEXT_DEFAULT_COLOR,
            fontSize: 32.sp,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Constants.TEXT_DEFAULT_COLOR,
            fontSize: 30.sp,
          ),
          bodyMedium: TextStyle(
            color: Constants.TEXT_SECONDARY_COLOR,
            fontSize: 28.sp,
          ),
          bodySmall: TextStyle(
            color: Constants.TEXT_LIGHT_COLOR,
            fontSize: 24.sp,
          ),
        ),
      );
}
