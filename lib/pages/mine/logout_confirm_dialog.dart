import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/pages/auth/login.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 5.3.10 退出登录确认弹窗
class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(21.w, 30.w, 21.w, 21.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '确定要退出登录吗?',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Constants.INK,
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              '退出后将无法同步你的数据',
              style: TextStyle(
                fontSize: 13.sp,
                color: Constants.GRAY_LIGHT,
              ),
            ),
            SizedBox(height: 24.w),
            Row(
              children: [
                // 取消
                Expanded(
                  child: GhostButton(
                    text: '取消',
                    height: 44,
                    fontSize: 15,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 16.w),
                // 退出登录
                Expanded(
                  child: LimeButton(
                    text: '退出登录',
                    height: 44,
                    fontSize: 15,
                    background: const Color(0xFFFF5454),
                    textColor: Colors.white,
                    onPressed: () {
                      // 清除登录态并回到登录页
                      Global.logout();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
