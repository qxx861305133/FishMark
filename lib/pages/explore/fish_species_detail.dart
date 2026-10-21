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

  // 加载详情补充
  Future<void> _loadDetail() async {
    if (_species.rid == null) return;
    try {
      final result = await Api().get(
        'fish_species_detail',
        queryParameters: {'rid': _species.rid},
      );
      if (!mounted) return;
      if (result['success'] && result['data'] != null) {
        setState(() {
          _species = FishSpecies.fromJson(
            Map<String, dynamic>.from(result['data']),
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
                height: 440.w,
                width: double.infinity,
              ),
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
                Text(
                  unlocked ? (species.name ?? '未知鱼种') : '？？？',
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unlocked && species.alias != null) ...[
                  SizedBox(height: 8.w),
                  Text(
                    '别名：${species.alias}',
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Constants.TEXT_SECONDARY_COLOR,
                    ),
                  ),
                ],
                SizedBox(height: 24.w),
                // 属性标签
                Row(
                  children: [
                    _buildTag(_habitatLabel(species.habitat),
                        Constants.PRIMARY_COLOR),
                    SizedBox(width: 16.w),
                    _buildTag(
                        _difficultyLabel(species.difficulty),
                        Constants.HIGHLIGHT_COLOR),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.w),
          // 钓法信息
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(32.w),
            child: Column(
              children: [
                _buildInfoRow(Icons.phishing, '推荐拟饵',
                    unlocked ? (species.bait ?? '暂无推荐') : '解锁后查看'),
                SizedBox(height: 24.w),
                _buildInfoRow(Icons.calendar_month_outlined, '最佳季节',
                    unlocked ? (species.season ?? '全年可钓') : '解锁后查看'),
              ],
            ),
          ),
          SizedBox(height: 24.w),
          // 介绍与解锁记录
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '鱼种介绍',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.w),
                Text(
                  unlocked
                      ? (species.description ?? '暂无介绍')
                      : '钓获该鱼种后即可解锁完整图鉴信息',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                    height: 1.6,
                  ),
                ),
                if (unlocked && species.unlocked_at != null) ...[
                  SizedBox(height: 32.w),
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            size: 36.w, color: Constants.HIGHLIGHT_COLOR),
                        SizedBox(width: 12.w),
                        Text(
                          '首次解锁：${species.unlocked_at}',
                          style: TextStyle(
                            fontSize: 24.sp,
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
          SizedBox(height: 48.w),
        ],
      ),
    );
  }

  // 信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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

  // 属性标签
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24.sp,
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
