import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/http/api.dart';
import 'package:luji_app/models/spot.dart';
import 'package:luji_app/widgets/empty_widget.dart';
import 'package:luji_app/widgets/net_image.dart';
import 'package:luji_app/widgets/section_header.dart';

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

  // 加载详情
  Future<void> _loadDetail() async {
    try {
      final result = await Api().get(
        'spot_detail',
        queryParameters: {'rid': widget.rid},
      );
      if (!mounted) return;
      if (result['success'] && result['data'] != null) {
        setState(() {
          _spot = Spot.fromJson(Map<String, dynamic>.from(result['data']));
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

  // 加载点评
  Future<void> _loadReviews() async {
    try {
      final result = await Api().get(
        'spot_reviews',
        queryParameters: {'rid': widget.rid},
      );
      if (!mounted) return;
      if (result['success'] && result['data'] is List) {
        setState(() {
          for (final item in result['data']) {
            _reviews.add(Map<String, dynamic>.from(item));
          }
        });
      }
    } catch (e) {
      LogUtil.e('钓点点评加载失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
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
            NetImage(url: spot.cover, height: 440.w, width: double.infinity),
            SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back,
                      size: 36.w, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        // 基础信息
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      spot.name ?? '',
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.star, size: 32.w, color: Constants.HIGHLIGHT_COLOR),
                  SizedBox(width: 4.w),
                  Text(
                    (spot.rating ?? 0).toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: Constants.HIGHLIGHT_COLOR,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.w),
              Row(
                children: [
                  Icon(Icons.place, size: 30.w, color: Constants.TEXT_LIGHT_COLOR),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      spot.address ?? '',
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24.w),
        // 常见鱼种
        if (spot.fish_names != null && spot.fish_names!.isNotEmpty)
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: '常见鱼种'),
                Padding(
                  padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 32.w),
                  child: Wrap(
                    spacing: 16.w,
                    runSpacing: 16.w,
                    children: spot.fish_names!
                        .map(
                          (name) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 12.w),
                            decoration: BoxDecoration(
                              color: Constants.PRIMARY_COLOR
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(32.w),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 26.sp,
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
        SizedBox(height: 24.w),
        // 收费/开放时间
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              _buildInfoRow(Icons.paid_outlined, '收费说明', spot.fee ?? '免费'),
              SizedBox(height: 24.w),
              _buildInfoRow(Icons.schedule_outlined, '开放时间', spot.open_time ?? '全天'),
              if (spot.description != null) ...[
                SizedBox(height: 24.w),
                _buildInfoRow(Icons.info_outline, '详细介绍', spot.description!),
              ],
            ],
          ),
        ),
        SizedBox(height: 24.w),
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
                      height: 200.w,
                      child: const EmptyWidget(text: '还没有点评，钓过就来评价吧'),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 32.w),
                      child: Column(
                        children: _reviews.map(_buildReviewItem).toList(),
                      ),
                    ),
            ],
          ),
        ),
        SizedBox(height: 48.w),
      ],
    );
  }

  // 信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 32.w, color: Constants.PRIMARY_COLOR),
        SizedBox(width: 16.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 26.sp,
            color: Constants.TEXT_SECONDARY_COLOR,
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 26.sp,
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
      margin: EdgeInsets.only(bottom: 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Constants.BG_COLOR,
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetImage(
                url: review['user']?['avatar'],
                width: 56.w,
                height: 56.w,
                borderRadius: 28.w,
              ),
              SizedBox(width: 16.w),
              Text(
                review['user']?['nickname'] ?? '钓友',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                review['created_at'] ?? '',
                style: TextStyle(
                  fontSize: 22.sp,
                  color: Constants.TEXT_LIGHT_COLOR,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.w),
          Text(
            review['content'] ?? '',
            style: TextStyle(
              fontSize: 26.sp,
              color: Constants.TEXT_DEFAULT_COLOR,
            ),
          ),
        ],
      ),
    );
  }
}

