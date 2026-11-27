import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/pages/auth/captcha_login.dart';
import 'package:FishMark/pages/auth/register.dart';
import 'package:FishMark/pages/auth/agreement_page.dart';
import 'package:FishMark/pages/home.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 0.2.1 选择登录方式
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 已登录直接进首页
    if (Global.profile.user?.is_login == true) {
      Future.microtask(_goHome);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: TopGradientBox(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo(size: 88),
                    SizedBox(height: 88.w),
                    Text(
                      '每一尾皆是勋章',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Constants.INK,
                      ),
                    ),
                    SizedBox(height: 24.w),
                    Text(
                      '记录每一次出钓，遇见每一片水域',
                      style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Column(
                  children: [
                    LimeButton(
                      text: '手机号密码登录',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CaptchaLoginPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.w),
                    GhostButton(
                      text: '注册新账号',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40.w),
                    _thirdPartyRow(),
                  ],
                ),
              ),
              SizedBox(height: 56.w),
              AgreementFooter(
                onUserAgreement: () {
                  AgreementPage.show(context, title: '用户协议');
                },
                onPrivacyAgreement: () {
                  AgreementPage.show(context, title: '隐私政策');
                },
              ),
              SizedBox(height: 28.w),
            ],
          ),
        ),
      ),
    );
  }

  /// 第三方登录：微信 / Apple ID / Google
  Widget _thirdPartyRow() {
    final items = [
      (RemixIcons.wechat_fill, '微信登录', const Color(0xFF09BB07), Colors.white),
      (RemixIcons.apple_fill, 'Apple ID', const Color(0xFFF2F3F5), Constants.INK),
      (RemixIcons.google_fill, 'Google', const Color(0xFFF2F3F5), const Color(0xFF4285F4)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (icon, label, bg, fg) in items)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
            child: Column(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, size: 24.w, color: fg),
                ),
                SizedBox(height: 10.w),
                Text(
                  label,
                  style: TextStyle(fontSize: 12.sp, color: Constants.INK),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
