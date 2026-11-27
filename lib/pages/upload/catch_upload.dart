import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/catch_record.dart';
import 'package:FishMark/pages/report/report_preview.dart';
import 'package:FishMark/utils/media_picker_util.dart';
import 'package:FishMark/widgets/round_button.dart';

/// @desc 鱼获记录上传页
class CatchUploadPage extends StatefulWidget {
  // AI识鱼结果带入的鱼种名（预填）
  final String initialFishName;

  const CatchUploadPage({super.key, this.initialFishName = ''});

  @override
  State<CatchUploadPage> createState() => _CatchUploadPageState();
}

class _CatchUploadPageState extends State<CatchUploadPage> {
  final TextEditingController _fishNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _weatherController = TextEditingController();

  final List<XFile> _images = [];
  // 提交中
  bool _isSubmiting = false;
  // 上钩时间
  DateTime _caughtAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialFishName.isNotEmpty) {
      _fishNameController.text = widget.initialFishName;
    }
  }

  @override
  void dispose() {
    _fishNameController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    _weatherController.dispose();
    super.dispose();
  }

  // 拍照（含相机权限处理）
  Future<void> _takePhoto() async {
    final file = await MediaPickerUtil.takePhoto(context);
    if (!mounted || file == null) return;
    if (_images.length < Constants.SELECTED_MAX_COUNT) {
      setState(() => _images.add(file));
    }
  }

  // 相册选择（含相册权限处理）
  Future<void> _pickImages() async {
    final remain = Constants.SELECTED_MAX_COUNT - _images.length;
    if (remain <= 0) return;
    final files = await MediaPickerUtil.pickImages(context, maxCount: remain);
    if (!mounted || files.isEmpty) return;
    setState(() => _images.addAll(files));
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
      // TODO: 图片上传端点待服务端上线后接入，届时将本地照片上传换取 asset_ids
      final result = await Api().post('catches', data: {
        'fish_species': _fishNameController.text.trim(),
        'weight': double.tryParse(_weightController.text.trim()),
        'length': double.tryParse(_lengthController.text.trim()),
        'note': _notesController.text.trim(),
        'weather': _weatherController.text.trim(),
        'catch_date':
            '${_caughtAt.year}-${_caughtAt.month.toString().padLeft(2, '0')}-${_caughtAt.day.toString().padLeft(2, '0')}',
        'asset_ids': <int>[],
      });

      if (!mounted) return;
      setState(() => _isSubmiting = false);
      if (result['success'] == true) {
        final data = Map<String, dynamic>.from(result['data'] ?? {});
        final record = CatchRecord.fromApi(
          Map<String, dynamic>.from(data['catch'] ?? data),
        );
        // 生成战报预览
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ReportPreviewPage(record: record)),
        );
      } else {
        final error = result['error'];
        Fluttertoast.showToast(
            msg: error is Map ? error['message'] ?? '提交失败' : '提交失败');
      }
    } catch (e) {
      LogUtil.e('鱼获提交失败: $e');
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      Fluttertoast.showToast(msg: '$e'.replaceAll('Exception: ', ''));
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

