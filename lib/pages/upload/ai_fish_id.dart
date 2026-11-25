import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/pages/upload/ai_fish_result.dart';
import 'package:FishMark/utils/media_picker_util.dart';

/// @desc AI识鱼页：拍照/相册 → 百炼识别 → 结果页
class AiFishIdPage extends StatefulWidget {
  const AiFishIdPage({super.key});

  @override
  State<AiFishIdPage> createState() => _AiFishIdPageState();
}

class _AiFishIdPageState extends State<AiFishIdPage> {
  Uint8List? _imageBytes;
  bool _recognizing = false;

  // 拍照识别（含相机权限处理）
  Future<void> _takePhoto() async {
    final file = await MediaPickerUtil.takePhoto(context);
    if (!mounted || file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
    await _recognize(bytes, filename: file.name);
  }

  // 相册识别（含相册权限处理）
  Future<void> _pickImage() async {
    final file = await MediaPickerUtil.pickSingleImage(context);
    if (!mounted || file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
    await _recognize(bytes, filename: file.name);
  }

  // 调用AI识鱼接口
  Future<void> _recognize(Uint8List bytes, {String filename = 'fish.jpg'}) async {
    setState(() => _recognizing = true);
    try {
      // 上传图片并提交识别任务
      final result = await Api().uploadBytes(
        bytes,
        'ai_fish_recognize',
        filename: filename,
      );
      if (!mounted) return;
      if (result['success']) {
        final taskId = result['data']?['task_id'];
        // 直接返回结果 or 跳转结果页轮询
        if (result['data']?['fish'] != null) {
          _goResult(taskId, Map<String, dynamic>.from(result['data']));
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AiFishResultPage(taskId: taskId?.toString() ?? ''),
            ),
          );
        }
      } else {
        setState(() => _recognizing = false);
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('AI识鱼失败: $e');
      if (!mounted) return;
      setState(() => _recognizing = false);
      Fluttertoast.showToast(msg: '识别服务异常，请稍后重试');
    }
  }

  // 进入结果页
  void _goResult(String? taskId, Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() => _recognizing = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiFishResultPage(
          taskId: taskId?.toString() ?? '',
          initialData: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('AI识鱼', style: TextStyle(fontSize: 34.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            // 预览区
            Container(
              width: double.infinity,
              height: 480.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.w),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 120.w, color: Constants.PRIMARY_COLOR),
                        SizedBox(height: 24.w),
                        Text(
                          '拍一拍，就知道是什么鱼',
                          style: TextStyle(
                            fontSize: 30.sp,
                            color: Constants.TEXT_SECONDARY_COLOR,
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 32.w),
            // 识别中
            if (_recognizing)
              Container(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child: const CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '正在识别鱼种…',
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 32.w),
            // 操作按钮
            _buildAction(),
            SizedBox(height: 48.w),
            // 说明
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '识别小技巧',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.w),
                  Text(
                    '· 鱼体完整入镜，侧面对镜头\n'
                    '· 光线充足，避免强反光\n'
                    '· 背景干净，识别更准确',
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Constants.TEXT_SECONDARY_COLOR,
                      height: 1.6,
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

  // 操作按钮区
  Widget _buildAction() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _recognizing ? null : _takePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.PRIMARY_COLOR,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 96.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(48.w),
              ),
            ),
            icon: Icon(Icons.camera_alt_outlined, size: 36.w),
            label: Text('拍照识别', style: TextStyle(fontSize: 30.sp)),
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _recognizing ? null : _pickImage,
            style: OutlinedButton.styleFrom(
              foregroundColor: Constants.PRIMARY_COLOR,
              minimumSize: Size(double.infinity, 96.w),
              side: BorderSide(color: Constants.PRIMARY_COLOR),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(48.w),
              ),
            ),
            icon: Icon(Icons.photo_library_outlined, size: 36.w),
            label: Text('相册选择', style: TextStyle(fontSize: 30.sp)),
          ),
        ),
      ],
    );
  }
}
