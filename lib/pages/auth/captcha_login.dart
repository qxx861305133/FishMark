import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/pages/auth/agreement_page.dart';
import 'package:FishMark/pages/auth/profile_setup.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 0.2.2 验证码/密码登录
class CaptchaLoginPage extends StatefulWidget {
  const CaptchaLoginPage({super.key});

  @override
  State<CaptchaLoginPage> createState() => _CaptchaLoginPageState();
}

class _CaptchaLoginPageState extends State<CaptchaLoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _countdown = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 11) {
      Fluttertoast.showToast(msg: '请输入正确的手机号');
      return;
    }
    // mock：直接开始倒计时
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _countdown = 0);
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
    Fluttertoast.showToast(msg: '验证码已发送（mock：任意6位数字可登录）');
  }

  void _login() {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      Fluttertoast.showToast(msg: '请输入验证码');
      return;
    }
    // mock 登录成功 → 基础信息
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TopGradientBox(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(pagePadding),
                child: const CircleBackButton(),
              ),
              SizedBox(height: 32.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hi ',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: Constants.INK,
                        ),
                      ),
                      TextSpan(
                        text: '欢迎来到路记',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Constants.INK,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Text(
                  '未注册手机号验证通过后自动注册',
                  style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
                ),
              ),
              SizedBox(height: 36.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Column(
                  children: [
                    FillInput(
                      controller: _mobileController,
                      hint: '请输入手机号',
                      keyboardType: TextInputType.phone,
                      prefixIcon: RemixIcons.smartphone_line,
                    ),
                    SizedBox(height: 16.w),
                    FillInput(
                      controller: _codeController,
                      hint: '请输入验证码',
                      keyboardType: TextInputType.number,
                      prefixIcon: RemixIcons.shield_check_line,
                      suffix: GestureDetector(
                        onTap: _countdown > 0 ? null : _sendCode,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          _countdown > 0 ? '${_countdown}s后重发' : '获取验证码',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Constants.INK,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 44.w),
                    LimeButton(text: '登  录', onPressed: _login),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: AgreementFooter(
                  onUserAgreement: () {
                    AgreementPage.show(context, title: '用户协议');
                  },
                  onPrivacyAgreement: () {
                    AgreementPage.show(context, title: '隐私政策');
                  },
                ),
              ),
              SizedBox(height: 28.w),
            ],
          ),
        ),
      ),
    );
  }
}
