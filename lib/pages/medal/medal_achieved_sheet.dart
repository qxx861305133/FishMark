import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/design_data.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 1.2.3 获得徽章（全屏遮罩弹窗）
class MedalAchievedSheet extends StatelessWidget {
  final String title;
  final String goal;

  const MedalAchievedSheet({
    super.key,
    this.title = '精准猎手挑战',
    this.goal = '125',
  });

  static void show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => const MedalAchievedSheet(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题：恭喜您获得新徽章
              Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '恭喜您获得',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: '新徽章',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFFF7D774), Color(0xFFC9962A)],
                        ).createShader(const Rect.fromLTWH(0, 0, 120, 40)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 56.w),
            HexMedal(style: MedalStyle.gold, size: 150),
            SizedBox(height: 48.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.w),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                children: [
                  const TextSpan(text: '解锁条件 '),
                  TextSpan(
                    text: goal,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Constants.LIME,
                    ),
                  ),
                  const TextSpan(text: ' 条马口鱼'),
                ],
              ),
            ),
            SizedBox(height: 48.w),
            SizedBox(
              width: 220.w,
              child: LimeButton(
                text: '领取徽章',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
