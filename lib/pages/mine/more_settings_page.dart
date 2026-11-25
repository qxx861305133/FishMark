import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/mock/mine_data.dart';
import 'package:FishMark/pages/auth/agreement_page.dart';
import 'package:FishMark/pages/mine/about_page.dart';
import 'package:FishMark/pages/mine/help_feedback_page.dart';
import 'package:FishMark/pages/mine/logout_confirm_dialog.dart';
import 'package:FishMark/pages/mine/notification_settings_page.dart';
import 'package:FishMark/pages/mine/profile_edit_page.dart';
import 'package:FishMark/utils/wechat_share_util.dart';
import 'package:FishMark/pages/mine/score_dialog.dart';
import 'package:FishMark/pages/mine/unit_setting_page.dart';
import 'package:FishMark/pages/mine/version_update_dialog.dart';

/// @desc 5.2.1 更多设置
class MoreSettingsPage extends StatefulWidget {
  const MoreSettingsPage({super.key});

  @override
  State<MoreSettingsPage> createState() => _MoreSettingsPageState();
}

class _MoreSettingsPageState extends State<MoreSettingsPage> {
  // 设置项图标映射
  static const Map<String, IconData> _icons = {
    'user_settings': RemixIcons.user_settings_line,
    'unit': RemixIcons.scales_line,
    'language': RemixIcons.global_line,
    'notification': RemixIcons.notification_3_line,
    'feedback': RemixIcons.customer_service_2_line,
    'about': RemixIcons.information_line,
    'share': RemixIcons.share_line,
    'score': RemixIcons.heart_line,
    'version': RemixIcons.arrow_down_circle_line,
    'logout': RemixIcons.logout_box_r_line,
  };

  // 设置项文案中英文对照（key 与 icon 一致）
  static const Map<String, List<String>> _labels = {
    'user_settings': ['个人资料', 'Profile'],
    'unit': ['计量单位', 'Units'],
    'language': ['多语言', 'Language'],
    'notification': ['通知设置', 'Notifications'],
    'feedback': ['帮助与反馈', 'Help & Feedback'],
    'about': ['关于路记', 'About'],
    'share': ['分享给朋友', 'Share'],
    'score': ['去评分', 'Rate Us'],
    'version': ['版本更新', 'Version Update'],
    'logout': ['退出登录', 'Log Out'],
  };

  String _label(String icon) {
    final pair = _labels[icon];
    if (pair == null) return '';
    return Global.t(pair[0], pair[1]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Constants.INPUT_BG,
        appBar: _buildAppBar(context),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 17.w, 16.w, 40.w),
          children: [
            // 分组卡片
            ...List.generate(MineData.settingsGroups.length, (index) {
              final group = MineData.settingsGroups[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 18.w),
                child: _buildGroup(context, group.items),
              );
            }),
            SizedBox(height: 22.w),
            _buildAgreementFooter(context),
            SizedBox(height: 14.w),
            _buildIcpFooter(),
          ],
        ),
      ),
    );
  }

  // 顶部导航
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    return PreferredSize(
      preferredSize: Size.fromHeight(statusBar + 44.w),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 44.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  Global.t('更多设置', 'More Settings'),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Constants.INK,
                  ),
                ),
                Positioned(
                  left: 10.w,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(RemixIcons.arrow_left_s_line,
                        size: 26.w, color: Constants.INK),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 设置分组卡片
  Widget _buildGroup(BuildContext context, List<SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              _buildRow(context, item),
              if (index != items.length - 1)
                Container(
                  margin: EdgeInsets.only(left: 16.w),
                  height: 0.5.w,
                  color: const Color(0xFFEFEFEF),
                ),
            ],
          );
        }),
      ),
    );
  }

  // 行右侧值（多语言跟随当前语言显示）
  String? _valueOf(SettingsItem item) {
    if (item.icon == 'language') {
      return Global.lang == 'en' ? 'English' : '中文（简体）';
    }
    if (item.icon == 'version' && item.value != null) {
      return Global.t('版本号 2.1.1', 'Version 2.1.1');
    }
    return item.value;
  }

  // 设置行
  Widget _buildRow(BuildContext context, SettingsItem item) {
    final hasChevron = item.icon != 'logout';
    return InkWell(
      onTap: () => _handleTap(context, item),
      child: Container(
        height: 48.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          children: [
            Icon(_icons[item.icon], size: 21.w, color: Constants.INK),
            SizedBox(width: 12.w),
            Text(
              _label(item.icon),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Constants.INK,
              ),
            ),
            const Spacer(),
            if (_valueOf(item) != null)
              Text(
                _valueOf(item)!,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: Constants.GRAY_LIGHT,
                ),
              ),
            if (hasChevron) ...[
              SizedBox(width: 4.w),
              Icon(RemixIcons.arrow_right_s_line,
                  size: 20.w, color: const Color(0xFFB8BCC4)),
            ],
          ],
        ),
      ),
    );
  }

  // 行点击
  void _handleTap(BuildContext context, SettingsItem item) {
    switch (item.icon) {
      case 'user_settings':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileEditPage()),
        );
        break;
      case 'unit':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UnitSettingPage()),
        );
        break;
      case 'language':
        _showLanguageSheet(context);
        break;
      case 'notification':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
        );
        break;
      case 'feedback':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HelpFeedbackPage()),
        );
        break;
      case 'about':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AboutPage()),
        );
        break;
      case 'score':
        showDialog(
          context: context,
          barrierColor: Colors.black54,
          builder: (_) => const ScoreDialog(),
        );
        break;
      case 'version':
        showDialog(
          context: context,
          barrierColor: Colors.black54,
          builder: (_) => const VersionUpdateDialog(),
        );
        break;
      case 'logout':
        showDialog(
          context: context,
          barrierColor: Colors.black54,
          builder: (_) => const LogoutConfirmDialog(),
        );
        break;
      default:
        // 分享给朋友：微信分享面板
        WechatShareUtil.show(
          context,
          title: Global.t('路记', 'Luji'),
          desc: Global.t('每一尾皆是勋章', 'Every catch is a medal'),
        );
        break;
    }
  }

  // ===== 多语言底部弹窗（中文（简体）/ English）=====
  void _showLanguageSheet(BuildContext context) {
    final options = [
      ('zh', '中文（简体）'),
      ('en', 'English'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
                child: Text(
                  Global.t('多语言', 'Language'),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Constants.INK,
                  ),
                ),
              ),
              ...options.map((option) {
                final selected = Global.lang == option.$1;
                return InkWell(
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (Global.lang != option.$1) {
                      setState(() => Global.lang = option.$1);
                      Fluttertoast.showToast(
                        msg: option.$1 == 'en'
                            ? 'Switched to English'
                            : '已切换为中文（简体）',
                      );
                    }
                  },
                  child: Container(
                    height: 52.w,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.$2,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: Constants.INK,
                            ),
                          ),
                        ),
                        _checkDot(selected),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 12.w),
            ],
          ),
        );
      },
    );
  }

  // 选中/未选中圆点（样式对齐计量单位页）
  Widget _checkDot(bool selected) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Constants.LIME : Colors.white,
        border: selected
            ? null
            : Border.all(color: const Color(0xFFC9CED6), width: 1.5.w),
      ),
      child: selected
          ? Icon(RemixIcons.check_line, size: 14.w, color: Constants.INK)
          : null,
    );
  }

  // 底部协议链接
  Widget _buildAgreementFooter(BuildContext context) {
    TextStyle base = TextStyle(fontSize: 12.5.sp, color: Constants.GRAY_LIGHT);
    Widget link(String text, String title) => GestureDetector(
          onTap: () {
            AgreementPage.show(context, title: title);
          },
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: const Color(0xFF21582F),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(Global.t('查看 ', 'View '), style: base),
            link('《用户协议》', '用户协议'),
            link('《隐私政策》', '隐私政策'),
            link('《个人信息收集清单》', '个人信息收集清单'),
          ],
        ),
        SizedBox(height: 6.w),
        link('《第三方信息共享清单》', '第三方信息共享清单'),
      ],
    );
  }

  // 备案号
  Widget _buildIcpFooter() {
    return Center(
      child: Text(
        'APP备案号 浙ICP备2023004716号',
        style: TextStyle(fontSize: 12.5.sp, color: Constants.GRAY_LIGHT),
      ),
    );
  }
}
