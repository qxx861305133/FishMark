import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/report_data.dart';
import 'package:FishMark/pages/report/gear_add_page.dart';
import 'package:FishMark/pages/upload/spot_map_page.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 3.3.2 / 3.3.3 记录渔获 - 记录详情（我的装备 / 常用组合）
class CatchRecordPage extends StatefulWidget {
  const CatchRecordPage({super.key, this.imagePath});

  // 用户拍摄/选择的渔获照片本地路径（空则回退 mock 示例图）
  final String? imagePath;

  @override
  State<CatchRecordPage> createState() => _CatchRecordPageState();
}

class _CatchRecordPageState extends State<CatchRecordPage> {
  // 0 我的装备 / 1 常用组合
  int _tab = 0;
  // 已勾选装备
  final Set<int> _gearChecked = {0, 1};
  // 已勾选组合
  final Set<int> _comboChecked = {0};

  @override
  Widget build(BuildContext context) {
    final record = ReportData.catchRecord;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(RemixIcons.arrow_left_line, size: 24.w, color: Constants.INK),
        ),
        title: Text(
          '记录渔获',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Constants.INK),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 16.w),
              children: [
                // 渔获照片（用户实拍优先）
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: widget.imagePath != null
                          ? Image.file(
                              File(widget.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const NetImagePlaceholder(),
                            )
                          : Image.network(
                              record.photo,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : const NetImagePlaceholder(),
                              errorBuilder: (_, _, _) =>
                                  const NetImagePlaceholder(),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24.w),
                // 基础信息
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Text(
                    '基础信息',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Constants.INK,
                    ),
                  ),
                ),
                SizedBox(height: 8.w),
                _infoRow('鱼种', value: record.species, required: true),
                _infoRow('长度', value: record.length),
                _infoRow('重量', value: record.weight),
                _infoRow('钓获时间', value: record.time),
                _infoRow('钓点', value: record.spot, showPin: true, onTap: _goSpotUpload),
                SizedBox(height: 24.w),
                // 使用装备 + tab 切换
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '使用装备',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Constants.INK,
                        ),
                      ),
                      Row(
                        children: [
                          _tabPill('我的装备', 0),
                          SizedBox(width: 8.w),
                          _tabPill('常用组合', 1),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.w),
                if (_tab == 0) _buildGearList() else _buildComboList(),
              ],
            ),
          ),
          // 底部保存
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 12.w),
              child: InkButton(
                text: '保存记录',
                height: 48,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 保存记录
  void _save() {
    Fluttertoast.showToast(msg: '渔获记录已保存');
    Navigator.of(context).pop();
  }

  // 点击钓点 → 去上传钓点
  void _goSpotUpload() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpotMapPage()),
    );
  }

  // tab 胶囊
  Widget _tabPill(String text, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        height: 30.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Constants.INK : Constants.INPUT_BG,
          borderRadius: BorderRadius.circular(15.w),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Constants.GRAY,
          ),
        ),
      ),
    );
  }

  // 基础信息行
  Widget _infoRow(String label, {String value = '', bool required = false, bool showPin = false, VoidCallback? onTap}) {
    final row = Container(
      height: 52.w,
      padding: EdgeInsets.symmetric(horizontal: pagePadding),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Constants.BORDER)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15.sp, color: Constants.INK),
          ),
          if (required) ...[
            SizedBox(width: 2.w),
            Text(
              '*',
              style: TextStyle(fontSize: 15.sp, color: Constants.ERROR_COLOR),
            ),
          ],
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Constants.INK,
            ),
          ),
          if (showPin) ...[
            SizedBox(width: 6.w),
            Icon(RemixIcons.map_pin_fill, size: 18.w, color: Constants.INK),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return GestureDetector(onTap: onTap, child: row);
  }

  // 我的装备列表
  Widget _buildGearList() {
    return Column(
      children: [
        for (var i = 0; i < ReportData.myGears.length; i++)
          _gearRow(ReportData.myGears[i], i),
        // 添加装备入口（记录流程内）
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.w, 24.w, 0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GearAddPage()),
              );
            },
            child: Container(
              height: 44.w,
              decoration: BoxDecoration(
                color: Constants.INPUT_BG,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(RemixIcons.add_circle_line, size: 18.w, color: Constants.GRAY),
                  SizedBox(width: 6.w),
                  Text(
                    '添加装备',
                    style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 装备条目
  Widget _gearRow(RecordGearItem gear, int index) {
    final checked = _gearChecked.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        checked ? _gearChecked.remove(index) : _gearChecked.add(index);
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: pagePadding, vertical: 12.w),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Constants.BORDER)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                gear.image,
                width: 56.w,
                height: 56.w,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const NetImagePlaceholder(),
                errorBuilder: (_, _, _) => const NetImagePlaceholder(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gear.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Constants.INK,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Row(
                    children: [
                      Text(
                        gear.sub,
                        style: TextStyle(fontSize: 12.sp, color: Constants.GRAY_LIGHT),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4EBE6),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          gear.tag,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF21582F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _checkCircle(checked),
          ],
        ),
      ),
    );
  }

  // 常用组合列表
  Widget _buildComboList() {
    return Column(
      children: [
        for (var i = 0; i < ReportData.combos.length; i++)
          _comboRow(ReportData.combos[i], i),
      ],
    );
  }

  // 组合条目
  Widget _comboRow(RecordComboItem combo, int index) {
    final checked = _comboChecked.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        checked ? _comboChecked.remove(index) : _comboChecked.add(index);
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: pagePadding, vertical: 12.w),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Constants.BORDER)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                combo.image,
                width: 56.w,
                height: 56.w,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const NetImagePlaceholder(),
                errorBuilder: (_, _, _) => const NetImagePlaceholder(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    combo.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Constants.INK,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    combo.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: Constants.GRAY_LIGHT),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _checkCircle(checked),
          ],
        ),
      ),
    );
  }

  // 勾选圆点：荧光绿选中 / 白底描边未选
  Widget _checkCircle(bool checked) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: checked ? Constants.LIME : Colors.white,
        shape: BoxShape.circle,
        border: checked
            ? null
            : Border.all(color: Constants.BORDER, width: 1.5.w),
      ),
      child: checked
          ? Icon(RemixIcons.check_line, size: 14.w, color: Constants.INK)
          : null,
    );
  }
}
