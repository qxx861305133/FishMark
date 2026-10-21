import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/pages/medal/medal_wall.dart';
import 'package:FishMark/widgets/empty_widget.dart';

/// @desc 数字履历页：数据总览 + 勋章入口 + 履历时间轴
class DigitalResumePage extends StatefulWidget {
  const DigitalResumePage({super.key});

  @override
  State<DigitalResumePage> createState() => _DigitalResumePageState();
}

class _DigitalResumePageState extends State<DigitalResumePage> {
  Map<String, dynamic> _overview = {};
  final List<Map<String, dynamic>> _timeline = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        Api().get('my_overview'),
        Api().get('my_timeline'),
      ]);
      if (!mounted) return;
      setState(() => _loading = false);
      // 总览
      if (results[0]['success'] && results[0]['data'] is Map) {
        setState(() {
          _overview = Map<String, dynamic>.from(results[0]['data']);
        });
      }
      // 时间轴
      if (results[1]['success'] && results[1]['data'] is List) {
        setState(() {
          _timeline.clear();
          for (final item in results[1]['data']) {
            _timeline.add(Map<String, dynamic>.from(item));
          }
        });
      }
    } catch (e) {
      LogUtil.e('数字履历加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('数字履历', style: TextStyle(fontSize: 34.sp)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(32.w, 24.w, 32.w, 160.w),
              children: [
                _buildStats(),
                SizedBox(height: 24.w),
                _buildMedalEntry(),
                SizedBox(height: 24.w),
                _buildTimeline(),
              ],
            ),
    );
  }

  // 数据总览
  Widget _buildStats() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Constants.PRIMARY_COLOR,
            Constants.PRIMARY_COLOR.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${_overview['catch_count'] ?? 0}', '鱼获总数'),
          _buildStatItem('${_overview['species_count'] ?? 0}', '解锁鱼种'),
          _buildStatItem('${_overview['medal_count'] ?? 0}', '获得勋章'),
          _buildStatItem('${_overview['challenge_count'] ?? 0}', '完成挑战'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // 勋章墙入口
  Widget _buildMedalEntry() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MedalWallPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
        ),
        child: Row(
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24.w),
              ),
              child: Icon(Icons.military_tech,
                  size: 48.w, color: Constants.HIGHLIGHT_COLOR),
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '我的勋章墙',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    '每一枚勋章都是一段故事',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Constants.TEXT_SECONDARY_COLOR,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 40.w, color: Constants.TEXT_LIGHT_COLOR),
          ],
        ),
      ),
    );
  }

  // 履历时间轴
  Widget _buildTimeline() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '钓鱼履历',
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 32.w),
          _timeline.isEmpty
              ? SizedBox(
                  height: 240.w,
                  child: const EmptyWidget(text: '还没有履历记录，开始你的第一钓吧'),
                )
              : Column(
                  children: List.generate(_timeline.length, (index) {
                    return _buildTimelineItem(
                      _timeline[index],
                      isFirst: index == 0,
                      isLast: index == _timeline.length - 1,
                    );
                  }),
                ),
        ],
      ),
    );
  }

  // 时间轴项
  Widget _buildTimelineItem(
    Map<String, dynamic> item, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 时间轴竖线 + 圆点
          SizedBox(
            width: 40.w,
            child: Column(
              children: [
                SizedBox(
                  width: 20.w,
                  height: isFirst ? 24.w : 24.w,
                ),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: _typeColor(item['type']),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3.w,
                      color: Constants.LINE_COLOR,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          // 内容
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.w),
                  if (item['description'] != null &&
                      item['description'].toString().isNotEmpty)
                    Text(
                      item['description'],
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  SizedBox(height: 8.w),
                  Text(
                    item['created_at'] ?? '',
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: Constants.TEXT_LIGHT_COLOR,
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

  // 事件类型颜色
  Color _typeColor(dynamic type) {
    switch (type) {
      case 'catch':
        return Constants.PRIMARY_COLOR;
      case 'medal':
        return Constants.HIGHLIGHT_COLOR;
      case 'challenge':
        return const Color.fromRGBO(124, 58, 237, 1.0);
      default:
        return Constants.TEXT_LIGHT_COLOR;
    }
  }
}
