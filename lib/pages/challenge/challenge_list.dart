import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/challenge.dart';
import 'package:FishMark/pages/challenge/challenge_detail.dart';
import 'package:FishMark/widgets/empty_widget.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 挑战列表页
class ChallengeListPage extends StatefulWidget {
  const ChallengeListPage({super.key});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  final List<Challenge> _challenges = [];
  bool _loading = true;
  // 当前类型筛选
  String _type = 'all';

  static const Map<String, String> _typeMap = {
    'all': '全部',
    'daily': '日常',
    'weekly': '周常',
    'season': '赛季',
    'event': '活动',
  };

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    try {
      final result = await Api().get('challenges');
      if (!mounted) return;
      if (result['success'] && result['data'] is List) {
        setState(() {
          _loading = false;
          _challenges.clear();
          for (final item in result['data']) {
            _challenges.add(
              Challenge.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('挑战列表加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Challenge> get _filtered {
    if (_type == 'all') return _challenges;
    return _challenges.where((c) => c.type == _type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('挑战', style: TextStyle(fontSize: 34.sp)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 类型筛选
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 24.w),
                  child: SizedBox(
                    height: 72.w,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _typeMap.entries.map((entry) {
                        final selected = _type == entry.key;
                        return Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: selected,
                            selectedColor: Constants.PRIMARY_COLOR,
                            backgroundColor: Constants.BG_COLOR,
                            labelStyle: TextStyle(
                              fontSize: 26.sp,
                              color: selected
                                  ? Colors.white
                                  : Constants.TEXT_SECONDARY_COLOR,
                            ),
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => _type = entry.key),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const EmptyWidget(text: '暂无挑战，敬请期待',
                          icon: Icons.emoji_events_outlined)
                      : RefreshIndicator(
                          onRefresh: _loadChallenges,
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                                32.w, 24.w, 32.w, 160.w),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) =>
                                _buildChallengeCard(_filtered[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // 挑战卡片
  Widget _buildChallengeCard(Challenge challenge) {
    final progress = challenge.progress ?? 0;
    final target = challenge.target_count ?? 1;
    final ratio = (progress / target).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChallengeDetailPage(rid: challenge.rid),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NetImage(
                  url: challenge.cover,
                  width: 96.w,
                  height: 96.w,
                  borderRadius: 16.w,
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
                ),
                _buildStatusTag(challenge.status),
              ],
            ),
            SizedBox(height: 20.w),
            // 进度条
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 12.w,
                      backgroundColor: Constants.BG_COLOR,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ratio >= 1
                            ? Constants.HIGHLIGHT_COLOR
                            : Constants.PRIMARY_COLOR,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  '$progress/$target',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.w),
            // 奖励
            Row(
              children: [
                Icon(Icons.military_tech,
                    size: 28.w, color: Constants.HIGHLIGHT_COLOR),
                SizedBox(width: 4.w),
                Text(
                  '${challenge.reward?.name ?? '神秘勋章'} · +${challenge.points ?? 0}积分',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Constants.HIGHLIGHT_COLOR,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (challenge.end_at != null)
                  Text(
                    '截止 ${challenge.end_at}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: Constants.TEXT_LIGHT_COLOR,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 状态标签
  Widget _buildStatusTag(String? status) {
    String text;
    Color color;
    switch (status) {
      case 'doing':
        text = '进行中';
        color = Constants.PRIMARY_COLOR;
        break;
      case 'finished':
        text = '已完成';
        color = Constants.HIGHLIGHT_COLOR;
        break;
      case 'expired':
        text = '已过期';
        color = Constants.DISABLED_COLOR;
        break;
      default:
        text = '未参与';
        color = Constants.TEXT_LIGHT_COLOR;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
