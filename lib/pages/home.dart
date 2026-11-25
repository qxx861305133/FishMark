import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/pages/footer/explore_tab.dart';
import 'package:FishMark/pages/footer/home_tab.dart';
import 'package:FishMark/pages/footer/mine_tab.dart';
import 'package:FishMark/pages/footer/gear_tab.dart';
import 'package:FishMark/pages/upload/publish_sheet.dart';
import 'package:FishMark/provider/tab_provider.dart';

/// @desc 主框架：底部导航（首页/探索/上传/装备/我的）
class HomePage extends StatefulWidget {
  final int tabIndex;
  const HomePage({super.key, this.tabIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pageController = PageController();
  late List<Widget> _bodys;

  @override
  void initState() {
    super.initState();

    _bodys = [
      const HomeTab(),
      const ExploreTab(),
      const GearTab(),
      const MineTab(),
    ];

    if (widget.tabIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onTabTap(widget.tabIndex);
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onTabTap(int index) {
    // 页面顺序：0首页 1探索 2装备 3我的
    Provider.of<TabProvider>(context, listen: false).updateTabIndex(index);
    pageController.jumpToPage(index);
  }

  /// 中间上传按钮：唤起上传面板
  void onPublishTap() {
    PublishSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(builder: (context, tabProvider, _) {
      return Scaffold(
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _bodys,
          onPageChanged: (index) {
            Provider.of<TabProvider>(context, listen: false)
                .updateTabIndex(index);
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Constants.BORDER, width: 0.5.w),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56.w,
              child: Row(
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: RemixIcons.home_5_fill,
                    label: '首页',
                    isActive: tabProvider.tabIndex == 0,
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: RemixIcons.compass_3_line,
                    label: '探索',
                    isActive: tabProvider.tabIndex == 1,
                  ),
                  _buildPublishItem(),
                  _buildTabItem(
                    index: 2,
                    icon: RemixIcons.briefcase_4_line,
                    label: '装备',
                    isActive: tabProvider.tabIndex == 2,
                  ),
                  _buildTabItem(
                    index: 3,
                    icon: RemixIcons.user_3_line,
                    label: '我的',
                    isActive: tabProvider.tabIndex == 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.w,
              color: isActive ? Constants.INK : const Color(0xFFB3B3B3),
            ),
            SizedBox(height: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isActive ? Constants.INK : const Color(0xFFB3B3B3),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 中间上传按钮（荧光绿圆形 + 黑色加号，向上突出于导航栏）
  Widget _buildPublishItem() {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onPublishTap,
          child: Transform.translate(
            offset: Offset(0, -14.w),
            child: Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constants.LIME,
                border: Border.all(color: Colors.white, width: 3.w),
                boxShadow: [
                  BoxShadow(
                    color: Constants.LIME.withValues(alpha: 0.45),
                    blurRadius: 14.w,
                    offset: Offset(0, 5.w),
                  ),
                ],
              ),
              child: Icon(RemixIcons.add_line, size: 26.w, color: Constants.INK),
            ),
          ),
        ),
      ),
    );
  }
}
