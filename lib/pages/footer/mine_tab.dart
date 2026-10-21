import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/user.dart';
import 'package:FishMark/pages/auth/login.dart';
import 'package:FishMark/pages/challenge/challenge_list.dart';
import 'package:FishMark/pages/explore/fish_species_list.dart';
import 'package:FishMark/pages/gear/gear_library.dart';
import 'package:FishMark/pages/medal/medal_wall.dart';
import 'package:FishMark/pages/mine/digital_resume.dart';
import 'package:FishMark/pages/subscription/subscription.dart';
import 'package:FishMark/provider/profile.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 我的Tab：用户头卡 + 数据总览 + 功能入口
class MineTab extends StatefulWidget {
  const MineTab({super.key});

  @override
  State<MineTab> createState() => _MineTabState();
}

class _MineTabState extends State<MineTab> {
  // 图鉴入口颜色
  static const Color _successIconColor = Color.fromRGBO(22, 163, 74, 1.0);

  // 数据总览
  Map<String, dynamic> _overview = {};

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    final isLogin = Provider.of<UserNotifier>(context, listen: false).isLogin;
    if (!isLogin) return;
    try {
      final result = await Api().get('my_overview');
      if (!mounted) return;
      if (result['success'] && result['data'] is Map) {
        setState(() {
          _overview = Map<String, dynamic>.from(result['data']);
        });
      }
    } catch (e) {
      LogUtil.e('数据总览加载失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      body: Consumer<UserNotifier>(builder: (context, userNotifier, _) {
        final user = userNotifier.user;
        final isLogin = userNotifier.isLogin;
        return RefreshIndicator(
          onRefresh: _loadOverview,
          child: ListView(
            padding: EdgeInsets.only(bottom: 160.w),
            children: [
              _buildHeader(user, isLogin),
              SizedBox(height: 24.w),
              _buildOverview(),
              SizedBox(height: 24.w),
              _buildMenuGrid(),
            ],
          ),
        );
      }),
    );
  }

  // 用户头卡
  Widget _buildHeader(User? user, bool isLogin) {
    return Container(
      padding: EdgeInsets.fromLTRB(32.w, 120.w, 32.w, 48.w),
      decoration: BoxDecoration(
        color: Constants.PRIMARY_COLOR,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.w)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _requireLogin(isLogin),
            child: NetImage(
              url: isLogin ? user?.avatar : null,
              width: 120.w,
              height: 120.w,
              borderRadius: 60.w,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _requireLogin(isLogin),
                  child: Text(
                    isLogin ? (user?.nickname ?? '路亚钓友') : '点击登录',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 12.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.w),
                  decoration: BoxDecoration(
                    color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24.w),
                  ),
                  child: Text(
                    _tierLabel(isLogin ? user?.subscribeTier : 'free'),
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: Constants.HIGHLIGHT_COLOR,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 订阅入口
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
            },
            child: Icon(Icons.workspace_premium,
                size: 48.w, color: Constants.HIGHLIGHT_COLOR),
          ),
        ],
      ),
    );
  }

  // 数据总览
  Widget _buildOverview() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.symmetric(vertical: 32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildOverviewItem('鱼获', '${_overview['catch_count'] ?? 0}'),
          _buildOverviewItem('解锁鱼种', '${_overview['species_count'] ?? 0}'),
          _buildOverviewItem('勋章', '${_overview['medal_count'] ?? 0}'),
          _buildOverviewItem('挑战完成', '${_overview['challenge_count'] ?? 0}'),
        ],
      ),
    );
  }

  // 总览项
  Widget _buildOverviewItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            color: Constants.PRIMARY_COLOR,
          ),
        ),
        SizedBox(height: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 24.sp,
            color: Constants.TEXT_SECONDARY_COLOR,
          ),
        ),
      ],
    );
  }

  // 功能入口宫格
  Widget _buildMenuGrid() {
    final menus = [
      {'icon': Icons.auto_stories, 'label': '数字履历', 'color': Constants.PRIMARY_COLOR, 'route': 'resume'},
      {'icon': Icons.military_tech, 'label': '勋章墙', 'color': Constants.HIGHLIGHT_COLOR, 'route': 'medal'},
      {'icon': Icons.set_meal, 'label': '鱼种图鉴', 'color': _successIconColor, 'route': 'fish'},
      {'icon': Icons.build_outlined, 'label': '装备库', 'color': Constants.WARNING_COLOR, 'route': 'gear'},
      {'icon': Icons.emoji_events_outlined, 'label': '挑战', 'color': Constants.PRIMARY_COLOR, 'route': 'challenge'},
      {'icon': Icons.workspace_premium_outlined, 'label': '订阅', 'color': Constants.HIGHLIGHT_COLOR, 'route': 'subscription'},
    ];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.symmetric(vertical: 32.w, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: menus.map((menu) {
          return GestureDetector(
            onTap: () => _handleMenuTap(menu['route'] as String),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88.w,
                  height: 88.w,
                  decoration: BoxDecoration(
                    color: (menu['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24.w),
                  ),
                  child: Icon(menu['icon'] as IconData,
                      size: 44.w, color: menu['color'] as Color),
                ),
                SizedBox(height: 12.w),
                Text(
                  menu['label'] as String,
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_DEFAULT_COLOR,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 菜单跳转（未登录统一拦截）
  void _handleMenuTap(String route) {
    final isLogin =
        Provider.of<UserNotifier>(context, listen: false).isLogin;
    if (!isLogin) {
      _goLogin();
      return;
    }
    switch (route) {
      case 'resume':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DigitalResumePage()),
        );
        break;
      case 'medal':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MedalWallPage()),
        );
        break;
      case 'fish':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FishSpeciesListPage()),
        );
        break;
      case 'gear':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GearLibraryPage()),
        );
        break;
      case 'challenge':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChallengeListPage()),
        );
        break;
      case 'subscription':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SubscriptionPage()),
        );
        break;
    }
  }

  // 需要登录
  void _requireLogin(bool isLogin) {
    if (!isLogin) _goLogin();
  }

  void _goLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // 订阅档位文案
  String _tierLabel(String? tier) {
    const map = {'free': '免费版', 'pro': 'Pro会员', 'master': 'Master大师'};
    return map[tier] ?? '免费版';
  }
}

