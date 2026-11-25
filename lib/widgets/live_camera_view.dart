import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// @desc 应用内实时相机取景（camera 插件）
///
/// 真机：实时预览，闪光灯（torch 常亮）/ 倍率（setZoomLevel）真实生效，
/// 页面通过 onReady 拿到 CameraController 直接 takePicture 完成拍照。
/// 初始化失败（模拟器无相机等）回调 onUnavailable，由页面回退 mock 取景。
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({
    super.key,
    required this.torchOn,
    required this.zoomLevel,
    this.onReady,
    this.onUnavailable,
  });

  /// 闪光灯常亮开关（预览补光 + 拍照闪光）
  final bool torchOn;

  /// 变焦倍率（如 1.0 / 2.0 / 5.0）
  final double zoomLevel;

  /// 相机就绪后回调，页面持有 controller 用于拍照
  final ValueChanged<CameraController>? onReady;

  /// 初始化失败（无相机 / 无权限等）
  final VoidCallback? onUnavailable;

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didUpdateWidget(covariant LiveCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.torchOn != widget.torchOn ||
        oldWidget.zoomLevel != widget.zoomLevel) {
      _applySettings();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('no camera available');
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _ready = true;
      });
      widget.onReady?.call(controller);
      _applySettings();
    } catch (e) {
      debugPrint('实时相机初始化失败，回退 mock 取景: $e');
      if (mounted) setState(() => _failed = true);
      widget.onUnavailable?.call();
    }
  }

  /// 应用闪光灯 / 倍率；个别设备不支持某倍率时静默失败（仅 debug 日志）
  Future<void> _applySettings() async {
    final controller = _controller;
    if (controller == null || !_ready) return;
    try {
      await controller.setFlashMode(
        widget.torchOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('闪光灯设置失败: $e');
    }
    try {
      await controller.setZoomLevel(widget.zoomLevel);
    } catch (e) {
      debugPrint('倍率设置失败: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 退到后台释放相机，回到前台重新初始化并恢复闪光灯/倍率
    final controller = _controller;
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
      _controller = null;
      if (mounted) setState(() => _ready = false);
    } else if (state == AppLifecycleState.resumed &&
        controller == null &&
        !_failed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_ready && controller != null && controller.value.isInitialized) {
      return CameraPreview(controller);
    }
    // 初始化中：黑底等待；失败时由页面回退 mock 取景
    return const SizedBox.expand();
  }
}
