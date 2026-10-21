import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/pages/footer/explore_tab.dart';
import 'package:FishMark/pages/footer/home_tab.dart';
import 'package:FishMark/pages/footer/mine_tab.dart';
import 'package:FishMark/pages/footer/report_tab.dart';
import 'package:FishMark/pages/upload/publish_sheet.dart';
import 'package:FishMark/provider/tab_provider.dart';

/// @desc 主框架：底部导航（首页/探索/发布/战报/我的）
class HomePage extends StatefulWidget {
  final int tabIndex;
  const HomePage({super.key, this.tabIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pageController = PageController();
  // 存储4个页面
  late List<Widget> _bodys;

  @override
  void initState() {
    super.initState();

    _bodys = [
      const HomeTab(),
      const ExploreTab(),
      const ReportTab(),
      const MineTab(),
    ];

    // 跳转至某页
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
    // 切换菜单
    Provider.of<TabProvider>(context, listen: false).updateTabIndex(index);
    pageController.jumpToPage(index);
  }

  /// 中间发布按钮：唤起上传面板
  void onPublishTap() {
    PublishSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
        builder: (context, tabProvider, _) {
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
        floatingActionButton: PublishFabButton(
          onTap: onPublishTap,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          height: 120.w,
          color: Colors.white,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.w,
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              _buildTabItem(
                context,
                index: 0,
                icon: Icons.home_rounded,
                label: '首页',
                isActive: tabProvider.tabIndex == 0,
              ),
              _buildTabItem(
                context,
                index: 1,
                icon: Icons.explore_outlined,
                label: '探索',
                isActive: tabProvider.tabIndex == 1,
              ),
              SizedBox(width: 120.w),
              _buildTabItem(
                context,
                index: 2,
                icon: Icons.description_outlined,
                label: '战报',
                isActive: tabProvider.tabIndex == 2,
              ),
              _buildTabItem(
                context,
                index: 3,
                icon: Icons.person_outline,
                label: '我的',
                isActive: tabProvider.tabIndex == 3,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabItem(
    BuildContext context, {
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
              size: 48.w,
              color: isActive
                  ? Constants.PRIMARY_COLOR
                  : Constants.TEXT_LIGHT_COLOR,
            ),
            SizedBox(height: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 22.sp,
                color: isActive
                    ? Constants.PRIMARY_COLOR
                    : Constants.TEXT_LIGHT_COLOR,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// @desc 中间发布按钮
class PublishFabButton extends StatelessWidget {
  final VoidCallback onTap;
  const PublishFabButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 108.w,
        height: 108.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Constants.PRIMARY_COLOR,
          border: Border.all(color: Colors.white, width: 6.w),
          boxShadow: [
            BoxShadow(
              color: Constants.PRIMARY_COLOR.withValues(alpha: 0.3),
              blurRadius: 16.w,
              offset: Offset(0, 6.w),
            ),
          ],
        ),
        child: Icon(Icons.add, size: 56.w, color: Colors.white),
      ),
    );
  }
}
