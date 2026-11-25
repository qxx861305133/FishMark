import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/pages/auth/agreement_page.dart';
import 'package:FishMark/pages/mine/version_update_dialog.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 5.3.6 关于路记（设计稿暂缺，简洁样式 mock）
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
            SizedBox(height: 36.w),
            // Logo + 名称 + Slogan + 版本
            Center(child: AppLogo(size: 96)),
            SizedBox(height: 16.w),
            Center(
              child: Text(
                Constants.APP_NAME,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.INK,
                ),
              ),
            ),
            SizedBox(height: 6.w),
            Center(
              child: Text(
                Constants.APP_SLOGAN,
                style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
              ),
            ),
            SizedBox(height: 10.w),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  Global.t('版本 2.1.1', 'Version 2.1.1'),
                  style: TextStyle(fontSize: 12.sp, color: Constants.GRAY),
                ),
              ),
            ),
            SizedBox(height: 32.w),
            // 协议入口 + 检查更新
            _buildGroup(context),
            SizedBox(height: 32.w),
            // 备案号
            Center(
              child: Text(
                'APP备案号 浙ICP备2023004716号',
                style: TextStyle(
                    fontSize: 12.5.sp, color: Constants.GRAY_LIGHT),
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
                  Global.t('关于路记', 'About'),
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

  Widget _buildGroup(BuildContext context) {
    final rows = <(String, VoidCallback)>[
      (
        Global.t('用户协议', 'User Agreement'),
        () => AgreementPage.show(context, title: '用户协议'),
      ),
      (
        Global.t('隐私政策', 'Privacy Policy'),
        () => AgreementPage.show(context, title: '隐私政策'),
      ),
      (
        Global.t('个人信息收集清单', 'Personal Info List'),
        () => AgreementPage.show(context, title: '个人信息收集清单'),
      ),
      (
        Global.t('检查更新', 'Check Updates'),
        () => showDialog(
              context: context,
              barrierColor: Colors.black54,
              builder: (_) => const VersionUpdateDialog(),
            ),
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: List.generate(rows.length, (index) {
          return Column(
            children: [
              _buildRow(rows[index].$1, rows[index].$2),
              if (index != rows.length - 1)
                Container(
                  margin: EdgeInsets.only(left: 14.w),
                  height: 0.5.w,
                  color: const Color(0xFFEFEFEF),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRow(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Constants.INK,
                ),
              ),
            ),
            Icon(RemixIcons.arrow_right_s_line,
                size: 20.w, color: const Color(0xFFB8BCC4)),
          ],
        ),
      ),
    );
  }
}
