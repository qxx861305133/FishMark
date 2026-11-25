import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/design_data.dart';
import 'package:FishMark/pages/medal/medal_list_page.dart';
import 'package:FishMark/pages/medal/medal_achieved_sheet.dart';
import 'package:FishMark/pages/notification/notification_page.dart';
import 'package:FishMark/utils/wechat_share_util.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 1.1.1 首页

/// 内容面板底色（设计稿采样 #F5F7FB）
const Color _kPanelBg = Color(0xFFF5F7FB);

/// banner 照片总高度（底部一段被白面板遮住）
const double _kBannerH = 400;

/// 白面板上移遮挡 banner 的高度
const double _kPanelOverlap = 40;

/// 未读红点角标颜色
const Color _kBadgeRed = Color(0xFFFF5E59);

/// 挑战卡片渐变顶色（按勋章样式，设计稿采样）
const Map<MedalStyle, Color> _kChallengeTints = {
  MedalStyle.bronze: Color(0xFFFFF0E9),
  MedalStyle.silver: Color(0xFFF1F3F7),
  MedalStyle.gold: Color(0xFFFFFBE2),
  MedalStyle.blue: Color(0xFFF0F5FF),
};

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  late List<MockFeed> _feeds;
  int _feedPage = 1;
  bool _loadingMore = false;
  bool _headerGlass = false;

  @override
  void initState() {
    super.initState();
    _feeds = _generateFeeds(1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 未读官方消息数
  int get _unreadCount =>
      DesignData.officialMessages.where((m) => m.unread).length;

  /// 复制 mock 渔获生成分页数据
  List<MockFeed> _generateFeeds(int page) {
    return [
      for (final f in DesignData.feeds)
        MockFeed(
          userName: f.userName,
          avatar: f.avatar,
          date: f.date,
          image: page > 1
              ? f.image.replaceFirst('seed/luji-', 'seed/luji-p$page-')
              : f.image,
          fishName: f.fishName,
          weight: f.weight,
          length: f.length,
          location: f.location,
          likes: f.likes,
          comments: f.comments,
          liked: f.liked,
        ),
    ];
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _feedPage = 1;
      _feeds = _generateFeeds(1);
    });
  }

  /// 上拉加载更多
  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _feedPage += 1;
      _feeds.addAll(_generateFeeds(_feedPage));
      _loadingMore = false;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // 上拉加载
    if (!_loadingMore && pos.maxScrollExtent - pos.pixels < 300) _loadMore();
    // 滚过阈值后头部切换毛玻璃
    final glass = pos.pixels > 200.w;
    if (glass != _headerGlass) setState(() => _headerGlass = glass);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _headerGlass
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 滚动层：banner 照片跟随内容滚动，白面板圆角上移遮住 banner 底部
            Positioned.fill(
              child: RefreshIndicator(
                color: Constants.INK,
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [SliverToBoxAdapter(child: _buildScrollBody())],
                ),
              ),
            ),
            // 固定层：头像信息行（不随滚动）
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFixedHeaderBar(),
            ),
          ],
        ),
      ),
    );
  }

  /// 滚动主体：banner 照片 + 白色圆角内容面板（面板叠在照片底部之上）
  Widget _buildScrollBody() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // banner 背景照片（定高，随内容滚动）
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: _kBannerH.w,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(
                  url: 'https://picsum.photos/seed/luji-banner/870/540',
                  fit: BoxFit.cover,
                ),
                // 暗色遮罩
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Banner 临时占位',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 白色圆角内容面板：上移遮住 banner 底部一段
        Padding(
          padding: EdgeInsets.only(top: (_kBannerH - _kPanelOverlap).w),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _kPanelBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.w),
                SectionRow(title: '我的挑战', onViewAll: _pushMedalList),
                SizedBox(height: 16.w),
                _buildChallengeCards(),
                SizedBox(height: 24.w),
                SectionRow(
                  title: '渔获动态',
                  onViewAll: () {
                    Fluttertoast.showToast(msg: '演示数据，敬请期待');
                  },
                ),
                SizedBox(height: 16.w),
                ..._feeds.map((feed) => FeedCard(feed: feed)),
                if (_loadingMore)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.w),
                    child: Center(
                      child: SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Constants.GRAY,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 24.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 固定在顶部的头像信息行（含消息角标铃铛）
  /// 滚过阈值后切换为白色毛玻璃背景 + 深色文字
  Widget _buildFixedHeaderBar() {
    final topPadding = MediaQuery.of(context).padding.top;
    final glass = _headerGlass;
    // 前景色：正常白色 / 毛玻璃深色
    final titleColor = glass ? Constants.INK : Colors.white;
    final subColor = glass ? Constants.GRAY_LIGHT : Colors.white70;
    final bar = Container(
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        topPadding + 12.w,
        pagePadding,
        12.w,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: NetImage(
              url: DesignData.user.avatar,
              width: 41.w,
              height: 41.w,
              borderRadius: 20.5.w,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DesignData.user.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    _levelBadge(),
                    SizedBox(width: 4.w),
                    _badge(),
                  ],
                ),
                SizedBox(height: 4.w),
                Row(
                  children: [
                    Icon(RemixIcons.map_pin_line, size: 12.w, color: subColor),
                    SizedBox(width: 2.w),
                    Text(
                      DesignData.user.location,
                      style: TextStyle(fontSize: 12.sp, color: subColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildBell(glass: glass),
        ],
      ),
    );
    // 背景：普通黑色渐变 / 毛玻璃
    if (!glass) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent],
          ),
        ),
        child: bar,
      );
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: bar,
        ),
      ),
    );
  }

  /// 铃铛 + 未读消息数量角标
  Widget _buildBell({bool glass = false}) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotificationPage())),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              RemixIcons.notification_3_line,
              size: 22.w,
              color: glass ? Constants.INK : Colors.white,
            ),
            if (_unreadCount > 0)
              Positioned(
                top: -5.w,
                right: -8.w,
                child: Container(
                  height: 15.w,
                  constraints: BoxConstraints(minWidth: 15.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kBadgeRed,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white, width: 1.w),
                  ),
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    style: TextStyle(
                      fontSize: 9.sp,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _levelBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: Constants.LIME,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        DesignData.user.level,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Constants.INK,
        ),
      ),
    );
  }

  Widget _badge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D92F6),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        DesignData.user.badge,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 我的挑战横向卡片（徽章悬浮超出卡片顶部）
  Widget _buildChallengeCards() {
    return SizedBox(
      height: 166.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: DesignData.challenges.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == DesignData.challenges.length - 1 ? 0 : 12.w,
            ),
            child: _ChallengeCard(
              challenge: DesignData.challenges[index],
              onClaim: _showAchieved,
            ),
          );
        },
      ),
    );
  }

  void _pushMedalList() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MedalListPage()));
  }

  void _showAchieved() {
    MedalAchievedSheet.show(context);
  }
}

/// 我的挑战卡片：渐变底色 + 徽章悬浮超出卡片顶部
class _ChallengeCard extends StatelessWidget {
  final MockChallenge challenge;
  final VoidCallback onClaim;

  const _ChallengeCard({required this.challenge, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final claimable = challenge.status == ChallengeStatus.claimable;
    final tint = _kChallengeTints[challenge.style]!;
    return SizedBox(
      width: 122.w,
      height: 170.w, // 固定高度：16 徽章悬浮区 + 154 卡体，避免内容溢出
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 卡片主体（顶部留出徽章悬浮空间）
          Positioned(
            top: 16.w,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 48.w, 12.w, 16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.45],
                  colors: [tint, Colors.white],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    challenge.title,
                    style: TextStyle(fontSize: 12.sp, color: Constants.INK),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.w),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${challenge.current} ',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Constants.INK,
                          ),
                        ),
                        TextSpan(
                          text: '/${challenge.total}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Constants.GRAY_LIGHT,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.w),
                  GestureDetector(
                    onTap: claimable ? onClaim : null,
                    child: Container(
                      width: double.infinity,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: claimable ? Constants.LIME : Constants.INPUT_BG,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Text(
                          '领取徽章',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: claimable ? Constants.INK : Constants.GRAY,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 徽章：悬浮在卡片顶部之上
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: HexMedal(style: challenge.style, size: 56)),
          ),
        ],
      ),
    );
  }
}

/// 渔获动态卡片
class FeedCard extends StatefulWidget {
  final MockFeed feed;

  const FeedCard({super.key, required this.feed});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    final feed = widget.feed;
    return Container(
      margin: EdgeInsets.fromLTRB(pagePadding, 0, pagePadding, 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Constants.BORDER),
      ),
      child: Column(
        children: [
          // 头部：用户 + 日期
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                child: NetImage(
                  url: feed.avatar,
                  width: 36.w,
                  height: 36.w,
                  borderRadius: 18.w,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  feed.userName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Constants.INK,
                  ),
                ),
              ),
              Text(
                feed.date,
                style: TextStyle(fontSize: 12.sp, color: Constants.GRAY_LIGHT),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          // 照片
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: double.infinity,
              height: 190.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(url: feed.image, fit: BoxFit.cover),
                  // 底部渐变
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  // 鱼名 / 地点 / 重量长度
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 10.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feed.fishName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.w),
                              Row(
                                children: [
                                  Icon(
                                    RemixIcons.map_pin_line,
                                    size: 11.w,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    feed.location,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              feed.weight,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Constants.LIME,
                              ),
                            ),
                            SizedBox(height: 2.w),
                            Text(
                              feed.length,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.w),
          // 操作行：点赞 / 评论 / 分享
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  feed.liked = !feed.liked;
                  feed.likes += feed.liked ? 1 : -1;
                }),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Row(
                    children: [
                      Icon(
                        feed.liked
                            ? RemixIcons.heart_3_fill
                            : RemixIcons.heart_3_line,
                        size: 18.w,
                        color: feed.liked ? _kBadgeRed : Constants.GRAY,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatCount(feed.likes),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: feed.liked ? _kBadgeRed : Constants.GRAY,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Row(
                    children: [
                      Icon(
                        RemixIcons.chat_3_line,
                        size: 18.w,
                        color: Constants.GRAY,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${feed.comments}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Constants.GRAY,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => WechatShareUtil.show(
                  context,
                  title: '${feed.fishName} | 路记',
                  desc: '${feed.userName} 在${feed.location}钓获${feed.fishName}',
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Row(
                    children: [
                      Icon(
                        RemixIcons.share_forward_line,
                        size: 18.w,
                        color: Constants.GRAY,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '分享',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Constants.GRAY,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final rest = s.length - i;
      buf.write(s[i]);
      if (rest > 1 && rest % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
