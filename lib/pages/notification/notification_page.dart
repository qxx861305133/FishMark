import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/design_data.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 1.3.1 / 1.3.2 消息通知（官方消息 / 点赞 / 评论回复）
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _tab = 0;

  late List<MockOfficialMessage> _officialMessages;
  late List<MockLikeMessage> _likeMessages;
  bool _officialLoadingMore = false;
  bool _likeLoadingMore = false;

  static const _tabs = ['官方消息', '点赞', '评论回复'];
  static const _tabColors = [
    Color(0xFF1D92F6), // 蓝
    Color(0xFFFF5E59), // 红
    Color(0xFF07C160), // 绿
  ];

  @override
  void initState() {
    super.initState();
    _officialMessages = List.of(DesignData.officialMessages);
    _likeMessages = List.of(DesignData.likeMessages);
  }

  /// 下拉刷新官方消息
  Future<void> _refreshOfficial() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _officialMessages = List.of(DesignData.officialMessages));
  }

  /// 上拉加载更多官方消息
  Future<void> _loadMoreOfficial() async {
    if (_officialLoadingMore) return;
    setState(() => _officialLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _officialMessages.addAll(DesignData.officialMessages);
      _officialLoadingMore = false;
    });
  }

  /// 下拉刷新点赞列表
  Future<void> _refreshLikes() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _likeMessages = List.of(DesignData.likeMessages));
  }

  /// 上拉加载更多点赞
  Future<void> _loadMoreLikes() async {
    if (_likeLoadingMore) return;
    setState(() => _likeLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _likeMessages.addAll(DesignData.likeMessages);
      _likeLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(RemixIcons.arrow_left_s_line, size: 26.w, color: Constants.INK),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '消息通知',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: Constants.INK,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 8.w),
          _buildTabs(),
          SizedBox(height: 16.w),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final icons = [
      RemixIcons.notification_2_fill,
      RemixIcons.heart_3_fill,
      RemixIcons.chat_3_fill,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < _tabs.length; i++)
            GestureDetector(
              onTap: () => setState(() => _tab = i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 72.w,
                child: Column(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _tab == i
                            ? _tabColors[i]
                            : _tabColors[i].withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        icons[i],
                        size: 24.w,
                        color: _tab == i ? Colors.white : _tabColors[i],
                      ),
                    ),
                    SizedBox(height: 8.w),
                    Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Constants.INK,
                        fontWeight: _tab == i ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_tab == 0) return _officialList();
    if (_tab == 1) return _likeList();
    return _empty('暂无评论回复');
  }

  /// 官方消息列表（下拉刷新 + 上拉加载更多）
  Widget _officialList() {
    return RefreshIndicator(
      color: Constants.INK,
      onRefresh: _refreshOfficial,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
              n.metrics.axis == Axis.vertical) {
            _loadMoreOfficial();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(pagePadding, 0, pagePadding, 24.w),
          itemCount: _officialMessages.length + (_officialLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: 16.w),
          itemBuilder: (context, index) {
            if (index == _officialMessages.length) {
              return _buildListFooter();
            }
            final msg = _officialMessages[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Fluttertoast.showToast(msg: '演示数据，敬请期待'),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Constants.BORDER),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        msg.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Constants.INK,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (msg.unread)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5E59),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: Constants.GRAY,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 12.w),
              Divider(height: 1, color: Constants.BORDER),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        msg.date,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Constants.GRAY_LIGHT,
                        ),
                      ),
                    ),
                    Icon(
                      RemixIcons.arrow_right_s_line,
                      size: 18.w,
                      color: Constants.GRAY_LIGHT,
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
      ),
    );
  }

  /// 点赞列表（下拉刷新 + 上拉加载更多）
  Widget _likeList() {
    return RefreshIndicator(
      color: Constants.INK,
      onRefresh: _refreshLikes,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
              n.metrics.axis == Axis.vertical) {
            _loadMoreLikes();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(pagePadding, 0, pagePadding, 24.w),
          itemCount: _likeMessages.length + (_likeLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: 16.w),
          itemBuilder: (context, index) {
            if (index == _likeMessages.length) {
              return _buildListFooter();
            }
            final msg = _likeMessages[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Constants.BORDER),
          ),
          child: Row(
            children: [
              NetImage(
                url: msg.avatar,
                width: 40.w,
                height: 40.w,
                borderRadius: 20.w,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 14.sp, color: Constants.INK),
                        children: [
                          TextSpan(
                            text: msg.userName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: ' ${msg.action}',
                            style: TextStyle(color: Constants.GRAY),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.w),
                    Text(
                      msg.date,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Constants.GRAY_LIGHT,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                RemixIcons.heart_3_fill,
                size: 20.w,
                color: const Color(0xFFFF5E59),
              ),
            ],
          ),
        );
          },
        ),
      ),
    );
  }

  /// 列表底部加载中指示
  Widget _buildListFooter() {
    return Padding(
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
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            RemixIcons.chat_3_line,
            size: 48.w,
            color: Constants.GRAY_LIGHT,
          ),
          SizedBox(height: 12.w),
          Text(text, style: TextStyle(fontSize: 13.sp, color: Constants.GRAY_LIGHT)),
        ],
      ),
    );
  }
}
