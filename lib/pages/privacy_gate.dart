import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/pages/auth/agreement_page.dart';
import 'package:FishMark/pages/auth/login.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 隐私协议授权页
class PrivacyGatePage extends StatefulWidget {
  const PrivacyGatePage({super.key});

  @override
  State<PrivacyGatePage> createState() => _PrivacyGatePageState();
}

class _PrivacyGatePageState extends State<PrivacyGatePage> {
  bool _isAgree = false;

  /// 同意并继续
  Future<void> _handleAgree() async {
    if (!_isAgree) {
      Fluttertoast.showToast(
        msg: '请先勾选同意协议',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    await Global.setPrivacyAgreed(true);
    LogUtil.v('✅ 用户同意隐私协议');

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  /// 暂不使用
  void _handleRefuse() {
    Fluttertoast.showToast(
      msg: '需同意协议后才能使用路记App',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TopGradientBox(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 80.w),
              const AppLogo(size: 88),
              SizedBox(height: 24.w),
              Text(
                Constants.APP_NAME,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Constants.INK,
                ),
              ),
              SizedBox(height: 8.w),
              Text(
                Constants.APP_SLOGAN,
                style: TextStyle(fontSize: 14.sp, color: Constants.GRAY),
              ),
              SizedBox(height: 40.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Constants.INPUT_BG,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    Constants.PrivacyPolicyText,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.6,
                      color: Constants.GRAY,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.w),
              // 勾选协议
              GestureDetector(
                onTap: () => setState(() => _isAgree = !_isAgree),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAgree
                            ? RemixIcons.checkbox_circle_fill
                            : RemixIcons.checkbox_blank_circle_line,
                        size: 18.w,
                        color: _isAgree ? Constants.LIME : Constants.GRAY_LIGHT,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '我已阅读并同意',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Constants.GRAY,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openAgreement('用户协议'),
                        child: Text(
                          '《用户协议》',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Constants.INK,
                          ),
                        ),
                      ),
                      Text(
                        '和',
                        style: TextStyle(fontSize: 12.sp, color: Constants.GRAY),
                      ),
                      GestureDetector(
                        onTap: () => _openAgreement('隐私协议'),
                        child: Text(
                          '《隐私政策》',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Constants.INK,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: LimeButton(text: '同意并继续', onPressed: _handleAgree),
              ),
              SizedBox(height: 16.w),
              TextButton(
                onPressed: _handleRefuse,
                child: Text(
                  '暂不使用',
                  style: TextStyle(fontSize: 13.sp, color: Constants.GRAY_LIGHT),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAgreement(String title) {
    AgreementPage.show(context, title: title);
  }
}
