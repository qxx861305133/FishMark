import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/config/theme_palettes.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/profile.dart';

/// 可选主题色
Map<String, ThemeData> _themes = {
  'light': AppTheme.light,
};

/// @desc 全局配置
class Global {
  static late SharedPreferences _prefs;
  static const String _privacyAgreedKey = 'privacy_agreed';

  // 持久化系统配置
  static Profile profile = Profile();
  // 可选主题列表
  static Map get themes => _themes;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 初始化全局信息，会在APP启动时执行
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    var profileStr = _prefs.getString('profile');
    if (profileStr != null) {
      try {
        profile = Profile.fromJson(jsonDecode(profileStr));
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
      }
    }

    // 初始化网络请求相关配置
    await Api.init();
  }

  // 持久化存储Profile信息
  static void saveProfile() => _prefs.setString(
        'profile',
        jsonEncode(
          profile.toJson(),
        ),
      );

  // 退出登录，清空用户信息
  static void logout() {
    profile.token = null;
    profile.user = null;
    saveProfile();
    LogUtil.v('🚪 已退出登录');
  }

  static Future<bool> isPrivacyAgreed() async {
    try {
      // 明确处理null值情况，确保未同意时返回false
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_privacyAgreedKey) ?? false;
    } catch (e) {
      debugPrint('读取隐私协议状态失败: $e');
      return false; // 读取失败时默认显示弹窗
    }
  }

  static Future<void> setPrivacyAgreed(bool agreed) async {
    await _prefs.setBool(_privacyAgreedKey, agreed);
  }
}
