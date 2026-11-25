import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/pages/auth/login.dart';
import 'package:FishMark/pages/auth/profile_setup.dart';
import 'package:FishMark/pages/explore/fish_species_list.dart';
import 'package:FishMark/pages/home.dart';
import 'package:FishMark/pages/privacy_gate.dart';

/// @desc 闪屏分流：隐私协议 -> 登录 / 首页
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  /// DEBUG 巡游开关：验证后必须恢复为 false
  static const bool kDebugTour = false;

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
    if (SplashGate.kDebugTour) {
      _go(const _DebugTour());
      return;
    }
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
      backgroundColor: Constants.LIME,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RemixIcons.anchor_fill,
              size: 120.w,
              color: Constants.INK,
            ),
            SizedBox(height: 24.w),
            Text(
              Constants.APP_NAME,
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.w800,
                color: Constants.INK,
                letterSpacing: 8.w,
              ),
            ),
            SizedBox(height: 12.w),
            Text(
              Constants.APP_SLOGAN,
              style: TextStyle(
                fontSize: 22.sp,
                color: Constants.INK.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== 临时 DEBUG 巡游：依次展示 4 个 tab + 个人资料页，验证后删除 =====
class _DebugTour extends StatefulWidget {
  const _DebugTour();

  @override
  State<_DebugTour> createState() => _DebugTourState();
}

class _DebugTourState extends State<_DebugTour> {
  // 每个页面用唯一 Key，确保 HomePage 切 tabIndex 时重新初始化
  Widget get _page {
    switch (_i) {
      case 0:
        return HomePage(key: const ValueKey('tour0'), tabIndex: 0);
      case 1:
        return HomePage(key: const ValueKey('tour1'), tabIndex: 3);
      case 2:
        return FishSpeciesListPage(key: const ValueKey('tour2'));
      default:
        return ProfileSetupPage(key: const ValueKey('tour3'));
    }
  }

  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _i++;
      if (_i > 4) {
        t.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _page;
}
