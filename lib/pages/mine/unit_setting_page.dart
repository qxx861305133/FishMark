import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/mine_data.dart';

/// @desc 5.3.3 计量单位
class UnitSettingPage extends StatefulWidget {
  const UnitSettingPage({super.key});

  @override
  State<UnitSettingPage> createState() => _UnitSettingPageState();
}

class _UnitSettingPageState extends State<UnitSettingPage> {
  // 每组选中的选项下标，默认公制
  final List<int> _selected =
      List<int>.generate(MineData.unitGroups.length, (_) => 0);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Constants.INPUT_BG,
        appBar: _buildAppBar(context),
        body: ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 40.w),
          itemCount: MineData.unitGroups.length,
          itemBuilder: (_, index) {
            final group = MineData.unitGroups[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 20.w),
              child: _buildGroupCard(index, group),
            );
          },
        ),
      ),
    );
  }

  // 顶部导航
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    return PreferredSize(
      preferredSize: Size.fromHeight(statusBar + 44.w),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 44.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '计量单位',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Constants.INK,
                  ),
                ),
                Positioned(
                  left: 10.w,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(RemixIcons.arrow_left_s_line,
                        size: 26.w, color: Constants.INK),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 分组卡片
  Widget _buildGroupCard(int groupIndex, UnitGroup group) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, top: 2.w),
            child: Text(
              group.title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Constants.INK,
              ),
            ),
          ),
          SizedBox(height: 14.w),
          Row(
            children: List.generate(group.options.length, (optionIndex) {
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: optionIndex == 0 ? 0 : 10.w),
                  child: _buildOptionTile(
                    group.title,
                    group.options[optionIndex],
                    selected: _selected[groupIndex] == optionIndex,
                    onTap: () {
                      setState(() => _selected[groupIndex] = optionIndex);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 选项块
  Widget _buildOptionTile(
    String groupTitle,
    UnitOption option, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color strong = const Color(0xFF7B93B2); // 选中图标色
    final Color weak = const Color(0xFFB0C1D8); // 未选中图标色
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.w,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Constants.INPUT_BG,
          borderRadius: BorderRadius.circular(14.r),
          border: selected
              ? Border.all(color: const Color(0xFFD9D9D9), width: 1.2.w)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _unitIcon(groupTitle, option.code, selected ? strong : weak),
            SizedBox(height: 12.w),
            // 选中圆点 + 文案
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _checkDot(selected),
                SizedBox(width: 6.w),
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: selected ? Constants.INK : Constants.GRAY_LIGHT,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 选中/未选中圆点
  Widget _checkDot(bool selected) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Constants.LIME : Colors.white,
        border: selected
            ? null
            : Border.all(color: const Color(0xFFC9CED6), width: 1.5.w),
      ),
      child: selected
          ? Icon(RemixIcons.check_line, size: 14.w, color: Constants.INK)
          : null,
    );
  }

  // 单位图标（按分组绘制不同形态）
  Widget _unitIcon(String groupTitle, String code, Color color) {
    Widget shape;
    switch (groupTitle) {
      case '深度 / 距离':
        // 立柱 + 上下双箭头
        shape = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _block(code, 30.w, 46.w, 8.r, color, 13.sp),
            SizedBox(width: 6.w),
            Icon(RemixIcons.arrow_up_down_line, size: 18.w, color: color),
          ],
        );
        break;
      case '重量':
        // 壶铃：提手 + 方块
        shape = Column(
          children: [
            Container(
              width: 18.w,
              height: 10.w,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: color, width: 2.5.w),
                  left: BorderSide(color: color, width: 2.5.w),
                  right: BorderSide(color: color, width: 2.5.w),
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(9.r)),
              ),
            ),
            _block(code, 42.w, 36.w, 8.r, color, 13.sp),
          ],
        );
        break;
      case '尺寸':
        // 方块 + 左右双箭头
        shape = Column(
          children: [
            _block(code, 40.w, 24.w, 6.r, color, 12.sp),
            SizedBox(height: 6.w),
            Icon(RemixIcons.arrow_left_right_line, size: 18.w, color: color),
          ],
        );
        break;
      case '气瓶压力':
        // 压力表：半圆顶
        shape = Column(
          children: [
            Container(
              width: 40.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
            ),
            _block('', 40.w, 20.w, 0, color, 12.sp,
                radiusGeometry: const BorderRadius.vertical(
                    bottom: Radius.circular(6))),
          ],
        );
        break;
      case '温度':
      default:
        // 温度计：细长条
        shape = _block(code, 30.w, 46.w, 15.r, color, 13.sp);
        break;
    }
    return SizedBox(height: 50.w, child: Center(child: shape));
  }

  // 单位色块
  Widget _block(
    String text,
    double width,
    double height,
    double radius,
    Color color,
    double fontSize, {
    BorderRadius? radiusGeometry,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radiusGeometry ?? BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: text.isEmpty
          ? null
          : Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
    );
  }
}
