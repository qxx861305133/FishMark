import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/challenge.dart';
import 'package:FishMark/models/feed.dart';
import 'package:FishMark/pages/challenge/challenge_detail.dart';
import 'package:FishMark/pages/challenge/challenge_list.dart';
import 'package:FishMark/pages/upload/catch_upload.dart';
import 'package:FishMark/widgets/empty_widget.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/section_header.dart';

/// @desc 首页Tab：Banner轮播 + 挑战入口 + 鱼获动态
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<Map<String, dynamic>> _banners = [];
  final List<Challenge> _challenges = [];
  final List<Feed> _feeds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        Api().get('banners'),
        Api().get('challenges', queryParameters: {'page_size': 3}),
        Api().get('home_feeds'),
      ]);
      if (!mounted) return;
      setState(() {
        _loading = false;
        // Banner
        final bannerData = results[0]['data'];
        if (bannerData is List) {
          _banners.clear();
          for (final item in bannerData) {
            _banners.add(Map<String, dynamic>.from(item));
          }
        }
        // 挑战
        final challengeData = results[1]['data'];
        if (challengeData is List) {
          _challenges.clear();
          for (final item in challengeData) {
            _challenges.add(Challenge.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        // 鱼获动态
        final feedData = results[2]['data'];
        if (feedData is List) {
          _feeds.clear();
          for (final item in feedData) {
            _feeds.add(Feed.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      });
    } catch (e) {
      LogUtil.e('首页数据加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Constants.PRIMARY_COLOR,
        elevation: 0,
        centerTitle: false,
        title: Text(
          Constants.APP_NAME,
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 32.w),
            child: Icon(Icons.phishing, size: 44.w, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.only(bottom: 160.w),
                children: [
                  _buildBanner(),
                  if (_challenges.isNotEmpty) ...[
                    SectionHeader(
                      title: '进行中的挑战',
                      actionText: '全部',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChallengeListPage(),
                          ),
                        );
                      },
                    ),
                    _buildChallenges(),
                  ],
                  SectionHeader(title: '鱼获动态'),
                  _buildFeeds(),
                ],
              ),
      ),
    );
  }

  // Banner轮播
  Widget _buildBanner() {
    if (_banners.isEmpty) {
      return SizedBox(height: 16.w);
    }
    return Container(
      margin: EdgeInsets.only(top: 24.w),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 280.w,
          viewportFraction: 0.92,
          autoPlay: _banners.length > 1,
          autoPlayInterval: const Duration(seconds: 4),
        ),
        items: _banners.map((banner) {
          return GestureDetector(
            onTap: () => _handleBannerLink(banner['link']),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(
                    url: banner['image'],
                    borderRadius: 24.w,
                  ),
                  Positioned(
                    left: 24.w,
                    bottom: 24.w,
                    child: Text(
                      banner['title'] ?? '',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Banner跳转（按link标识直接push目标页）
  void _handleBannerLink(dynamic link) {
    final target = link?.toString() ?? '';
    switch (target) {
      case 'challenge_list':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChallengeListPage()),
        );
        break;
      case 'catch_upload':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CatchUploadPage()),
        );
        break;
      default:
        Fluttertoast.showToast(msg: '活动页面敬请期待');
    }
  }

  // 挑战横滑卡片
  Widget _buildChallenges() {
    return SizedBox(
      height: 220.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        itemCount: _challenges.length,
        separatorBuilder: (_, _) => SizedBox(width: 24.w),
        itemBuilder: (context, index) {
          final challenge = _challenges[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChallengeDetailPage(rid: challenge.rid),
                ),
              );
            },
            child: Container(
              width: 480.w,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.w),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                    child: Icon(Icons.emoji_events_outlined,
                        size: 56.w, color: Constants.HIGHLIGHT_COLOR),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          challenge.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          challenge.target ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: Constants.TEXT_SECONDARY_COLOR,
                          ),
                        ),
                        SizedBox(height: 12.w),
                        Row(
                          children: [
                            Icon(Icons.military_tech,
                                size: 28.w, color: Constants.HIGHLIGHT_COLOR),
                            SizedBox(width: 4.w),
                            Text(
                              '+${challenge.points ?? 0} 积分',
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: Constants.HIGHLIGHT_COLOR,
                                fontWeight: FontWeight.w600,
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
          );
        },
      ),
    );
  }

  // 鱼获动态列表
  Widget _buildFeeds() {
    if (_feeds.isEmpty) {
      return SizedBox(
        height: 320.w,
        child: const EmptyWidget(text: '还没有动态，发一条你的鱼获吧'),
      );
    }
    return Column(
      children: _feeds.map((feed) => _buildFeedItem(feed)).toList(),
    );
  }

  // 单条动态卡片
  Widget _buildFeedItem(Feed feed) {
    return Container(
      margin: EdgeInsets.fromLTRB(32.w, 0, 32.w, 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发布者信息
          Row(
            children: [
              NetImage(
                url: feed.user?.avatar,
                width: 72.w,
                height: 72.w,
                borderRadius: 36.w,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feed.user?.nickname ?? '路亚钓友',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (feed.created_at != null)
                      Text(
                        feed.created_at!,
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Constants.TEXT_LIGHT_COLOR,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.w),
          // 文案
          if (feed.content != null && feed.content!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16.w),
              child: Text(
                feed.content!,
                style: TextStyle(
                  fontSize: 28.sp,
                  color: Constants.TEXT_DEFAULT_COLOR,
                ),
              ),
            ),
          // 图片
          if (feed.images != null && feed.images!.isNotEmpty)
            _buildFeedImages(feed.images!),
          // 鱼获信息条
          if (feed.catch_record != null)
            Container(
              margin: EdgeInsets.only(top: 16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Constants.BG_COLOR,
                borderRadius: BorderRadius.circular(16.w),
              ),
              child: Row(
                children: [
                  Icon(Icons.set_meal, size: 32.w, color: Constants.PRIMARY_COLOR),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      '${feed.catch_record!.fish?.name ?? '未知鱼种'}'
                      '${feed.catch_record!.weight != null ? ' · ${feed.catch_record!.weight}kg' : ''}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Constants.PRIMARY_COLOR,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16.w),
          // 点赞/评论
          Row(
            children: [
              GestureDetector(
                onTap: () => _handleLike(feed),
                child: Row(
                  children: [
                    Icon(
                      feed.liked == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 36.w,
                      color: feed.liked == true
                          ? Constants.ERROR_COLOR
                          : Constants.TEXT_SECONDARY_COLOR,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${feed.likes ?? 0}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 48.w),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 36.w, color: Constants.TEXT_SECONDARY_COLOR),
                  SizedBox(width: 8.w),
                  Text(
                    '${feed.comments_count ?? 0}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Constants.TEXT_SECONDARY_COLOR,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 动态九宫格图片
  Widget _buildFeedImages(List<String> images) {
    final showCount = images.length > 3 ? 3 : images.length;
    return Row(
      children: List.generate(showCount, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == showCount - 1 ? 0 : 12.w),
            child: NetImage(
              url: images[index],
              height: 200.w,
              borderRadius: 16.w,
            ),
          ),
        );
      }),
    );
  }

  // 点赞
  Future<void> _handleLike(Feed feed) async {
    if (feed.rid == null) return;
    try {
      final result = await Api().post('feed_like', data: {'rid': feed.rid});
      if (result['success']) {
        if (!mounted) return;
        setState(() {
          feed.liked = !(feed.liked ?? false);
          feed.likes = (feed.likes ?? 0) + (feed.liked == true ? 1 : -1);
        });
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('点赞失败: $e');
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }
}

