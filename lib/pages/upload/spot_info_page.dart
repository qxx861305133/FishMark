import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/mock/report_data.dart';
import 'package:FishMark/utils/media_picker_util.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 3.4.2 填写钓点信息（照片真实选取，提交走 spot_submit）
class SpotInfoPage extends StatefulWidget {
  // 上一页选点带入：地点名 / 地址 / 坐标
  final String initialName;
  final String initialAddress;
  final LatLng? latLng;

  const SpotInfoPage({
    super.key,
    this.initialName = '',
    this.initialAddress = '',
    this.latLng,
  });

  @override
  State<SpotInfoPage> createState() => _SpotInfoPageState();
}

class _SpotInfoPageState extends State<SpotInfoPage> {
  late String _waterType = ReportData.spotInfo.selectedType;
  final List<SpotFishItem> _fishes = List.from(ReportData.spotInfo.fishes);
  // 本地选取的钓点照片（真实选图，提交时上传）
  final List<XFile> _photos = [];
  bool _submitting = false;

  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  // 地址：上一页选点带入，可编辑修改后参与保存
  late final TextEditingController _addrController =
      TextEditingController(text: widget.initialAddress);
  late final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addrController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // 选图（含相册权限处理，最多 9 张）
  Future<void> _pickPhotos() async {
    final remain = Constants.SELECTED_MAX_COUNT - _photos.length;
    if (remain <= 0) {
      Fluttertoast.showToast(msg: '最多上传${Constants.SELECTED_MAX_COUNT}张照片');
      return;
    }
    final files = await MediaPickerUtil.pickImages(context, maxCount: remain);
    if (!mounted || files.isEmpty) return;
    setState(() => _photos.addAll(files));
  }

  // 删除照片
  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  // 添加常见鱼种：简单输入对话框
  Future<void> _addFish() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('添加常见鱼种',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '如：翘嘴、马口'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('添加', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    setState(() {
      _fishes.add(SpotFishItem(name: name, image: ''));
    });
  }

  // 提交钓点：提交钓点信息（照片上传端点待服务端上线后接入）
  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: '请填写钓点名称');
      return;
    }
    if (widget.latLng == null) {
      Fluttertoast.showToast(msg: '请先在地图上选择钓点位置');
      return;
    }
    setState(() => _submitting = true);
    try {
      // TODO: 照片上传端点待服务端上线后接入，届时上传照片换取 asset_ids
      final result = await Api().post('spots', data: {
        'name': name,
        'address': _addrController.text.trim(),
        'description': _descController.text.trim(),
        'water_type': _waterType,
        'latitude': widget.latLng!.latitude,
        'longitude': widget.latLng!.longitude,
        'asset_ids': <int>[],
      });
      if (!mounted) return;
      if (result['success'] == true) {
        Fluttertoast.showToast(msg: '钓点已提交审核');
        // 返回到地图选点上一页之上（连退两层回到入口）
        Navigator.of(context)..pop()..pop();
      } else {
        setState(() => _submitting = false);
        final error = result['error'];
        Fluttertoast.showToast(
            msg: error is Map ? error['message'] ?? '提交失败' : '提交失败');
      }
    } catch (e) {
      LogUtil.e('钓点提交失败: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      Fluttertoast.showToast(msg: '$e'.replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '填写钓点信息',
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
          // 照片九宫格（真实选图）+ 上传卡片
          _photoGrid(),
          _divider(),
          // 钓点名称（带入上一页选中地点）
          SizedBox(
            height: 52.w,
            child: Row(
              children: [
                _label('钓点名称', required: true),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Constants.INK,
                    ),
                    decoration: _inputDecoration(),
                  ),
                ),
              ],
            ),
          ),
          // 地址（上一页选点带入，可编辑）
          SizedBox(
            height: 44.w,
            child: Row(
              children: [
                _label('地址'),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _addrController,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Constants.GRAY,
                    ),
                    decoration: _inputDecoration(hint: '请填写钓点地址'),
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          // 水域类型
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('水域类型', required: true),
              SizedBox(height: 12.w),
              Wrap(
                spacing: 10.w,
                children: [
                  for (final type in ReportData.spotInfo.waterTypes)
                    _typeChip(type),
                ],
              ),
            ],
          ),
          _divider(),
          // 常见鱼种
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('常见鱼种'),
              SizedBox(height: 12.w),
              Wrap(
                spacing: 14.w,
                runSpacing: 12.w,
                children: [
                  for (var i = 0; i < _fishes.length; i++) _fishItem(_fishes[i], i),
                  _addFishCard(),
                ],
              ),
            ],
          ),
          _divider(),
          // 钓点描述
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '钓点描述',
                style: TextStyle(fontSize: 13.sp, color: Constants.GRAY_LIGHT),
              ),
              SizedBox(height: 8.w),
              TextFormField(
                controller: _descController,
                minLines: 2,
                maxLines: 4,
                style: TextStyle(fontSize: 15.sp, color: Constants.INK, height: 1.6),
                decoration: _inputDecoration(),
              ),
            ],
          ),
          SizedBox(height: 8.w),
        ],
        ),
      ),
      // 确认上传：固定底部
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 12.w),
          child: InkButton(
            text: _submitting ? '提交中…' : '确认上传',
            height: 48,
            onPressed: _submitting ? null : _submit,
          ),
        ),
      ),
    );
  }

  // 照片九宫格
  Widget _photoGrid() {
    final children = <Widget>[];
    for (var i = 0; i < _photos.length; i++) {
      children.add(_localPhoto(_photos[i], i));
    }
    if (_photos.isEmpty) {
      children.add(_uploadCard());
    } else if (_photos.length < Constants.SELECTED_MAX_COUNT) {
      children.add(_addMoreCard());
    }
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.w,
      children: children,
    );
  }

  // 本地照片缩略图（可删除）
  Widget _localPhoto(XFile file, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(file.path),
            width: 104.w,
            height: 104.w,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6.w,
          right: -6.w,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: const BoxDecoration(
                color: Constants.INK,
                shape: BoxShape.circle,
              ),
              child: Icon(RemixIcons.close_fill, size: 10.w, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // 上传照片卡片
  Widget _uploadCard() {
    return GestureDetector(
      onTap: _pickPhotos,
      child: Container(
        height: 104.w,
        width: 104.w,
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
    );
  }

  // 追加照片小卡
  Widget _addMoreCard() {
    return GestureDetector(
      onTap: _pickPhotos,
      child: Container(
        height: 104.w,
        width: 104.w,
        decoration: BoxDecoration(
          color: Constants.INPUT_BG,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(RemixIcons.add_line, size: 20.w, color: Constants.INK),
      ),
    );
  }

  // 分隔线
  Widget _divider() {
    return Container(
      height: 1,
      color: Constants.BORDER,
      margin: EdgeInsets.symmetric(vertical: 16.w),
    );
  }

  // 字段标签
  Widget _label(String text, {bool required = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: TextStyle(fontSize: 15.sp, color: Constants.INK)),
        if (required) ...[
          SizedBox(width: 2.w),
          Text('*', style: TextStyle(fontSize: 15.sp, color: Constants.ERROR_COLOR)),
        ],
      ],
    );
  }

  // 水域类型 chip
  Widget _typeChip(String type) {
    final selected = type == _waterType;
    return GestureDetector(
      onTap: () => setState(() => _waterType = type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.w),
        decoration: BoxDecoration(
          color: selected ? Constants.LIME : Constants.INPUT_BG,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Constants.INK : Constants.GRAY,
          ),
        ),
      ),
    );
  }

  // 常见鱼种缩略图
  Widget _fishItem(SpotFishItem fish, int index) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: fish.image.isEmpty
                  ? Container(
                      width: 72.w,
                      height: 72.w,
                      color: Constants.INPUT_BG,
                      alignment: Alignment.center,
                      child: Icon(RemixIcons.image_line,
                          size: 22.w, color: Constants.GRAY_LIGHT),
                    )
                  : fish.image.startsWith('http')
                      ? Image.network(
                          fish.image,
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const NetImagePlaceholder(),
                          errorBuilder: (_, _, _) => const NetImagePlaceholder(),
                        )
                      : Image.file(
                          File(fish.image),
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                        ),
            ),
            Positioned(
              top: -6.w,
              right: -6.w,
              child: GestureDetector(
                onTap: () => setState(() => _fishes.removeAt(index)),
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(
                    color: Constants.INK,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(RemixIcons.close_fill, size: 10.w, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.w),
        Text(
          fish.name,
          style: TextStyle(fontSize: 11.sp, color: Constants.INK),
        ),
      ],
    );
  }

  // 添加鱼种卡片
  Widget _addFishCard() {
    return GestureDetector(
      onTap: _addFish,
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: Constants.INPUT_BG,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(RemixIcons.add_circle_line, size: 20.w, color: Constants.INK),
          ),
          SizedBox(height: 6.w),
          Text('添加', style: TextStyle(fontSize: 11.sp, color: Constants.INK)),
        ],
      ),
    );
  }
}

/// 无边框输入装饰
InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    isCollapsed: true,
    border: InputBorder.none,
    hintText: hint,
    hintStyle: TextStyle(color: Constants.GRAY_LIGHT, fontSize: 14.sp),
  );
}
