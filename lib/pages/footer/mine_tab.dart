import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/mock/design_data.dart';
import 'package:FishMark/mock/mine_data.dart';
import 'package:FishMark/pages/explore/fish_species_list.dart';
import 'package:FishMark/pages/medal/medal_list_page.dart';
import 'package:FishMark/pages/mine/more_settings_page.dart';
import 'package:FishMark/pages/subscription/subscription.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 5.1 我的
class MineTab extends StatefulWidget {
  const MineTab({super.key});

  @override
  State<MineTab> createState() => _MineTabState();
}

class _MineTabState extends State<MineTab> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Constants.INPUT_BG,
        body: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildBody(context)],
          ),
        ),
      ),
    );
  }

  // ===== 顶部：照片头 + 统计 + VIP条 + 内容面板 =====
  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 照片头部：照片只铺头部区域（底部多留 20，被 VIP 深色条上移遮盖）
        Stack(
          children: [
            // 背景照片（带占位兜底）
            Positioned.fill(
              child: NetImage(
                url: 'https://picsum.photos/seed/luji-mine-hero/1170/720',
                fit: BoxFit.cover,
              ),
            ),
            // 暗色遮罩（非 positioned 子组件，决定 Stack 尺寸）
            Container(
              color: Colors.black.withValues(alpha: 0.30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SafeArea(bottom: false, child: _buildHeader(context)),
                  SizedBox(height: 26.w),
                  _buildStats(),
                  SizedBox(height: 42.w),
                ],
              ),
            ),
          ],
        ),
        // VIP 深色条 + 浅色面板整体上移 20，盖住照片头部底部（与首页面板遮 banner 同方式）
        Transform.translate(
          offset: Offset(0, -20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // VIP 会员条：圆角+金边压在照片上
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1E1E), Color(0xFF3C3C3C)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFC9962A),
                      width: 1.2.w,
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _goSubscription(context),
                  child: _buildVipBar(),
                ),
              ),
              // 浅色内容面板：紧贴 VIP 条下方（页尾下方透出同色背景）
              Container(
                color: Constants.INPUT_BG,
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 120.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGalleryCard(context),
                    SizedBox(height: 18.w),
                    _buildMedalCard(context),
                    SizedBox(height: 18.w),
                    _buildTimelineCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== 用户信息 =====
  Widget _buildHeader(BuildContext context) {
    final user = MineData.user;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5.w),
            ),
            child: NetImage(
              url: user.avatar,
              width: 52.w,
              height: 52.w,
              borderRadius: 26.w,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称 + 徽章
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _nameBadge('Lv.5', const [
                      Color(0xFFE3B367),
                      Color(0xFFD9A24A),
                    ]),
                    SizedBox(width: 6.w),
                    _nameBadge('路亚先锋', const [
                      Color(0xFF1C91F5),
                      Color(0xFF1384E5),
                    ]),
                  ],
                ),
                SizedBox(height: 8.w),
                // 位置
                Row(
                  children: [
                    Icon(
                      RemixIcons.map_pin_2_fill,
                      size: 14.w,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      user.location,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // 设置入口（返回后刷新，跟随语言等全局配置）
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MoreSettingsPage()),
              );
              if (mounted) setState(() {});
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                RemixIcons.settings_fill,
                size: 24.w,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 昵称小徽章
  Widget _nameBadge(String text, List<Color> colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ===== 数据统计 =====
  Widget _buildStats() {
    // 统计标签中英文对照（与 MineData.stats 顺序一致）
    const enLabels = [
      'Total Catches',
      'Species Unlocked',
      'Total Weight',
      'Best Catch',
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: List.generate(MineData.stats.length, (index) {
          final item = MineData.stats[index];
          return Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item['value']!,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 6.w),
                Text(
                  Global.t(item['label']!, enLabels[index]),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ===== VIP 会员中心条 =====
  Widget _buildVipBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF8DE8B), Color(0xFFD9A24A)],
            ).createShader(bounds),
            child: Text(
              'VIP',
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            Global.t('会员中心', 'Membership'),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            Global.t('解锁', 'Unlock'),
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
          ),
          Expanded(
            flex: 3,
            child: Text(
              Global.t(
                ' 无限鱼获记录 · 私密钓点 · AI识鱼额度',
                ' Unlimited records · Private spots · AI ID',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9C9C9C)),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 我的图鉴 =====
  Widget _buildGalleryCard(BuildContext context) {
    return Container(
      // 卡片自身裁剪：横向滑动的鱼种卡不会越出卡片边界（与设计稿一致，右侧贴边截断）
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 0, 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Row(
              children: [
                Text(
                  Global.t('我的图鉴', 'My Collection'),
                  style: _cardTitleStyle(),
                ),
                const Spacer(),
                Text(
                  '16',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: Constants.INK,
                  ),
                ),
                Text(
                  ' /245',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Constants.GRAY_LIGHT,
                  ),
                ),
                SizedBox(width: 10.w),
                _borderPill(
                  Global.t('查看全部', 'View All'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FishSpeciesListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 14.w),
          SizedBox(
            height: 80.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: MineData.gallery.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (_, index) {
                final fish = MineData.gallery[index];
                return _fishTile(fish);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 图鉴鱼种卡
  Widget _fishTile(GalleryFish fish) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: SizedBox(
        width: 80.w,
        height: 80.w,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(url: fish.image),
            Positioned(
              left: 0,
              right: 0,
              bottom: 6.w,
              child: Center(
                child: Text(
                  fish.name,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== 我的勋章 =====
  Widget _buildMedalCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(Global.t('我的勋章', 'My Medals'), style: _cardTitleStyle()),
              const Spacer(),
              _borderPill(
                Global.t('查看全部', 'View All'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MedalListPage()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.w),
          Row(
            children: MineData.medals.map((medal) {
              return Expanded(
                child: Column(
                  children: [
                    HexMedal(style: medal.style, size: 62),
                    SizedBox(height: 10.w),
                    Text(
                      medal.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        height: 1.3,
                        color: Constants.INK,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===== 我的时间轴 =====
  Widget _buildTimelineCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Global.t('我的时间轴', 'My Timeline'), style: _cardTitleStyle()),
          SizedBox(height: 20.w),
          ...List.generate(MineData.timeline.length, (index) {
            final isLast = index == MineData.timeline.length - 1;
            return _timelineItem(MineData.timeline[index], isLast: isLast);
          }),
        ],
      ),
    );
  }

  // 时间轴单项
  Widget _timelineItem(TimelineEvent event, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左列：图标块 + 节点 + 虚线
        SizedBox(
          width: 64.w,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  _timelineTile(event),
                  Positioned(
                    bottom: -7.w,
                    child: Container(
                      width: 13.w,
                      height: 13.w,
                      decoration: BoxDecoration(
                        color: Constants.LIME,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5.w),
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast)
                CustomPaint(
                  size: Size(1.5.w, 30.w),
                  painter: _DashedLinePainter(),
                ),
            ],
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.w, bottom: isLast ? 0 : 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: event.title
                        .map(
                          (seg) => TextSpan(
                            text: seg.text,
                            style: TextStyle(
                              fontSize: 16.5.sp,
                              fontWeight: seg.bold
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: Constants.INK,
                              height: 1.35,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(height: 6.w),
                Text(
                  event.date,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Constants.GRAY_LIGHT,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 时间轴图标块
  Widget _timelineTile(TimelineEvent event) {
    Widget child;
    switch (event.type) {
      case TimelineType.record:
        child = NetImage(
          url: event.image,
          width: 64.w,
          height: 64.w,
          borderRadius: 16.r,
        );
        break;
      case TimelineType.spot:
        child = Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Icon(
              RemixIcons.map_pin_2_fill,
              size: 30.w,
              color: const Color(0xFF1B8DF0),
            ),
          ),
        );
        break;
      case TimelineType.medal:
        child = Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10.w,
                offset: Offset(0, 3.w),
              ),
            ],
          ),
          child: Center(child: HexMedal(style: MedalStyle.gold, size: 52)),
        );
        break;
    }
    return child;
  }

  // ===== 通用小部件 =====

  // 卡片标题
  TextStyle _cardTitleStyle() {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: Constants.INK,
    );
  }

  // 描边胶囊（查看全部）
  Widget _borderPill(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: Constants.BORDER),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: Constants.GRAY),
          ),
        ),
      ),
    );
  }

  void _goSubscription(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SubscriptionPage()));
  }
}

/// 时间轴垂直虚线
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Constants.INK
      ..strokeWidth = 1.5.w
      ..style = PaintingStyle.stroke;
    const dash = 3.0;
    const gap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dash).clamp(0.0, size.height)),
        paint,
      );
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}
