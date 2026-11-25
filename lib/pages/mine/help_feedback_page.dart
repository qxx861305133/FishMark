import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/mock/mine_data.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 5.3.5 帮助与反馈（设计稿暂缺，简洁样式 mock）
/// 长列表支持下拉刷新 + 上拉加载更多（Future.delayed 模拟请求）
class HelpFeedbackPage extends StatefulWidget {
  const HelpFeedbackPage({super.key});

  @override
  State<HelpFeedbackPage> createState() => _HelpFeedbackPageState();
}

class _HelpFeedbackPageState extends State<HelpFeedbackPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _feedbackController = TextEditingController();

  late List<Map<String, String>> _faqs;
  int _page = 0; // 已加载的追加页数
  bool _loadingMore = false;
  bool _hasMore = true; // mock：到第 3 页停止

  @override
  void initState() {
    super.initState();
    _faqs = List.of(MineData.faqs);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  // 上拉加载：接近底部时追加一页 mock 数据
  void _onScroll() {
    if (!_hasMore || _loadingMore) return;
    if (_scrollController.position.extentAfter < 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
    if (!mounted) return;
    setState(() {
      _page += 1;
      _faqs.addAll(MineData.moreFaqs(_page - 1));
      _loadingMore = false;
      if (_page >= 3) _hasMore = false;
    });
  }

  // 下拉刷新：重置列表
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
    if (!mounted) return;
    setState(() {
      _page = 0;
      _hasMore = true;
      _faqs = List.of(MineData.faqs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Constants.INPUT_BG,
        appBar: _buildAppBar(context),
        body: RefreshIndicator(
          color: Constants.INK,
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 17.w, 16.w, 40.w),
            children: [
              // 常见问题
              Text(
                Global.t('常见问题', 'FAQ'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.INK,
                ),
              ),
              SizedBox(height: 12.w),
              _buildFaqList(),
              // 加载更多状态
              if (_loadingMore)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.w),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (!_hasMore)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.w),
                  child: Center(
                    child: Text(
                      Global.t('没有更多了', 'No more'),
                      style: TextStyle(
                          fontSize: 12.5.sp, color: Constants.GRAY_LIGHT),
                    ),
                  ),
                ),
              SizedBox(height: 18.w),
              // 意见反馈
              Text(
                Global.t('意见反馈', 'Feedback'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.INK,
                ),
              ),
              SizedBox(height: 12.w),
              _buildFeedbackCard(),
            ],
          ),
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
                  Global.t('帮助与反馈', 'Help & Feedback'),
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

  // FAQ 列表（静态展开样式）
  Widget _buildFaqList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: List.generate(_faqs.length, (index) {
          final faq = _faqs[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.w, 14.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        faq['q']!,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Constants.INK,
                        ),
                      ),
                    ),
                    Icon(RemixIcons.question_answer_line,
                        size: 16.w, color: const Color(0xFFB8BCC4)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 6.w, 14.w, 12.w),
                child: Text(
                  faq['a']!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: Constants.GRAY,
                  ),
                ),
              ),
              if (index != _faqs.length - 1)
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

  // 意见反馈卡片
  Widget _buildFeedbackCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            maxLength: 200,
            style: TextStyle(fontSize: 14.sp, color: Constants.INK),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: Global.t('请描述您遇到的问题或建议…',
                  'Describe your issue or suggestion…'),
              hintStyle: TextStyle(fontSize: 14.sp, color: Constants.GRAY_LIGHT),
            ),
          ),
          SizedBox(height: 12.w),
          LimeButton(
            text: Global.t('提交', 'Submit'),
            height: 44,
            onPressed: () {
              if (_feedbackController.text.trim().isEmpty) {
                Fluttertoast.showToast(
                    msg: Global.t('请先填写反馈内容', 'Please write something first'));
                return;
              }
              _feedbackController.clear();
              FocusScope.of(context).unfocus();
              Fluttertoast.showToast(
                  msg: Global.t('感谢您的反馈（演示）', 'Thanks for your feedback (demo)'));
            },
          ),
        ],
      ),
    );
  }
}
