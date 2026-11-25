import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/gear_data.dart';
import 'package:FishMark/pages/gear/gear_detail_page.dart';
import 'package:FishMark/pages/gear/gear_widgets.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 4.4.1 添加装备组合
class GearComboAddPage extends StatefulWidget {
  const GearComboAddPage({super.key});

  @override
  State<GearComboAddPage> createState() => _GearComboAddPageState();
}

class _GearComboAddPageState extends State<GearComboAddPage> {
  final Set<int> _selected = {0};
  // 可选装备（编辑详情返回后可更新）
  final List<MockGear> _candidates = List.of(GearData.comboCandidates);

  /// 点击装备列表项 → 进入该装备详情页；详情内编辑保存后回填更新
  Future<void> _openDetail(int index) async {
    final updated = await Navigator.of(context).push<MockGear>(
      MaterialPageRoute(builder: (_) => GearDetailPage(gear: _candidates[index])),
    );
    if (updated != null && mounted) {
      setState(() => _candidates[index] = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.INPUT_BG,
      appBar: AppBar(
        backgroundColor: Constants.INPUT_BG,
        surfaceTintColor: Constants.INPUT_BG,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(RemixIcons.arrow_left_s_line,
              size: 26.w, color: Constants.INK),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '新建组合',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: Constants.INK,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 封面 + 更换封面
                  _cover(),
                  SizedBox(height: 16.w),
                  // 组合名称
                  _nameRow(),
                  Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Constants.BORDER),
                  // 组合描述
                  _descBlock(),
                  Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Constants.BORDER),
                  SizedBox(height: 20.w),
                  // 选择组合装备
                  Text(
                    '选择组合装备',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Constants.INK,
                    ),
                  ),
                  SizedBox(height: 12.w),
                  for (int i = 0; i < _candidates.length; i++) ...[
                    _checkRow(i, _candidates[i]),
                    if (i < _candidates.length - 1)
                      Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: Constants.BORDER),
                  ],
                ],
              ),
            ),
          ),
          // 底部保存
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 16.w),
              child: InkButton(
                text: '保存组合',
                height: 48,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 封面图（右下角更换封面）
  Widget _cover() {
    return SizedBox(
      width: double.infinity,
      height: 128.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(
            url: 'https://picsum.photos/seed/combo-lake-1/750/420',
            borderRadius: 12,
          ),
          Positioned(
            right: 12.w,
            bottom: 12.w,
            child: GestureDetector(
              onTap: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                decoration: BoxDecoration(
                  color: Constants.INK.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  '更换封面',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 组合名称行
  Widget _nameRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 14.w),
      child: Row(
        children: [
          Text('组合名称',
              style: TextStyle(fontSize: 14.sp, color: Constants.INK)),
          SizedBox(width: 2.w),
          Text(
            '*',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: kGearAsterisk,
            ),
          ),
          const Spacer(),
          Text(
            '溪流轻量组合',
            style: TextStyle(fontSize: 15.sp, color: Constants.INK),
          ),
        ],
      ),
    );
  }

  /// 组合描述块
  Widget _descBlock() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('组合描述',
              style: TextStyle(fontSize: 13.sp, color: Constants.GRAY)),
          SizedBox(height: 10.w),
          Text(
            '溪流小型鱼种，轻量灵敏，适合马口白条等。',
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.5,
              color: Constants.INK,
            ),
          ),
        ],
      ),
    );
  }

  /// 可勾选装备行：点击列表项进详情，勾选框/图标区域切换选中
  Widget _checkRow(int index, MockGear gear) {
    final checked = _selected.contains(index);
    void toggle() {
      setState(() {
        checked ? _selected.remove(index) : _selected.add(index);
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.w),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggle,
              child: _checkBox(checked),
            ),
            SizedBox(width: 14.w),
            _gearIcon(gear, checked, onToggle: toggle),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gear.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Constants.INK,
                    ),
                  ),
                  SizedBox(height: 6.w),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          gear.specLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.sp, color: Constants.GRAY),
                        ),
                      ),
                      if (gear.tag.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        GearTag(text: gear.tag, lime: gear.limeTag),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(RemixIcons.arrow_right_s_line,
                size: 20.w, color: kGearChevron),
          ],
        ),
      ),
    );
  }

  /// 装备图标区域：点击选中/取消选中，选中态 lime 边框 + 对勾角标
  Widget _gearIcon(MockGear gear, bool checked, {required VoidCallback onToggle}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        // 扩大点击区域，并为角标留出溢出空间
        padding: EdgeInsets.all(5.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: checked ? Constants.LIME : Colors.transparent,
                  width: 2,
                ),
              ),
              child: NetImage(
                url: gear.image,
                width: double.infinity,
                height: double.infinity,
                borderRadius: 8,
              ),
            ),
            if (checked)
              Positioned(
                top: -5.w,
                right: -5.w,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    color: Constants.LIME,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(RemixIcons.check_line,
                      size: 12.w, color: Constants.INK),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 圆形勾选框
  Widget _checkBox(bool checked) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? Constants.LIME : Colors.white,
        border: checked
            ? null
            : Border.all(color: const Color(0xFFD9D9D9), width: 1.5),
      ),
      child: checked
          ? Icon(RemixIcons.check_line, size: 14.w, color: Constants.INK)
          : null,
    );
  }
}
