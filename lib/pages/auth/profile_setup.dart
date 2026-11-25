import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/pages/home.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 0.4.1 基础信息（登录后完善昵称/头像/位置）
class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TopGradientBox(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 右上角跳过
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(pagePadding),
                  child: GestureDetector(
                    onTap: () => _goHome(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '跳过',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF21582F),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36.w),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    NetImage(
                      url: 'https://picsum.photos/seed/luji-avatar/240/240',
                      width: 96.w,
                      height: 96.w,
                      borderRadius: 48.w,
                    ),
                    Positioned(
                      right: -2.w,
                      bottom: 0,
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Constants.LIME,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                        child: Icon(
                          RemixIcons.camera_fill,
                          size: 18.w,
                          color: Constants.INK,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 68.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Column(
                  children: [
                    FillInput(hint: '请输入您的昵称'),
                    SizedBox(height: 16.w),
                    FillInput(
                      hint: '请选择您的位置',
                      suffix: Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Icon(
                          RemixIcons.map_pin_2_fill,
                          size: 20.w,
                          color: Constants.INK,
                        ),
                      ),
                    ),
                    SizedBox(height: 44.w),
                    LimeButton(
                      text: '确 定',
                      onPressed: () => _goHome(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }
}
