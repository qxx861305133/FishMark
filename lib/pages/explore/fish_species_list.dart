import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/catch_record.dart';
import 'package:FishMark/pages/explore/fish_species_detail.dart';
import 'package:FishMark/widgets/empty_widget.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 鱼种图鉴列表页（已解锁彩色 / 未解锁灰显）
class FishSpeciesListPage extends StatefulWidget {
  const FishSpeciesListPage({super.key});

  @override
  State<FishSpeciesListPage> createState() => _FishSpeciesListPageState();
}

class _FishSpeciesListPageState extends State<FishSpeciesListPage> {
  final List<FishSpecies> _species = [];
  bool _loading = true;
  int _unlockedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    try {
      final result = await Api().get('fish_species');
      if (!mounted) return;
      if (result['success'] && result['data'] is List) {
        int unlocked = 0;
        for (final item in result['data']) {
          final species = FishSpecies.fromJson(
            Map<String, dynamic>.from(item),
          );
          _species.add(species);
          if (species.unlocked == true) unlocked++;
        }
        setState(() {
          _unlockedCount = unlocked;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('鱼种图鉴加载失败: $e');
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
        title: Text('鱼种图鉴', style: TextStyle(fontSize: 34.sp)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _species.isEmpty
              ? const EmptyWidget(text: '图鉴收录中')
              : Column(
                  children: [
                    // 收集进度
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 24.w),
                      child: Text(
                        '已解锁 $_unlockedCount / ${_species.length} 种',
                        style: TextStyle(
                          fontSize: 26.sp,
                          color: Constants.TEXT_SECONDARY_COLOR,
                        ),
                      ),
                    ),
                    // 图鉴网格
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadSpecies,
                        child: GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                              32.w, 24.w, 32.w, 160.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 24.w,
                            crossAxisSpacing: 24.w,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: _species.length,
                          itemBuilder: (context, index) =>
                              _buildSpeciesCard(_species[index]),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // 图鉴卡片
  Widget _buildSpeciesCard(FishSpecies species) {
    final unlocked = species.unlocked == true;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FishSpeciesDetailPage(species: species),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(
                    url: unlocked ? species.cover : null,
                    borderRadius: 16.w,
                  ),
                  // 未解锁遮罩
                  if (!unlocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        size: 72.w,
                        color: Colors.black26,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12.w),
            Text(
              unlocked ? (species.name ?? '') : '???',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
                color: unlocked
                    ? Constants.TEXT_DEFAULT_COLOR
                    : Constants.TEXT_LIGHT_COLOR,
              ),
            ),
            if (unlocked && species.difficulty != null)
              Text(
                _difficultyLabel(species.difficulty),
                style: TextStyle(
                  fontSize: 22.sp,
                  color: Constants.TEXT_LIGHT_COLOR,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 难度文案
  String _difficultyLabel(String? difficulty) {
    const map = {'easy': '难度：易', 'medium': '难度：中', 'hard': '难度：难'};
    return map[difficulty] ?? '';
  }
}
