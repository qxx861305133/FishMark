import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 0.3.1 用户协议 / 0.3.2 隐私协议
class AgreementPage extends StatelessWidget {
  final String title;
  final VoidCallback? onConfirm;

  const AgreementPage({super.key, required this.title, this.onConfirm});

  /// 从底部弹出（sheet 形式）
  static void show(
    BuildContext context, {
    required String title,
    VoidCallback? onConfirm,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        // 遮罩由路由 barrier 提供：固定淡入淡出，不随 sheet 滑动
        barrierColor: Colors.black54,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => AgreementPage(title: title, onConfirm: onConfirm),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
            child: child,
          );
        },
        reverseTransitionDuration: const Duration(milliseconds: 260),
      ),
    );
  }

  static const String _demoText = '用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换用户服务协议文案待替换';

  @override
  Widget build(BuildContext context) {
    // 背景透明：黑色遮罩由路由 barrierColor 提供（固定不动），本页只放 sheet
    return Scaffold(
      backgroundColor: Colors.transparent,
      // sheet 固定在底部、直接顶到屏幕底部（不留出底部安全区，避免下缘露出黑色遮罩）
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 88.w),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(height: 24.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.INK,
                ),
              ),
              SizedBox(height: 20.w),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    _demoText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.7,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
              ),
              // 底部按钮包 SafeArea，内容不被 Home Indicator 压住
              Padding(
                padding: EdgeInsets.fromLTRB(pagePadding, 8.w, pagePadding, 8.w),
                child: SafeArea(
                  top: false,
                  child: InkButton(
                    text: '我已知晓',
                    onPressed: onConfirm ?? () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
