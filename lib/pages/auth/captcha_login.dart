import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/user.dart';
import 'package:FishMark/pages/auth/agreement_page.dart';
import 'package:FishMark/pages/auth/profile_setup.dart';
import 'package:FishMark/pages/auth/register.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 0.2.2 手机号 + 密码登录（对接 POST /auth/login）
class CaptchaLoginPage extends StatefulWidget {
  const CaptchaLoginPage({super.key});

  @override
  State<CaptchaLoginPage> createState() => _CaptchaLoginPageState();
}

class _CaptchaLoginPageState extends State<CaptchaLoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    final phone = _mobileController.text.trim();
    final password = _passwordController.text;
    if (phone.length != 11) {
      Fluttertoast.showToast(msg: '请输入正确的手机号');
      return;
    }
    if (password.isEmpty) {
      Fluttertoast.showToast(msg: '请输入密码');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await Api().post('auth_login', data: {
        'phone': phone,
        'password': password,
      });
      if (!mounted) return;
      final data = result['data'];
      if (result['success'] == true && data != null) {
        final user = data['user'];
        Global.profile.token = data['access_token'];
        Global.profile.refreshToken = data['refresh_token'];
        Global.profile.user = User.fromApiUser(user, phone: phone);
        Global.saveProfile();
        Fluttertoast.showToast(msg: '登录成功');
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: result['message'] ?? '登录失败，请检查手机号和密码');
      }
    } catch (e) {
      LogUtil.e('登录失败: $e');
      if (!mounted) return;
      Fluttertoast.showToast(msg: '$e'.replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  '使用注册的手机号和密码登录',
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
                      controller: _passwordController,
                      hint: '请输入密码',
                      obscureText: _obscure,
                      prefixIcon: RemixIcons.shield_check_line,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          _obscure
                              ? RemixIcons.eye_off_line
                              : RemixIcons.eye_line,
                          size: 20.w,
                          color: Constants.INK,
                        ),
                      ),
                    ),
                    SizedBox(height: 44.w),
                    LimeButton(
                      text: _loading ? '登录中...' : '登  录',
                      onPressed: _login,
                    ),
                    SizedBox(height: 16.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        '没有账号？立即注册',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Constants.INK,
                        ),
                      ),
                    ),
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
