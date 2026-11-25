import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/gear_data.dart';
import 'package:FishMark/pages/gear/gear_widgets.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 4.3.1 添加装备 / 编辑装备（传入 gear 为编辑模式，回填数据）
class GearAddPage extends StatefulWidget {
  final MockGear? gear; // 非空 = 编辑模式

  const GearAddPage({super.key, this.gear});

  // 表单行：label / 是否必填
  static const List<(String, bool)> _rows = [
    ('品牌', true),
    ('型号', true),
    ('长度', true),
    ('硬度', true),
    ('调性', true),
    ('节数', true),
    ('适用饵重', true),
    ('适用线号', true),
    ('购入时间', true),
  ];

  @override
  State<GearAddPage> createState() => _GearAddPageState();
}

class _GearAddPageState extends State<GearAddPage> {
  // 新增模式下的默认值
  static const Map<String, String> _defaults = {
    '品牌': 'Shimano',
    '型号': 'STREAM 702ML',
    '长度': '2.13m',
    '硬度': 'ML（中轻）',
    '调性': 'Fast（快）',
    '节数': '3',
    '适用饵重': '5–18g',
    '适用线号': 'PE 0.6–1.5号',
    '购入时间': '2025年12月28日',
  };

  late final Map<String, TextEditingController> _controllers;

  bool get _isEdit => widget.gear != null;

  @override
  void initState() {
    super.initState();
    final gear = widget.gear;
    // 编辑模式：从 specLine（如 "2.13m · ML · 5–18g"）拆出长度/硬度/饵重回填
    final specs = gear == null
        ? const <String>[]
        : gear.specLine.split('·').map((e) => e.trim()).toList();
    String valueOf(String label, int specIndex) {
      if (specIndex < specs.length && specs[specIndex].isNotEmpty) {
        return specs[specIndex];
      }
      return _defaults[label]!;
    }

    _controllers = {
      for (final (label, _) in GearAddPage._rows)
        label: TextEditingController(text: switch (label) {
          '品牌' => gear?.brand ?? _defaults['品牌']!,
          '型号' => gear?.model ?? _defaults['型号']!,
          '长度' => valueOf('长度', 0),
          '硬度' => valueOf('硬度', 1),
          '适用饵重' => valueOf('适用饵重', 2),
          _ => _defaults[label]!,
        }),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// 保存：编辑模式回传更新后的装备，新增模式直接返回
  void _save() {
    final gear = widget.gear;
    if (gear == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(gear.copyWith(
      brand: _controllers['品牌']!.text.trim(),
      model: _controllers['型号']!.text.trim(),
      specLine:
          '${_controllers['长度']!.text.trim()} · ${_controllers['硬度']!.text.trim()} · ${_controllers['适用饵重']!.text.trim()}',
    ));
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
          _isEdit ? '编辑装备' : '添加装备',
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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 16.w, bottom: 16.w),
                child: Column(
                  children: [
                    _photoRow(),
                    SizedBox(height: 8.w),
                    // 表单行
                    for (final (label, required) in GearAddPage._rows) ...[
                      _formRow(label, required: required),
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: Constants.BORDER,
                        indent: 16.w,
                      ),
                    ],
                    _remarkRow(),
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Constants.BORDER,
                      indent: 16.w,
                    ),
                    _statusRow(),
                  ],
                ),
              ),
            ),
          ),
          // 底部保存
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 16.w),
              child: InkButton(
                text: '保存',
                height: 48,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 照片上传行：2 张已传 + 上传占位
  Widget _photoRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          for (final url in GearData.addPhotos) ...[
            NetImage(url: url, width: 96.w, height: 96.w, borderRadius: 12),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: GestureDetector(
              onTap: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
              child: Container(
                height: 96.w,
                decoration: BoxDecoration(
                  color: Constants.INPUT_BG,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RemixIcons.add_circle_line,
                        size: 22.w, color: Constants.INK),
                    SizedBox(height: 6.w),
                    Text(
                      '上传照片',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Constants.INK,
                      ),
                    ),
                    SizedBox(height: 2.w),
                    Text(
                      '（支持多张）',
                      style: TextStyle(
                          fontSize: 10.sp, color: Constants.GRAY_LIGHT),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 表单行：label(+*) 左，可编辑输入右（编辑模式回填）
  Widget _formRow(String label, {bool required = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      constraints: BoxConstraints(minHeight: 46.w),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 14.sp, color: Constants.INK)),
          if (required) ...[
            SizedBox(width: 2.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: kGearAsterisk,
              ),
            ),
          ],
          SizedBox(width: 24.w),
          Expanded(
            child: TextField(
              controller: _controllers[label],
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15.sp, color: Constants.INK),
              cursorColor: Constants.INK,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 备注行：label 左，多行文案右
  Widget _remarkRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('备注',
              style: TextStyle(fontSize: 14.sp, color: Constants.INK)),
          SizedBox(width: 40.w),
          Expanded(
            child: Text(
              GearData.detailNote,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: Constants.INK,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 使用状态行：右侧标签（编辑模式回填装备当前状态）+ 箭头
  Widget _statusRow() {
    final statusTag =
        (widget.gear?.tag.isNotEmpty ?? false) ? widget.gear!.tag : '常用';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      constraints: BoxConstraints(minHeight: 52.w),
      child: Row(
        children: [
          Text('使用状态',
              style: TextStyle(fontSize: 14.sp, color: Constants.INK)),
          const Spacer(),
          GearTag(text: statusTag),
          SizedBox(width: 8.w),
          Icon(RemixIcons.arrow_right_s_line,
              size: 18.w, color: Constants.GRAY_LIGHT),
        ],
      ),
      ),
    );
  }
}
