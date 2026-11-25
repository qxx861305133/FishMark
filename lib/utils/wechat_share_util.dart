import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluwx/fluwx.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';

/// @desc 微信分享（fluwx）：底部弹出「微信好友 / 朋友圈」选择面板
///
/// 模拟说明：当前使用占位 AppID，真机未安装微信时走「模拟分享」提示；
/// 接入正式环境只需替换 Constants.WX_APP_ID / WX_UNIVERSAL_LINK。
class WechatShareUtil {
  static final Fluwx _fluwx = Fluwx();
  static bool _registered = false;

  /// 注册 WXApi（幂等，App 启动时调用一次即可）
  static Future<void> ensureRegistered() async {
    if (_registered) return;
    try {
      _registered = await _fluwx.registerApi(
        appId: Constants.WX_APP_ID,
        universalLink: Constants.WX_UNIVERSAL_LINK,
      );
    } catch (e) {
      debugPrint('fluwx 注册失败: $e');
    }
  }

  /// 弹出分享面板
  /// [title]/[desc]：分享文案；[link]：网页链接（图片为空时用网页卡片）
  /// [imageBytes]：图片二进制（有值时优先分享图片，如战报卡）
  static void show(
    BuildContext context, {
    String title = '路记',
    String desc = '每一尾皆是勋章',
    String link = 'https://www.luji.cn',
    Uint8List? imageBytes,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _ShareSheet(
        title: title,
        desc: desc,
        link: link,
        imageBytes: imageBytes,
      ),
    );
  }

  /// 分享到指定场景
  static Future<void> share(
    BuildContext context, {
    required WeChatScene scene,
    String title = '路记',
    String desc = '每一尾皆是勋章',
    String link = 'https://www.luji.cn',
    Uint8List? imageBytes,
  }) async {
    await ensureRegistered();

    // 未安装微信 → 模拟分享成功（演示环境）
    bool installed = false;
    try {
      installed = await _fluwx.isWeChatInstalled;
    } catch (_) {}
    if (!installed) {
      final sceneName = scene == WeChatScene.timeline
          ? Global.t('朋友圈', 'Moments')
          : Global.t('微信好友', 'WeChat friend');
      Fluttertoast.showToast(
        msg: Global.t(
          '未安装微信，已模拟分享到$sceneName',
          'WeChat not installed. Simulated share to $sceneName.',
        ),
      );
      return;
    }

    try {
      final ok = await _fluwx.share(
        imageBytes != null
            ? WeChatShareImageModel(
                WeChatImageToShare(uint8List: imageBytes),
                title: title,
                description: desc,
                scene: scene,
              )
            : WeChatShareWebPageModel(
                link,
                title: title,
                description: desc,
                scene: scene,
              ),
      );
      if (!ok) {
        Fluttertoast.showToast(msg: Global.t('分享失败，请重试', 'Share failed. Try again.'));
      }
    } catch (e) {
      debugPrint('微信分享失败: $e');
      Fluttertoast.showToast(msg: Global.t('分享失败，请重试', 'Share failed. Try again.'));
    }
  }
}

class _ShareSheet extends StatelessWidget {
  final String title;
  final String desc;
  final String link;
  final Uint8List? imageBytes;

  const _ShareSheet({
    required this.title,
    required this.desc,
    required this.link,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 22.w),
            Text(
              Global.t('分享到', 'Share to'),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Constants.INK,
              ),
            ),
            SizedBox(height: 24.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildItem(
                  context,
                  icon: RemixIcons.wechat_2_fill,
                  color: const Color(0xFF09BB07),
                  label: Global.t('微信好友', 'Chats'),
                  onTap: () => _shareTo(context, WeChatScene.session),
                ),
                SizedBox(width: 44.w),
                _buildItem(
                  context,
                  icon: RemixIcons.earth_fill,
                  color: const Color(0xFF576B95),
                  label: Global.t('朋友圈', 'Moments'),
                  onTap: () => _shareTo(context, WeChatScene.timeline),
                ),
              ],
            ),
            SizedBox(height: 28.w),
            // 取消
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: 48.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Constants.BORDER)),
                ),
                child: Text(
                  Global.t('取消', 'Cancel'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Constants.GRAY,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 分享选项：绿色圆形图标 + 文案
  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28.w, color: color),
          ),
          SizedBox(height: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Constants.GRAY,
            ),
          ),
        ],
      ),
    );
  }

  void _shareTo(BuildContext context, WeChatScene scene) {
    Navigator.of(context).pop();
    WechatShareUtil.share(
      context,
      scene: scene,
      title: title,
      desc: desc,
      link: link,
      imageBytes: imageBytes,
    );
  }
}
