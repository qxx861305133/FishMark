import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/pages/report/catch_capture_page.dart';
import 'package:FishMark/widgets/ui_kit.dart';
import 'package:FishMark/pages/report/gear_add_page.dart';
import 'package:FishMark/pages/upload/ai_fish_capture_page.dart';
import 'package:FishMark/pages/upload/spot_map_page.dart';

/// @desc 3.1 上传
class PublishSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isScrollControlled: true,
      builder: (_) => const _PublishSheetBody(),
    );
  }
}

class _PublishSheetBody extends StatelessWidget {
  const _PublishSheetBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetOption(
            label: 'AI 识鱼',
            icon: RemixIcons.scan_2_line,
            highlight: true,
            onTap: () => _push(context, const AiFishCapturePage()),
          ),
          SizedBox(height: 24.w),
          _SheetOption(
            label: '鱼获记录',
            icon: RemixIcons.sailboat_line,
            onTap: () => _push(context, const CatchCapturePage()),
          ),
          SizedBox(height: 24.w),
          _SheetOption(
            label: '钓点上传',
            icon: RemixIcons.map_pin_line,
            onTap: () => _push(context, const SpotMapPage()),
          ),
          SizedBox(height: 24.w),
          _SheetOption(
            label: '装备上传',
            icon: RemixIcons.briefcase_line,
            onTap: () => _push(context, const GearAddPage()),
          ),
          SizedBox(height: 24.w),
          // 关闭按钮：荧光绿圆形
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: Constants.LIME,
                shape: BoxShape.circle,
              ),
              child: Icon(RemixIcons.close_line, size: 26.w, color: Constants.INK),
            ),
          ),
          SizedBox(height: 24.w),
        ],
      ),
    );
  }

  // 关闭面板后跳转对应页面
  void _push(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

/// 面板选项按钮：首项荧光绿，其余白色渐变卡片
class _SheetOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlight;
  final VoidCallback onTap;

  const _SheetOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = highlight ? 88.0 : 84.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.w,
        margin: EdgeInsets.symmetric(horizontal: pagePadding),
        decoration: BoxDecoration(
          gradient: highlight
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFF0F1F6)],
                ),
          color: highlight ? Constants.LIME : null,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24.w,
              offset: Offset(0, 8.w),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22.w, color: Constants.INK),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Constants.INK,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
