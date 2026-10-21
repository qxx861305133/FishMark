import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/global.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/pages/auth/login.dart';
import 'package:luji_app/pages/home.dart';
import 'package:luji_app/pages/privacy_gate.dart';

/// @desc 闪屏分流：隐私协议 -> 登录 / 首页
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // 等首帧建立后再做导航，确保 Navigator 就绪
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideNext();
    });
  }

  Future<void> _decideNext() async {
    if (_navigated) return;
    _navigated = true;

    // 展示背景一会儿
    await Future.delayed(const Duration(milliseconds: 1200));

    final agreed = await Global.isPrivacyAgreed();
    if (agreed) {
      LogUtil.v("✅ 同意隐私协议，准备进首页");
      final isLogin = Global.profile.user != null &&
          Global.profile.user!.is_login == true;
      _go(isLogin ? const HomePage() : const LoginPage());
    } else {
      LogUtil.v("✅ 未同意隐私协议，准备进隐私页");
      _go(const PrivacyGatePage());
    }
  }

  void _go(Widget page) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phishing,
                size: 160.w, color: Colors.white),
            SizedBox(height: 24.w),
            Text(
              Constants.APP_NAME,
              style: TextStyle(
                fontSize: 56.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 8.w,
              ),
            ),
            SizedBox(height: 12.w),
            Text(
              Constants.APP_SLOGAN,
              style: TextStyle(
                fontSize: 26.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
