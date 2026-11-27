import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/challenge.dart';
import 'package:FishMark/widgets/empty_widget.dart';
import 'package:FishMark/widgets/medal_badge.dart';

/// @desc 勋章墙页：按稀有度分组展示
class MedalWallPage extends StatefulWidget {
  const MedalWallPage({super.key});

  @override
  State<MedalWallPage> createState() => _MedalWallPageState();
}

class _MedalWallPageState extends State<MedalWallPage> {
  final List<Medal> _medals = [];
  bool _loading = true;

  // 稀有度分组展示顺序
  static const List<String> _rarityOrder = ['legend', 'epic', 'rare', 'common'];
  static const Map<String, String> _rarityNames = {
    'legend': '传说',
    'epic': '史诗',
    'rare': '稀有',
    'common': '普通',
  };

  @override
  void initState() {
    super.initState();
    _loadMedals();
  }

  Future<void> _loadMedals() async {
    try {
      // GET /users/me/badges：data 为 {badges: [...], total, pages} 嵌套结构
      final result = await Api().get('user_badges', queryParameters: {
        'page': 1,
        'per_page': 100,
      });
      if (!mounted) return;
      if (result['success'] == true && result['data'] != null) {
        final data = Map<String, dynamic>.from(result['data']);
        final items = data['badges'] ?? [];
        setState(() {
          _loading = false;
          _medals.clear();
          if (items is List) {
            for (final item in items) {
              _medals.add(Medal.fromApi(Map<String, dynamic>.from(item)));
            }
          }
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('勋章列表加载失败: $e');
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
        title: Text('勋章墙', style: TextStyle(fontSize: 17.sp)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _medals.isEmpty
              ? const EmptyWidget(text: '还没有解锁勋章，快去完成挑战吧',
                  icon: Icons.military_tech)
              : RefreshIndicator(
                  onRefresh: _loadMedals,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 80.w),
                    children:
                        _rarityOrder.map((rarity) => _buildGroup(rarity)).toList(),
                  ),
                ),
    );
  }

  // 按稀有度分组
  Widget _buildGroup(String rarity) {
    final medals = _medals.where((m) => m.rarity == rarity).toList();
    if (medals.isEmpty) return SizedBox(height: 4.w);
    final unlockedCount =
        medals.where((m) => m.unlocked == true).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.w),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 16.w,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: Constants.MEDAL_RARITY_COLORS[rarity],
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              Text(
                '${_rarityNames[rarity]}勋章',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '$unlockedCount/${medals.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Constants.TEXT_LIGHT_COLOR,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12.w,
              childAspectRatio: 0.75,
            ),
            itemCount: medals.length,
            itemBuilder: (context, index) {
              final medal = medals[index];
              return GestureDetector(
                onTap: () => _showMedalDetail(medal),
                child: MedalBadge(
                  rarity: medal.rarity ?? 'common',
                  name: medal.unlocked == true
                      ? (medal.name ?? '')
                      : '？？？',
                  icon: Icons.workspace_premium_outlined,
                  unlocked: medal.unlocked == true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 勋章详情弹窗
  void _showMedalDetail(Medal medal) {
    final unlocked = medal.unlocked == true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MedalBadge(
              rarity: medal.rarity ?? 'common',
              name: medal.name ?? '',
              icon: Icons.workspace_premium_outlined,
              unlocked: unlocked,
            ),
            SizedBox(height: 12.w),
            Text(
              medal.description ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Constants.TEXT_SECONDARY_COLOR,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8.w),
            if (!unlocked && medal.condition != null)
              Text(
                '解锁条件：${medal.condition}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Constants.TEXT_LIGHT_COLOR,
                ),
              ),
            if (unlocked && medal.unlocked_at != null)
              Text(
                '解锁于 ${medal.unlocked_at}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Constants.HIGHLIGHT_COLOR,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '知道了',
              style: TextStyle(
                fontSize: 14.sp,
                color: Constants.PRIMARY_COLOR,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
