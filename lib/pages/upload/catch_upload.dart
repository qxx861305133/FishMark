import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/http/api.dart';
import 'package:luji_app/models/catch_record.dart';
import 'package:luji_app/pages/report/report_preview.dart';
import 'package:luji_app/widgets/round_button.dart';

/// @desc 鱼获记录上传页
class CatchUploadPage extends StatefulWidget {
  const CatchUploadPage({super.key});

  @override
  State<CatchUploadPage> createState() => _CatchUploadPageState();
}

class _CatchUploadPageState extends State<CatchUploadPage> {
  final TextEditingController _fishNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _weatherController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  // 提交中
  bool _isSubmiting = false;
  // 上钩时间
  DateTime _caughtAt = DateTime.now();

  @override
  void dispose() {
    _fishNameController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    _weatherController.dispose();
    super.dispose();
  }

  // 拍照
  Future<void> _takePhoto() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null && _images.length < Constants.SELECTED_MAX_COUNT) {
        setState(() => _images.add(file));
      }
    } catch (e) {
      LogUtil.e('拍照失败: $e');
    }
  }

  // 相册选择
  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage();
      if (files.isNotEmpty) {
        setState(() {
          final remain = Constants.SELECTED_MAX_COUNT - _images.length;
          _images.addAll(files.take(remain));
        });
      }
    } catch (e) {
      LogUtil.e('相册选择失败: $e');
    }
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  // 选择时间
  Future<void> _pickCaughtAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _caughtAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_caughtAt),
    );
    if (time == null) return;
    setState(() {
      _caughtAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // 提交
  Future<void> _handleSubmit() async {
    if (_fishNameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '请填写鱼种名称');
      return;
    }

    setState(() => _isSubmiting = true);
    try {
      // 上传图片
      final imageUrls = <String>[];
      for (final image in _images) {
        final uploadResult = await Api().uploadAsset(image, 'upload_asset');
        if (uploadResult['success'] && uploadResult['data'] != null) {
          imageUrls.add(uploadResult['data']['url'] ?? '');
        }
      }

      // 提交鱼获
      final result = await Api().post('catch_submit', data: {
        'fish_name': _fishNameController.text.trim(),
        'weight': double.tryParse(_weightController.text.trim()),
        'length': double.tryParse(_lengthController.text.trim()),
        'notes': _notesController.text.trim(),
        'weather': _weatherController.text.trim(),
        'caught_at': _caughtAt.toIso8601String(),
        'images': imageUrls,
      });

      if (!mounted) return;
      setState(() => _isSubmiting = false);
      if (result['success']) {
        final record = CatchRecord.fromJson(
          Map<String, dynamic>.from(result['data'] ?? {}),
        );
        // 生成战报预览
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ReportPreviewPage(record: record)),
        );
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('鱼获提交失败: $e');
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('记录鱼获', style: TextStyle(fontSize: 34.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32.w, 16.w, 32.w, 160.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('鱼获照片', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildImageGrid(),
            SizedBox(height: 40.w),
            Text('鱼种', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_fishNameController, '如：翘嘴、鲈鱼、鳜鱼'),
            SizedBox(height: 32.w),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('重量（kg）', style: _labelStyle()),
                      SizedBox(height: 16.w),
                      _buildField(_weightController, '选填', isNumber: true),
                    ],
                  ),
                ),
                SizedBox(width: 32.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('长度（cm）', style: _labelStyle()),
                      SizedBox(height: 16.w),
                      _buildField(_lengthController, '选填', isNumber: true),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.w),
            Text('天气', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_weatherController, '如：晴 / 多云 / 小雨'),
            SizedBox(height: 32.w),
            Text('上钩时间', style: _labelStyle()),
            SizedBox(height: 16.w),
            GestureDetector(
              onTap: _pickCaughtAt,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: _fieldDecoration(),
                child: Row(
                  children: [
                    Text(
                      _formatDateTime(_caughtAt),
                      style: TextStyle(fontSize: 28.sp),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time,
                        size: 32.w, color: Constants.TEXT_LIGHT_COLOR),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.w),
            Text('心得笔记', style: _labelStyle()),
            SizedBox(height: 16.w),
            TextField(
              controller: _notesController,
              maxLines: 4,
              maxLength: 500,
              style: TextStyle(fontSize: 28.sp),
              decoration: InputDecoration(
                counterText: '',
                hintText: '用什么饵？什么标点？分享一下钓法心得…',
                hintStyle: TextStyle(
                  fontSize: 26.sp,
                  color: Constants.TEXT_LIGHT_COLOR,
                ),
                filled: true,
                fillColor: Constants.BG_COLOR,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 64.w),
            RoundButton(
              text: '提交并生成战报',
              loading: _isSubmiting,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  // 图片九宫格
  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16.w,
        crossAxisSpacing: 16.w,
      ),
      itemCount: _images.length + 1,
      itemBuilder: (context, index) {
        if (index == _images.length) {
          // 添加按钮
          return GestureDetector(
            onTap: _images.length >= Constants.SELECTED_MAX_COUNT
                ? null
                : () => showModalBottomSheet(
                      context: context,
                      builder: (_) => _buildImageSourceSheet(),
                    ),
            child: Container(
              decoration: BoxDecoration(
                color: Constants.BG_COLOR,
                borderRadius: BorderRadius.circular(16.w),
              ),
              child: Icon(Icons.camera_alt_outlined,
                  size: 56.w, color: Constants.TEXT_LIGHT_COLOR),
            ),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.w),
              child: Image.file(
                File(_images[index].path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 8.w,
              top: 8.w,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close,
                      size: 24.w, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 图片来源选择
  Widget _buildImageSourceSheet() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('拍照'),
            onTap: () {
              Navigator.of(context).pop();
              _takePhoto();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImages();
            },
          ),
        ],
      ),
    );
  }

  // 输入框
  Widget _buildField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: TextStyle(fontSize: 28.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 26.sp,
          color: Constants.TEXT_LIGHT_COLOR,
        ),
        filled: true,
        fillColor: Constants.BG_COLOR,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 字段装饰
  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Constants.BG_COLOR,
      borderRadius: BorderRadius.circular(16.w),
    );
  }

  // 标签样式
  TextStyle _labelStyle() {
    return TextStyle(
      fontSize: 28.sp,
      fontWeight: FontWeight.w600,
      color: Constants.TEXT_DEFAULT_COLOR,
    );
  }

  // 时间格式化
  String _formatDateTime(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd $hh:$mi';
  }
}

