import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/design_data.dart';
import 'package:FishMark/mock/explore_data.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 2.2.2 鱼种图鉴 - 新鱼种
class FishGuidePage extends StatelessWidget {
  const FishGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final record = newFishRecord;
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 模糊的图鉴背景
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: NetImage(
              url: record.bgImage,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.w, 24.w, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: const CircleBackButton(),
                  ),
                ),
                SizedBox(height: 26.w),
                _buildTitle(),
                SizedBox(height: 28.w),
                _buildHeroCard(record),
                SizedBox(height: 20.w),
                _buildAchievementCard(record),
                const Spacer(),
                _buildActions(),
                SizedBox(height: 24.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 标题：恭喜您获得新记录
  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: -0.7,
          child: Icon(RemixIcons.leaf_fill,
              size: 22.w, color: Colors.white.withValues(alpha: 0.92)),
        ),
        SizedBox(width: 10.w),
        Text(
          '恭喜您获得',
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        _GoldText(
          text: '新记录',
          fontSize: 30,
        ),
        SizedBox(width: 10.w),
        Transform.flip(
          flipX: true,
          child: Transform.rotate(
            angle: -0.7,
            child: Icon(RemixIcons.leaf_fill,
                size: 22.w, color: Colors.white.withValues(alpha: 0.92)),
          ),
        ),
      ],
    );
  }

  // 新鱼种大卡
  Widget _buildHeroCard(NewFishRecord record) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      height: 353.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(url: record.heroImage, width: double.infinity, height: double.infinity),
          // 底部压暗
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 14.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    Text(
                      '记录',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _RecordPill(text: record.length),
                    SizedBox(width: 8.w),
                    _RecordPill(text: record.weight),
                  ],
                ),
                SizedBox(height: 12.w),
                Row(
                  children: [
                    Icon(RemixIcons.map_pin_fill,
                        size: 15.w, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      record.place,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      record.date,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 成就卡（金色描边）
  Widget _buildAchievementCard(NewFishRecord record) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF9C7226), Color(0xFFF3D27A), Color(0xFF9C7226)],
        ),
      ),
      padding: EdgeInsets.all(1.2.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            HexMedal(style: MedalStyle.gold, size: 44),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GoldText(text: record.achievement, fontSize: 16),
                  SizedBox(height: 4.w),
                  Text(
                    record.achievementDesc,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Constants.GRAY,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 底部操作：保存图片 / 分享图鉴
  Widget _buildActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
              child: Container(
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: Text(
                  '保存图片',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: LimeButton(
                  text: '分享图鉴',
                  height: 44,
                  onPressed: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
                ),
          ),
        ],
      ),
    );
  }
}

/// 金色渐变文字
class _GoldText extends StatelessWidget {
  final String text;
  final double fontSize;

  const _GoldText({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFE49B), Color(0xFFF3BC3F)],
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}

/// 记录数据小胶囊（17.31cm / 4.2kg）
class _RecordPill extends StatelessWidget {
  final String text;

  const _RecordPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
