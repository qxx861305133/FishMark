import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/catch_record.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 鱼种详情页：图鉴信息 + 推荐饵 + 首次解锁记录
class FishSpeciesDetailPage extends StatefulWidget {
  // 鱼种对象（列表传入，详情补充）
  final FishSpecies species;

  const FishSpeciesDetailPage({super.key, required this.species});

  @override
  State<FishSpeciesDetailPage> createState() => _FishSpeciesDetailPageState();
}

class _FishSpeciesDetailPageState extends State<FishSpeciesDetailPage> {
  late FishSpecies _species;

  @override
  void initState() {
    super.initState();
    _species = widget.species;
    _loadDetail();
  }

  // 加载详情补充：GET /fish-species/{species_id}
  Future<void> _loadDetail() async {
    if (_species.rid == null) return;
    try {
      final result = await Api().get(
        'fish_species_detail',
        queryParameters: {'species_id': _species.rid},
      );
      if (!mounted) return;
      if (result['success'] == true && result['data'] != null) {
        final data = Map<String, dynamic>.from(result['data']);
        final item = data['species'] ?? data;
        setState(() {
          _species = FishSpecies.fromApi(
            Map<String, dynamic>.from(item),
          );
        });
      }
    } catch (e) {
      LogUtil.e('鱼种详情加载失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final species = _species;
    final unlocked = species.unlocked == true;
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 封面
          Stack(
            children: [
              NetImage(
                url: unlocked ? species.cover : null,
                height: 220.w,
                width: double.infinity,
              ),
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
                Text(
                  unlocked ? (species.name ?? '未知鱼种') : '？？？',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unlocked && species.alias != null) ...[
                  SizedBox(height: 4.w),
                  Text(
                    '别名：${species.alias}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Constants.TEXT_SECONDARY_COLOR,
                    ),
                  ),
                ],
                SizedBox(height: 12.w),
                // 属性标签
                Row(
                  children: [
                    _buildTag(_habitatLabel(species.habitat),
                        Constants.PRIMARY_COLOR),
                    // 难度：服务端暂未提供该字段，有值才展示
                    if (species.difficulty != null) ...[
                      SizedBox(width: 8.w),
                      _buildTag(
                          _difficultyLabel(species.difficulty),
                          Constants.HIGHLIGHT_COLOR),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.w),
          // 钓法信息
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildInfoRow(Icons.phishing, '推荐拟饵',
                    unlocked ? (species.bait ?? '暂无推荐') : '解锁后查看'),
                SizedBox(height: 12.w),
                _buildInfoRow(Icons.calendar_month_outlined, '最佳季节',
                    unlocked ? (species.season ?? '全年可钓') : '解锁后查看'),
              ],
            ),
          ),
          SizedBox(height: 12.w),
          // 介绍与解锁记录
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '鱼种介绍',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.w),
                Text(
                  unlocked
                      ? (species.description ?? '暂无介绍')
                      : '钓获该鱼种后即可解锁完整图鉴信息',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                    height: 1.6,
                  ),
                ),
                if (unlocked && species.unlocked_at != null) ...[
                  SizedBox(height: 16.w),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            size: 18.w, color: Constants.HIGHLIGHT_COLOR),
                        SizedBox(width: 6.w),
                        Text(
                          '首次解锁：${species.unlocked_at}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Constants.HIGHLIGHT_COLOR,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24.w),
        ],
      ),
    );
  }

  // 信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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

  // 属性标签
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 栖息地文案
  String _habitatLabel(String? habitat) {
    const map = {
      'river': '江河',
      'lake': '湖泊',
      'reservoir': '水库',
      'sea': '海钓',
    };
    return map[habitat] ?? '淡水';
  }

  // 难度文案
  String _difficultyLabel(String? difficulty) {
    const map = {'easy': '难度 易', 'medium': '难度 中', 'hard': '难度 难'};
    return map[difficulty] ?? '难度 未知';
  }
}
