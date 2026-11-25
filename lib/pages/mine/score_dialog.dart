import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 5.3.8 去评分弹窗（未选灰色 / 选中金色，支持点击与拖动打分）
class ScoreDialog extends StatefulWidget {
  const ScoreDialog({super.key});

  @override
  State<ScoreDialog> createState() => _ScoreDialogState();
}

class _ScoreDialogState extends State<ScoreDialog> {
  static const Color _gold = Color(0xFFFDC541);
  static const Color _grey = Color(0xFFD9D9D9);

  int _rating = 0; // 0 未打分，1~5 星

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 弹窗主体
          Container(
            margin: EdgeInsets.only(top: 44.w),
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 58.w, 24.w, 24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Global.t('喜欢路记吗？\n给我们一个好评吧！',
                      'Enjoying LuJi?\nGive us a rating!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.sp,
                    height: 1.55,
                    fontWeight: FontWeight.w700,
                    color: Constants.INK,
                  ),
                ),
                SizedBox(height: 22.w),
                _buildStars(),
                SizedBox(height: 26.w),
                InkButton(
                  text: Global.t('去评分', 'Rate Us'),
                  height: 46,
                  onPressed: () {
                    Fluttertoast.showToast(
                      msg: _rating > 0
                          ? Global.t(
                              '感谢您的 $_rating 星好评（演示）', 'Thanks for $_rating stars (demo)')
                          : Global.t('请先选择星级', 'Please pick a star first'),
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          // 顶部 Logo（一半露出弹窗外）
          Positioned(
            top: 0,
            child: AppLogo(size: 88),
          ),
        ],
      ),
    );
  }

  // 五星评分：点击 / 横向拖动均可打分
  Widget _buildStars() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _rateFromX(d.localPosition.dx, width),
          onHorizontalDragUpdate: (d) => _rateFromX(d.localPosition.dx, width),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final selected = index < _rating;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Icon(
                  RemixIcons.star_fill,
                  size: 30.w,
                  color: selected ? _gold : _grey,
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // 根据横向坐标换算星级（1~5）
  void _rateFromX(double dx, double width) {
    if (width <= 0) return;
    final int stars = (dx / width * 5).ceil().clamp(1, 5);
    if (stars != _rating) {
      setState(() => _rating = stars);
    }
  }
}
