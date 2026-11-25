import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';

/// @desc 装备模块共用小组件（1104 设计稿取色）

// 装备模块辅助色（设计稿精确取色）
const Color kGearSageBg = Color(0xFFE4EBE6); // 「常用/数量」标签底色
const Color kGearSageText = Color(0xFF21582F); // 标签文字
const Color kGearChipText = Color(0xFF6E85A3); // 未选中筛选/分段文字
const Color kGearChevron = Color(0xFFC1D1E6); // 列表右箭头
const Color kGearSpecLabel = Color(0xFF7B93B2); // 详情规格标签
const Color kGearAsterisk = Color(0xFFFF4B4B); // 必填星号

/// 装备状态标签（常用 / 使用中 / 数量 *3）
class GearTag extends StatelessWidget {
  final String text;
  final bool lime;

  const GearTag({super.key, required this.text, this.lime = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
      decoration: BoxDecoration(
        color: lime ? Constants.LIME : kGearSageBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          height: 1.0,
          fontWeight: FontWeight.w500,
          color: lime ? Constants.INK : kGearSageText,
        ),
      ),
    );
  }
}

/// 顶部「我的装备 / 装备组合」分段切换
class GearSegmented extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const GearSegmented({super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['我的装备', '装备组合'];
    return Container(
      height: 36.w,
      decoration: BoxDecoration(
        color: Constants.INPUT_BG,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36.w,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == index ? Constants.INK : Colors.transparent,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: i == index ? FontWeight.w600 : FontWeight.w400,
                    color: i == index ? Colors.white : kGearChipText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 右上角荧光绿「+ 添加装备 / 新建组合」按钮
class GearAddButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const GearAddButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Constants.LIME,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          height: 36.w,
          padding: EdgeInsets.only(left: 6.w, right: 14.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(color: Constants.INK, shape: BoxShape.circle),
                child: Icon(RemixIcons.add_line, size: 14.w, color: Constants.LIME),
              ),
              SizedBox(width: 6.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Constants.INK,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 装备分类筛选胶囊
class GearCategoryChip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback? onTap;

  const GearCategoryChip({super.key, required this.text, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Constants.LIME : Constants.INPUT_BG,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? Constants.INK : kGearChipText,
          ),
        ),
      ),
    );
  }
}
