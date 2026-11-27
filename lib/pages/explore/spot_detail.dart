import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/spot.dart';
import 'package:FishMark/widgets/empty_widget.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/section_header.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 钓点详情页：详情 + 常见鱼种 + 钓友点评
class SpotDetailPage extends StatefulWidget {
  // 钓点ID
  final String? rid;

  const SpotDetailPage({super.key, this.rid});

  @override
  State<SpotDetailPage> createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends State<SpotDetailPage> {
  Spot? _spot;
  final List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadReviews();
  }

  // 加载详情：GET /spots/{spot_id}
  Future<void> _loadDetail() async {
    try {
      final result = await Api().get(
        'spot_detail',
        queryParameters: {'spot_id': widget.rid},
      );
      if (!mounted) return;
      if (result['success'] == true && result['data'] != null) {
        final data = Map<String, dynamic>.from(result['data']);
        final item = data['spot'] ?? data;
        setState(() {
          _spot = Spot.fromApi(Map<String, dynamic>.from(item));
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('钓点详情加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // 加载打卡记录：GET /spots/{spot_id}/checkins
  Future<void> _loadReviews() async {
    try {
      final result = await Api().get(
        'spot_checkins',
        queryParameters: {
          'spot_id': widget.rid,
          'page': 1,
          'per_page': 20,
        },
      );
      if (!mounted) return;
      if (result['success'] == true && result['data'] is List) {
        setState(() {
          for (final item in result['data']) {
            _reviews.add(Map<String, dynamic>.from(item));
          }
        });
      }
    } catch (e) {
      LogUtil.e('钓点打卡记录加载失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      // 打卡记录按钮固定在底部，不随内容滚动
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(16.w, 6.w, 16.w, 6.w),
        child: InkButton(
          text: '打卡记录',
          height: 44,
          onPressed: () => Fluttertoast.showToast(msg: '演示数据，敬请期待'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _spot == null
              ? const EmptyWidget(text: '钓点不存在或已下架')
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final spot = _spot!;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 封面 + 返回按钮
        Stack(
          children: [
            NetImage(url: spot.cover, height: 220.w, width: double.infinity),
            SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back,
                      size: 18.w, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        // 基础信息
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      spot.name ?? '',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.star, size: 16.w, color: Constants.HIGHLIGHT_COLOR),
                  SizedBox(width: 2.w),
                  Text(
                    (spot.rating ?? 0).toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Constants.HIGHLIGHT_COLOR,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              Row(
                children: [
                  Icon(Icons.place, size: 15.w, color: Constants.TEXT_LIGHT_COLOR),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      spot.address ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.w),
        // 常见鱼种
        if (spot.fish_names != null && spot.fish_names!.isNotEmpty)
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: '常见鱼种'),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.w,
                    children: spot.fish_names!
                        .map(
                          (name) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.w),
                            decoration: BoxDecoration(
                              color: Constants.PRIMARY_COLOR
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16.w),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Constants.PRIMARY_COLOR,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 12.w),
        // 收费/开放时间
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildInfoRow(Icons.paid_outlined, '收费说明', spot.fee ?? '免费'),
              SizedBox(height: 12.w),
              _buildInfoRow(Icons.schedule_outlined, '开放时间', spot.open_time ?? '全天'),
              if (spot.description != null) ...[
                SizedBox(height: 12.w),
                _buildInfoRow(Icons.info_outline, '详细介绍', spot.description!),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.w),
        // 点评
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: '钓友点评 (${spot.reviews_count ?? _reviews.length})',
              ),
              _reviews.isEmpty
                  ? SizedBox(
                      height: 100.w,
                      child: const EmptyWidget(text: '还没有点评，钓过就来评价吧'),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                      child: Column(
                        children: _reviews.map(_buildReviewItem).toList(),
                      ),
                    ),
            ],
          ),
        ),
        SizedBox(height: 24.w),
      ],
    );
  }

  // 信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.w, color: Constants.PRIMARY_COLOR),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Constants.TEXT_SECONDARY_COLOR,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Constants.TEXT_DEFAULT_COLOR,
            ),
          ),
        ),
      ],
    );
  }

  // 点评项
  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Constants.BG_COLOR,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetImage(
                url: review['user']?['avatar'],
                width: 28.w,
                height: 28.w,
                borderRadius: 14.w,
              ),
              SizedBox(width: 8.w),
              Text(
                review['user']?['nickname'] ?? '钓友',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                review['created_at'] ?? '',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Constants.TEXT_LIGHT_COLOR,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),
          Text(
            review['content'] ?? '',
            style: TextStyle(
              fontSize: 13.sp,
              color: Constants.TEXT_DEFAULT_COLOR,
            ),
          ),
        ],
      ),
    );
  }
}

