import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';

/// @desc 5.3.4 通知设置（设计稿暂缺，简洁样式 mock）
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // 开关状态（mock）
  final Map<String, bool> _switches = {
    'catch': true, // 渔获记录提醒
    'interact': true, // 点赞与评论
    'follow': false, // 新粉丝关注
    'official': true, // 官方公告与活动
    'dnd': false, // 夜间免打扰
  };

  String _title(String key) {
    switch (key) {
      case 'catch':
        return Global.t('渔获记录提醒', 'Catch record alerts');
      case 'interact':
        return Global.t('点赞与评论', 'Likes & comments');
      case 'follow':
        return Global.t('新粉丝关注', 'New followers');
      case 'official':
        return Global.t('官方公告与活动', 'Announcements & events');
      default:
        return Global.t('夜间免打扰（22:00 - 8:00）', 'Do not disturb (22:00 - 8:00)');
    }
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: List.generate(_switches.length, (index) {
                  final key = _switches.keys.elementAt(index);
                  return Column(
                    children: [
                      _buildSwitchRow(key),
                      if (index != _switches.length - 1)
                        Container(
                          margin: EdgeInsets.only(left: 14.w),
                          height: 0.5.w,
                          color: const Color(0xFFEFEFEF),
                        ),
                    ],
                  );
                }),
              ),
            ),
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
                  Global.t('通知设置', 'Notifications'),
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

  // 开关行
  Widget _buildSwitchRow(String key) {
    return InkWell(
      onTap: () => setState(() => _switches[key] = !_switches[key]!),
      child: Container(
        height: 52.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _title(key),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Constants.INK,
                ),
              ),
            ),
            Switch(
              value: _switches[key]!,
              activeThumbColor: Constants.INK,
              activeTrackColor: Constants.LIME,
              onChanged: (value) => setState(() => _switches[key] = value),
            ),
          ],
        ),
      ),
    );
  }
}
