import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/global.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/pages/auth/login.dart';

/// @desc 隐私协议授权页
class PrivacyGatePage extends StatefulWidget {
  const PrivacyGatePage({super.key});

  @override
  State<PrivacyGatePage> createState() => _PrivacyGatePageState();
}

class _PrivacyGatePageState extends State<PrivacyGatePage> {
  bool _isAgree = false;
  bool _submitting = false;

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
    setState(() => _submitting = true);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Column(
            children: [
              SizedBox(height: 160.w),
              Icon(Icons.phishing, size: 140.w, color: Constants.PRIMARY_COLOR),
              SizedBox(height: 24.w),
              Text(
                Constants.APP_NAME,
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.TEXT_DEFAULT_COLOR,
                ),
              ),
              Text(
                Constants.APP_SLOGAN,
                style: TextStyle(
                  fontSize: 26.sp,
                  color: Constants.TEXT_SECONDARY_COLOR,
                ),
              ),
              SizedBox(height: 96.w),
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: Constants.BG_COLOR,
                  borderRadius: BorderRadius.circular(24.w),
                ),
                child: Text(
                  Constants.PrivacyPolicyText,
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: 32.w),
              GestureDetector(
                onTap: () => setState(() => _isAgree = !_isAgree),
                behavior: HitTestBehavior.opaque,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  spacing: 2.w,
                  runSpacing: 8.w,
                  children: [
                    Icon(
                      _isAgree
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 36.w,
                      color: _isAgree
                          ? Constants.PRIMARY_COLOR
                          : Constants.TEXT_LIGHT_COLOR,
                    ),
                    Text('我已阅读并同意', style: TextStyle(fontSize: 26.sp)),
                    Text(
                      '《用户协议》',
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: Constants.PRIMARY_COLOR,
                      ),
                    ),
                    Text('和', style: TextStyle(fontSize: 26.sp)),
                    Text(
                      '《隐私政策》',
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: Constants.PRIMARY_COLOR,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.w),
              SizedBox(
                width: double.infinity,
                height: 88.w,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _handleAgree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.PRIMARY_COLOR,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(44.w),
                    ),
                  ),
                  child: Text(
                    '同意并继续',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.w),
              TextButton(
                onPressed: _handleRefuse,
                child: Text(
                  '暂不使用',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_LIGHT_COLOR,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
