import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/utils/location_permission_util.dart';

/// @desc 统一图片选取入口（image_picker + 权限处理）
///
/// 权限策略（结合应用内用途告知，参考业界合规做法）：
/// - 首次申请：iOS 直接弹系统权限框；Android 先弹应用内「权限使用说明」告知用途，
///   用户同意后再弹系统框（国内上架合规要求）。
/// - 已授权 / iOS 受限(limited) / Android 14+ 部分授权(provisional)：直接继续。
/// - 相机：被拒绝过一次后再次点击，先弹说明弹窗引导去设置（不反复调用已失效的
///   request，避免「点了没反应」）。
/// - 永久拒绝（permanentlyDenied）：直接弹「去设置」引导弹窗。
class MediaPickerUtil {
  static final ImagePicker _picker = ImagePicker();

  // 进程内记录：用户是否曾拒绝过该权限（拒绝过一次后 request 不再弹系统框，
  // 返回值恒为 denied，需要引导去设置）
  static bool _cameraDeniedBefore = false;
  static bool _galleryDeniedBefore = false;

  // ===== 对外 API =====

  /// 申请相机权限（应用内实时取景 LiveCameraView 使用）。
  /// 返回 true 才可初始化相机；拒绝时按策略弹说明/引导去设置。
  static Future<bool> ensureCameraPermission(BuildContext context) {
    return _ensurePermission(
      context,
      permission: Permission.camera,
      deniedBefore: _cameraDeniedBefore,
      markDenied: (v) => _cameraDeniedBefore = v,
      titleZh: '相机权限未开启',
      titleEn: 'Camera permission is off',
      descZh: '拍照记录鱼获需要使用相机，请在设置中允许「路记」访问相机。',
      descEn:
          'We need camera access to capture your catch. Please allow camera access in Settings.',
    );
  }

  /// 拍照（单张）。取消返回 null，失败/无权限返回 null。
  /// [mockSeed]：传入后，无相机环境（模拟器）抛异常时自动用占位图模拟拍摄，
  /// 保证流程可直接走通；真机取消不触发（取消不抛异常）。
  static Future<XFile?> takePhoto(
    BuildContext context, {
    String? mockSeed,
  }) async {
    if (!await ensureCameraPermission(context)) {
      return null;
    }
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('拍照失败: $e');
      // 无相机环境（模拟器）抛异常：有 mockSeed 时模拟拍摄走通流程
      if (mockSeed != null) {
        final mock = await mockCapture(seed: mockSeed);
        if (mock != null && context.mounted) {
          Fluttertoast.showToast(
            msg: Global.t('当前设备无相机，已模拟拍摄', 'No camera here. Simulated a capture.'),
          );
        }
        return mock;
      }
      return null;
    }
  }

  /// 相册多选，最多 [maxCount] 张（默认 9）。
  static Future<List<XFile>> pickImages(
    BuildContext context, {
    int maxCount = Constants.SELECTED_MAX_COUNT,
  }) async {
    if (!await _ensurePermission(
      context,
      permission: Permission.photos,
      deniedBefore: _galleryDeniedBefore,
      markDenied: (v) => _galleryDeniedBefore = v,
      titleZh: '相册权限未开启',
      titleEn: 'Photo library permission is off',
      descZh: '选择鱼获照片需要访问相册，请在设置中允许「路记」访问照片。',
      descEn:
          'We need photo library access to pick your catch photos. Please allow it in Settings.',
    )) {
      return const [];
    }
    try {
      // iOS PHPicker 自带选片器，limit 不生效但可多选；Android 端通过数量兜底裁剪
      final files = await _picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (files.length > maxCount) {
        return files.take(maxCount).toList();
      }
      return files;
    } catch (e) {
      debugPrint('相册选择失败: $e');
      return const [];
    }
  }

  /// 相册单选（头像等场景）。
  static Future<XFile?> pickSingleImage(BuildContext context) async {
    if (!await _ensurePermission(
      context,
      permission: Permission.photos,
      deniedBefore: _galleryDeniedBefore,
      markDenied: (v) => _galleryDeniedBefore = v,
      titleZh: '相册权限未开启',
      titleEn: 'Photo library permission is off',
      descZh: '选择照片需要访问相册，请在设置中允许「路记」访问照片。',
      descEn:
          'We need photo library access to pick photos. Please allow it in Settings.',
    )) {
      return null;
    }
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('相册选择失败: $e');
      return null;
    }
  }

  // ===== 权限核心逻辑 =====

  /// 确保权限可用；返回 true 才继续调起选图。
  static Future<bool> _ensurePermission(
    BuildContext context, {
    required Permission permission,
    required bool deniedBefore,
    required ValueChanged<bool> markDenied,
    required String titleZh,
    required String titleEn,
    required String descZh,
    required String descEn,
  }) async {
    final status = await permission.status;
    if (!context.mounted) return false;

    // 已授权 / iOS 受限(limited) / Android 14+ 部分授权(provisional) 都可继续
    if (_isUsable(status)) {
      markDenied(false);
      return true;
    }

    // 永久拒绝：直接引导设置
    if (status.isPermanentlyDenied || status.isRestricted) {
      await showPermissionSettingsDialog(
        context,
        title: titleZh,
        desc: descZh,
      );
      return false;
    }

    // 曾被拒绝过：request 不再弹系统框（恒返回 denied），
    // 直接弹说明弹窗 → 用户确认后跳设置，避免「点了没反应」
    if (deniedBefore) {
      await showPermissionSettingsDialog(
        context,
        title: titleZh,
        desc: descZh,
      );
      return false;
    }

    // 首次申请：Android 先展示应用内用途告知（合规），同意后再弹系统框；
    // iOS 直接弹系统权限框（系统框本身已含用途描述）
    if (Platform.isAndroid) {
      final confirmed = await showStyledPermissionDialog(
        context,
        title: titleZh,
        desc: descZh,
        cancelText: Global.t('拒绝', 'Deny'),
        confirmText: Global.t('同意', 'Allow'),
      );
      if (!confirmed || !context.mounted) return false;
    }

    // 弹系统权限框
    final result = await permission.request();
    if (_isUsable(result)) {
      return true;
    }
    // 用户这次点了拒绝：记录状态，下次点击走设置引导
    markDenied(true);
    if (!context.mounted) return false;
    if (result.isPermanentlyDenied) {
      await showPermissionSettingsDialog(
        context,
        title: titleZh,
        desc: descZh,
      );
    } else {
      Fluttertoast.showToast(
        msg: Global.t('您已拒绝该权限，可到设置中开启', 'Permission denied. Enable it in Settings.'),
      );
    }
    return false;
  }

  /// 已授权 / 受限 / 部分授权均视为可用（iOS 和 Android 14+ 选定照片不阻断流程）
  static bool _isUsable(PermissionStatus status) =>
      status.isGranted || status.isLimited || status.isProvisional;

  /// 模拟拍摄：无相机环境（模拟器）用占位图生成临时文件，直接走通拍照流程
  static Future<XFile?> mockCapture({required String seed}) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(
        Uri.parse('https://picsum.photos/seed/$seed/1170/1568'),
      );
      final response = await request.close();
      final builder = BytesBuilder();
      await for (final chunk in response) {
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();
      if (bytes.isEmpty) return null;
      final file = File('${Directory.systemTemp.path}/mock_$seed.jpg');
      await file.writeAsBytes(bytes, flush: true);
      return XFile(file.path);
    } catch (e) {
      debugPrint('模拟拍摄失败: $e');
      return null;
    } finally {
      client.close();
    }
  }
}

