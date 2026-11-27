import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/pages/upload/ai_fish_result.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 3.2.2 AI 识鱼 - 识别中（背景与贴纸均展示用户实拍图）
class AiFishRecognizingPage extends StatefulWidget {
  // 用户拍摄/选择的图片本地路径
  final String imagePath;

  const AiFishRecognizingPage({super.key, required this.imagePath});

  @override
  State<AiFishRecognizingPage> createState() => _AiFishRecognizingPageState();
}

class _AiFishRecognizingPageState extends State<AiFishRecognizingPage> {
  @override
  void initState() {
    super.initState();
    // 上传实拍图提交识别任务，最短展示 2 秒识别动效
    _recognize();
  }

  Future<void> _recognize() async {
    final sw = Stopwatch()..start();
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      // POST /ai/recognize：JSON body，图片 base64
      final result = await Api().post('ai_recognize', data: {
        'image_base64': base64Encode(bytes),
      });
      if (!mounted) return;
      // 保证识别动效至少展示 2 秒，避免一闪而过
      final remain = const Duration(seconds: 2) - sw.elapsed;
      if (remain > Duration.zero) await Future.delayed(remain);
      if (!mounted) return;

      if (result['success'] == true && result['data']?['recognition'] != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AiFishResultPage(
              recognition: Map<String, dynamic>.from(
                result['data']['recognition'],
              ),
            ),
          ),
        );
      } else {
        final error = result['error'];
        Fluttertoast.showToast(
            msg: error is Map ? error['message'] ?? '识别失败' : '识别失败');
        Navigator.of(context).pop();
      }
    } catch (e) {
      LogUtil.e('AI识鱼失败: $e');
      if (!mounted) return;
      Fluttertoast.showToast(msg: '$e'.replaceAll('Exception: ', ''));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF1B2522),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 模糊背景：用户实拍图
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const NetImagePlaceholder(),
              ),
            ),
            Container(color: Colors.black.withValues(alpha: 0.35)),
            SafeArea(
              child: Stack(
                children: [
                  // 关闭
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.w),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            RemixIcons.close_line,
                            size: 20.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 识别主体
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 抠图白边贴纸效果：用户实拍图
                        Container(
                          width: 250.w,
                          height: 320.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Colors.white, width: 8.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.55),
                                blurRadius: 36.w,
                                spreadRadius: 2.w,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const NetImagePlaceholder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 48.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              RemixIcons.bear_smile_fill,
                              size: 30.w,
                              color: Constants.LIME,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              '识别分析中..',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
