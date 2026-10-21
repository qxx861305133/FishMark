import 'package:flutter/foundation.dart';

import 'package:luji_app/config/constants.dart';

/// @desc 日志工具
class LogUtil {
  static bool _isDebug = Constants.isDebug;

  static void init({bool isDebug = false}) {
    _isDebug = isDebug;
  }

  static void v(dynamic msg) {
    if (_isDebug) {
      debugPrint('[LJ] 💡 $msg');
    }
  }

  static void e(dynamic msg) {
    if (_isDebug) {
      debugPrint('[LJ] ❌ $msg');
    }
  }
}
