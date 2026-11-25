import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/pages/report/catch_record_page.dart';
import 'package:FishMark/pages/upload/viewfinder.dart';
import 'package:FishMark/utils/media_picker_util.dart';
import 'package:FishMark/widgets/live_camera_view.dart';

/// @desc 3.3.1 记录渔获 - 拍照
class CatchCapturePage extends StatefulWidget {
  const CatchCapturePage({super.key});

  @override
  State<CatchCapturePage> createState() => _CatchCapturePageState();
}

class _CatchCapturePageState extends State<CatchCapturePage> {
  // 当前变焦档位
  int _zoomIndex = 1;
  static const List<String> _zooms = ['0.5', '1x', '2x', '5x'];
  // 档位对应的实际变焦倍率（传给相机 setZoomLevel）
  static const List<double> _zoomValues = [0.5, 1.0, 2.0, 5.0];
  // 闪光灯常亮开关（真机 torch 生效）
  bool _flashOn = false;
  // 实时相机：权限通过后启用，初始化失败（模拟器无相机）回退 mock 取景
  bool _useLiveCamera = false;
  CameraController? _camera;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  // 进入页面先申请相机权限，通过后启用实时取景（闪光灯/倍率真实生效）
  Future<void> _requestCameraPermission() async {
    final ok = await MediaPickerUtil.ensureCameraPermission(context);
    if (!mounted || !ok) return; // 权限未通过：保持 mock 取景，快门时再引导
    setState(() => _useLiveCamera = true);
  }

  // 快门：实时相机可用时直接拍照，否则调起系统相机（无相机环境模拟拍摄）
  Future<void> _shoot() async {
    XFile? file;
    final camera = _camera;
    if (camera != null && camera.value.isInitialized) {
      try {
        file = await camera.takePicture();
      } catch (e) {
        debugPrint('实时拍照失败: $e');
      }
      if (!mounted) return; // 拍照期间页面已退出
    }
    file ??= await MediaPickerUtil.takePhoto(
      context,
      mockSeed: 'luji-catch',
    );
    if (!mounted || file == null) return; // 取消拍摄 / 无权限
    final imagePath = file.path;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatchRecordPage(imagePath: imagePath),
      ),
    );
  }

  // 相册：单张选择后进入记录页
  Future<void> _pickFromAlbum() async {
    final files = await MediaPickerUtil.pickImages(context, maxCount: 1);
    if (!mounted || files.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatchRecordPage(imagePath: files.first.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // 相机取景占位底色
        backgroundColor: const Color(0xFF3C3C3C),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 相机取景：真机实时预览；模拟器/初始化失败回退灰色底
            if (_useLiveCamera)
              LiveCameraView(
                torchOn: _flashOn,
                zoomLevel: _zoomValues[_zoomIndex],
                onReady: (controller) => _camera = controller,
                onUnavailable: () {
                  if (mounted) setState(() => _useLiveCamera = false);
                },
              ),
            SafeArea(
              child: Column(
                children: [
                  // 顶部：关闭 / 闪光灯
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleAction(
                          icon: RemixIcons.close_line,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        _CircleAction(
                          icon: _flashOn
                              ? RemixIcons.flashlight_fill
                              : RemixIcons.flashlight_line,
                          iconColor:
                              _flashOn ? const Color(0xFFFFD60A) : Colors.white,
                          onTap: () => setState(() => _flashOn = !_flashOn),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 变焦档位
                  _ZoomPill(
                    zooms: _zooms,
                    selectedIndex: _zoomIndex,
                    onSelected: (i) => setState(() => _zoomIndex = i),
                  ),
                  SizedBox(height: 24.w),
                  // 底部：相册 + 快门
                  SizedBox(
                    height: 84.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 28.w,
                          bottom: 6.w,
                          child: GestureDetector(
                            onTap: _pickFromAlbum,
                            child: Icon(
                              RemixIcons.image_line,
                              size: 26.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _shoot,
                          child: Container(
                            width: 76.w,
                            height: 76.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 66.w,
                              height: 66.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFDDDDDD),
                                  width: 1.w,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.w),
                ],
              ),
            ),
            // 取景框四角
            const Align(
              alignment: Alignment(0, -0.42),
              child: ViewfinderCorners(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 相机顶部圆形操作按钮
class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CircleAction({
    required this.icon,
    this.iconColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.w, color: iconColor),
      ),
    );
  }
}

/// 变焦档位胶囊
class _ZoomPill extends StatelessWidget {
  final List<String> zooms;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ZoomPill({
    required this.zooms,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < zooms.length; i++)
            GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                width: 32.w,
                height: 32.w,
                margin: i == 0 ? EdgeInsets.zero : EdgeInsets.only(left: 4.w),
                decoration: BoxDecoration(
                  color: i == selectedIndex ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  zooms[i],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                        i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                    color: i == selectedIndex ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
