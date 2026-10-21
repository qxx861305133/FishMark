import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/pages/splash_gate.dart';
import 'package:FishMark/provider/profile.dart';
import 'package:FishMark/provider/tab_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 强制等待初始化完成
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    Global.init(), // 仅做不需授权的初始化
  ]);

  runApp(const MyApp());

  FlutterError.onError = (details) {
    LogUtil.v('❌ 全局异常: ${details.exception}');
    FlutterError.presentError(details); // 确保异常被处理
    debugPrint("📍 Stack Trace: ${details.stack}");
  };

  // Android 状态栏透明
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }
}

/// APP入口 Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 750宽设计稿基准（.w/.sp 数值按 750 标注换算）
      designSize: const Size(750, 1631),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TabProvider()),
            ChangeNotifierProvider(create: (_) => UserNotifier()),
          ],
          child: Builder(
            builder: (BuildContext context) {
              return _buildMaterialApp(context);
            },
          ),
        );
      },
    );
  }
}

Widget _buildMaterialApp(BuildContext context) {
  return MaterialApp(
    theme: Global.themes['light']!.copyWith(
      splashColor: Colors.transparent,
    ),
    title: '路记',
    navigatorKey: Global.navigatorKey,
    home: const SplashGate(),
    debugShowCheckedModeBanner: false,
  );
}

// Must be top-level function
dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

Future<dynamic> parseJson(String text) {
  return compute(_parseAndDecode, text);
}
