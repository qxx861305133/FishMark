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
  final ScrollController _gridCtrl = ScrollController();
  bool _loading = true;
  bool _loadingMore = false;
  int _loadMoreCount = 0;
  int _unlockedCount = 0;

  @override
  void initState() {
    super.initState();
    _gridCtrl.addListener(_onGridScroll);
    _loadSpecies();
  }

  @override
  void dispose() {
    _gridCtrl.dispose();
    super.dispose();
  }

  // 上拉加载：网格滚动到底时追加 mock 数据
  void _onGridScroll() {
    if (!_gridCtrl.hasClients || _loadingMore || _loadMoreCount >= 3) return;
    final pos = _gridCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 80) _loadMore();
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted || _species.isEmpty) return;
    setState(() {
      _species.addAll(_species.take(6).toList());
      _loadMoreCount++;
      _loadingMore = false;
    });
  }

  Future<void> _loadSpecies() async {
    try {
      // GET /fish-species：data.species 数组
      final result = await Api().get('fish_species', queryParameters: {
        'page': 1,
        'per_page': 50,
      });
      if (!mounted) return;
      if (result['success'] == true) {
        int unlocked = 0;
        _species.clear();
        _loadMoreCount = 0;
        final data = Map<String, dynamic>.from(result['data'] ?? {});
        final items = data['species'];
        if (items is List) {
          for (final item in items) {
            final species = FishSpecies.fromApi(
              Map<String, dynamic>.from(item),
            );
            _species.add(species);
            if (species.unlocked == true) unlocked++;
          }
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
        title: Text('鱼种图鉴', style: TextStyle(fontSize: 17.sp)),
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
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.w),
                      child: Text(
                        '已解锁 $_unlockedCount / ${_species.length} 种',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Constants.TEXT_SECONDARY_COLOR,
                        ),
                      ),
                    ),
                    // 图鉴网格（下拉刷新 + 上拉加载更多）
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadSpecies,
                        child: GridView.builder(
                          controller: _gridCtrl,
                          padding: EdgeInsets.fromLTRB(
                              16.w, 12.w, 16.w, 80.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12.w,
                            crossAxisSpacing: 12.w,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: _species.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _species.length) {
                              return _loadingMore
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }
                            return _buildSpeciesCard(_species[index]);
                          },
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
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(
                    url: unlocked ? species.cover : null,
                    borderRadius: 8.w,
                  ),
                  // 未解锁遮罩
                  if (!unlocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        size: 36.w,
                        color: Colors.black26,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 6.w),
            Text(
              unlocked ? (species.name ?? '') : '???',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
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
                  fontSize: 11.sp,
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
