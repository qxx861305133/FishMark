import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// 当前定位是否已授权（只查询，不弹任何框）
Future<bool> hasLocationPermission() async {
  final status = await Permission.locationWhenInUse.status;
  return status.isGranted || status.isLimited;
}

/// 应用内统一权限弹窗（全局风格：透明 Dialog + F8F8F8 圆角容器 +
/// GhostButton/LimeButton）。
///
/// - [confirmText] 为「去设置」时：确认后自动跳系统设置。
/// - 返回 true 表示用户点了确认按钮。
Future<bool> showStyledPermissionDialog(
  BuildContext context, {
  required String title,
  required String desc,
  String cancelText = '取消',
  String confirmText = '去设置',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
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
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Constants.INK,
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: Constants.GRAY_LIGHT,
              ),
            ),
            SizedBox(height: 24.w),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    text: cancelText,
                    height: 44,
                    fontSize: 15,
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: LimeButton(
                    text: confirmText,
                    height: 44,
                    fontSize: 15,
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

/// 定位权限统一处理（iOS / Android）：
/// 1. 已授权 → 直接返回 true
/// 2. 未授权 → 弹系统授权框；Android 未永久拒绝时，再次进入会重新弹系统框
/// 3. 拒绝过 / 永久拒绝 → 弹应用内引导弹窗（项目统一风格），确认后跳系统设置
///
/// 返回 true 表示定位权限已就绪。
Future<bool> ensureLocationPermission(BuildContext context) async {
  var status = await Permission.locationWhenInUse.status;
  if (status.isGranted || status.isLimited) return true;

  // 先尝试系统授权框：未决定、或 Android 未永久拒绝（再次唤醒）时会弹出
  if (!status.isPermanentlyDenied) {
    status = await Permission.locationWhenInUse.request();
    if (status.isGranted || status.isLimited) return true;
  }
  // 拒绝过（iOS 拒绝后系统不再弹框 / Android 永久拒绝）：引导去系统设置
  if (!context.mounted) return false;
  final open = await showStyledPermissionDialog(
    context,
    title: '定位权限未开启',
    desc: '开启定位后才能展示当前位置和附近钓点\n请在系统设置中允许访问位置信息',
  );
  if (open) {
    await openAppSettings();
  }
  return false;
}

/// 「去设置」通用引导弹窗（相机/相册/定位等权限统一使用）
Future<void> showPermissionSettingsDialog(
  BuildContext context, {
  required String title,
  required String desc,
}) async {
  final open = await showStyledPermissionDialog(
    context,
    title: title,
    desc: desc,
  );
  if (open) {
    await openAppSettings();
  }
}
