import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/mock/report_data.dart';
import 'package:FishMark/utils/media_picker_util.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 3.5.1 添加装备（记录流程内：照片真实上传，提交走 gear_submit）
class GearAddPage extends StatefulWidget {
  const GearAddPage({super.key});

  @override
  State<GearAddPage> createState() => _GearAddPageState();
}

class _GearAddPageState extends State<GearAddPage> {
  // 本地选取的装备照片（真实选图，提交时上传）
  final List<XFile> _pickedPhotos = [];
  // 表单行输入（label → controller）
  late final Map<String, TextEditingController> _rowControllers = {
    for (final row in ReportData.gearForm.rows)
      row[0]: TextEditingController(text: row[1]),
  };
  late final TextEditingController _remarkController =
      TextEditingController(text: ReportData.gearForm.remark);
  late String _status = ReportData.gearForm.status;
  bool _submitting = false;

  static const List<String> _statusOptions = ['常用', '备用', '闲置'];

  @override
  void dispose() {
    for (final c in _rowControllers.values) {
      c.dispose();
    }
    _remarkController.dispose();
    super.dispose();
  }

  // 从相册选图（含权限处理）
  Future<void> _pickPhotos() async {
    final remain = Constants.SELECTED_MAX_COUNT - _pickedPhotos.length;
    if (remain <= 0) {
      Fluttertoast.showToast(msg: '最多上传${Constants.SELECTED_MAX_COUNT}张照片');
      return;
    }
    final files = await MediaPickerUtil.pickImages(context, maxCount: remain);
    if (!mounted || files.isEmpty) return;
    setState(() => _pickedPhotos.addAll(files));
  }

  // 使用状态选择
  Future<void> _pickStatus() async {
    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions
              .map((option) => InkWell(
                    onTap: () => Navigator.of(sheetContext).pop(option),
                    child: Container(
                      height: 52.w,
                      alignment: Alignment.center,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: option == _status
                              ? Constants.INK
                              : Constants.GRAY,
                          fontWeight: option == _status
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
    if (status != null && mounted) setState(() => _status = status);
  }

  // 保存：上传照片 → gear_submit
  Future<void> _save() async {
    final brand = _rowControllers['品牌']?.text.trim() ?? '';
    final model = _rowControllers['型号']?.text.trim() ?? '';
    if (brand.isEmpty) {
      Fluttertoast.showToast(msg: '请填写品牌');
      return;
    }
    if (model.isEmpty) {
      Fluttertoast.showToast(msg: '请填写型号');
      return;
    }
    setState(() => _submitting = true);
    try {
      final imageUrls = <String>[];
      for (final photo in _pickedPhotos) {
        final uploadResult = await Api().uploadAsset(photo, 'upload_asset');
        if (uploadResult['success'] && uploadResult['data'] != null) {
          imageUrls.add(uploadResult['data']['url'] ?? '');
        }
      }
      final result = await Api().post('gear_submit', data: {
        'category': 'rod',
        'brand': brand,
        'model': model,
        'specs': {
          for (final entry in _rowControllers.entries)
            if (entry.key != '品牌' && entry.key != '型号')
              entry.key: entry.value.text.trim(),
        },
        'remark': _remarkController.text.trim(),
        'status': _status,
        'images': imageUrls,
      });
      if (!mounted) return;
      if (result['success']) {
        Fluttertoast.showToast(msg: result['status']?['message'] ?? '装备已入库');
        Navigator.of(context).pop();
      } else {
        setState(() => _submitting = false);
        Fluttertoast.showToast(msg: result['status']?['message'] ?? '保存失败');
      }
    } catch (e) {
      LogUtil.e('装备提交失败: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gear = ReportData.gearForm;
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
          '添加装备',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Constants.INK,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // 照片 + 上传卡片（mock 示例图 + 本地真实选图）
          Row(
            children: [
              for (final url in gear.photos) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: NetImage(
                    url: url,
                    width: 104.w,
                    height: 104.w,
                    fit: BoxFit.cover,
                    borderRadius: 12.r,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              for (var i = 0; i < _pickedPhotos.length; i++) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(_pickedPhotos[i].path),
                    width: 104.w,
                    height: 104.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    height: 104.w,
                    decoration: BoxDecoration(
                      color: Constants.INPUT_BG,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(RemixIcons.add_circle_line, size: 20.w, color: Constants.INK),
                        SizedBox(height: 6.w),
                        Text(
                          '上传照片',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Constants.INK,
                          ),
                        ),
                        SizedBox(height: 2.w),
                        Text(
                          '（支持多张）',
                          style: TextStyle(fontSize: 9.sp, color: Constants.GRAY_LIGHT),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),
          // 表单行
          for (final row in ReportData.gearForm.rows) ...[
            SizedBox(
              height: 52.w,
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        row[0],
                        style: TextStyle(fontSize: 15.sp, color: Constants.INK),
                      ),
                      if (row[0] == '品牌' || row[0] == '型号') ...[
                        SizedBox(width: 2.w),
                        Text(
                          '*',
                          style: TextStyle(
                              fontSize: 15.sp, color: Constants.ERROR_COLOR),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _rowControllers[row[0]],
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Constants.INK,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Constants.BORDER),
          ],
          // 备注
          SizedBox(height: 16.w),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.w),
                child: Text(
                  '备注',
                  style: TextStyle(fontSize: 15.sp, color: Constants.INK),
                ),
              ),
              SizedBox(width: 36.w),
              Expanded(
                child: TextFormField(
                  controller: _remarkController,
                  minLines: 2,
                  maxLines: 4,
                  style: TextStyle(fontSize: 14.sp, color: Constants.INK, height: 1.7),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          Container(height: 1, color: Constants.BORDER),
          SizedBox(height: 4.w),
          // 使用状态
          GestureDetector(
            onTap: _pickStatus,
            child: SizedBox(
              height: 52.w,
              child: Row(
                children: [
                  Text(
                    '使用状态',
                    style: TextStyle(fontSize: 15.sp, color: Constants.INK),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4EBE6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF21582F),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(RemixIcons.arrow_right_s_line, size: 18.w, color: Constants.GRAY_LIGHT),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.w),
        ],
        ),
      ),
      // 保存：固定底部
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 12.w),
          child: InkButton(
            text: _submitting ? '保存中…' : '保 存',
            height: 48,
            onPressed: _submitting ? null : _save,
          ),
        ),
      ),
    );
  }
}
