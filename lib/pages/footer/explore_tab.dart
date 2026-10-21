import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/spot.dart';
import 'package:FishMark/pages/explore/spot_detail.dart';
import 'package:FishMark/pages/upload/spot_upload.dart';
import 'package:FishMark/widgets/empty_widget.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 探索Tab：钓点地图/列表 + 钓点卡片
class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  // 视图模式：map 地图 / list 列表
  String _viewMode = 'list';
  final List<Spot> _spots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    try {
      final result = await Api().get('spots');
      if (!mounted) return;
      setState(() => _loading = false);
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          setState(() {
            _spots.clear();
            for (final item in data) {
              _spots.add(Spot.fromJson(Map<String, dynamic>.from(item)));
            }
          });
        }
      }
    } catch (e) {
      LogUtil.e('钓点列表加载失败: $e');
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
        title: Text(
          '探索钓点',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            color: Constants.TEXT_DEFAULT_COLOR,
          ),
        ),
        actions: [
          // 上传钓点
          TextButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SpotUploadPage()),
              );
              _loadSpots();
            },
            icon: Icon(Icons.add_location_alt_outlined,
                size: 36.w, color: Constants.PRIMARY_COLOR),
            label: Text(
              '上传钓点',
              style: TextStyle(
                fontSize: 26.sp,
                color: Constants.PRIMARY_COLOR,
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Column(
        children: [
          // 地图/列表切换
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.w),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'list',
                        icon: Icon(Icons.list),
                        label: Text('列表'),
                      ),
                      ButtonSegment(
                        value: 'map',
                        icon: Icon(Icons.map_outlined),
                        label: Text('地图'),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (selection) {
                      setState(() => _viewMode = selection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _viewMode == 'list'
                    ? _buildSpotList()
                    : _buildMapPlaceholder(),
          ),
        ],
      ),
    );
  }

  // 钓点列表
  Widget _buildSpotList() {
    if (_spots.isEmpty) {
      return const EmptyWidget(text: '附近暂无钓点，去上传一个吧');
    }
    return RefreshIndicator(
      onRefresh: _loadSpots,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(32.w, 24.w, 32.w, 160.w),
        itemCount: _spots.length,
        itemBuilder: (context, index) => _buildSpotCard(_spots[index]),
      ),
    );
  }

  // 地图占位（后续接入高德/腾讯地图SDK）
  Widget _buildMapPlaceholder() {
    return Stack(
      children: [
        Container(
          color: Constants.BG_COLOR,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined,
                    size: 120.w, color: Constants.PRIMARY_COLOR),
                SizedBox(height: 24.w),
                Text(
                  '钓点地图',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w600,
                    color: Constants.TEXT_DEFAULT_COLOR,
                  ),
                ),
                SizedBox(height: 8.w),
                Text(
                  '${_spots.length} 个钓点已收录',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 钓点聚合点位浮层
        ..._spots.take(5).map((spot) => Positioned(
              left: (spot.lat ?? 0).abs() % 300 + 40,
              top: (spot.lng ?? 0).abs() % 400 + 80,
              child: GestureDetector(
                onTap: () => _goDetail(spot),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12.w,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on,
                          size: 28.w, color: Constants.PRIMARY_COLOR),
                      SizedBox(width: 8.w),
                      Text(
                        spot.name ?? '',
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  // 钓点卡片
  Widget _buildSpotCard(Spot spot) {
    return GestureDetector(
      onTap: () => _goDetail(spot),
      child: Container(
        margin: EdgeInsets.only(bottom: 24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NetImage(
                  url: spot.cover,
                  height: 280.w,
                  width: double.infinity,
                  borderRadius: 0,
                ),
                Positioned(
                  right: 20.w,
                  top: 20.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(24.w),
                    ),
                    child: Text(
                      _spotTypeLabel(spot.type),
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spot.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.star,
                          size: 30.w, color: Constants.HIGHLIGHT_COLOR),
                      SizedBox(width: 4.w),
                      Text(
                        (spot.rating ?? 0).toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: Constants.HIGHLIGHT_COLOR,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.w),
                  Row(
                    children: [
                      Icon(Icons.place,
                          size: 28.w, color: Constants.TEXT_LIGHT_COLOR),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          spot.address ?? '暂无地址信息',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: Constants.TEXT_SECONDARY_COLOR,
                          ),
                        ),
                      ),
                      if (spot.distance != null) ...[
                        SizedBox(width: 16.w),
                        Text(
                          '${spot.distance}km',
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: Constants.TEXT_LIGHT_COLOR,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 12.w),
                  // 常见鱼种标签
                  if (spot.fish_names != null &&
                      spot.fish_names!.isNotEmpty)
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.w,
                      children: spot.fish_names!
                          .take(4)
                          .map(
                            (name) => Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 6.w),
                              decoration: BoxDecoration(
                                color: Constants.PRIMARY_COLOR
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  color: Constants.PRIMARY_COLOR,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 钓点类型文案
  String _spotTypeLabel(String? type) {
    const map = {
      'river': '江河',
      'lake': '湖泊',
      'reservoir': '水库',
      'sea': '海钓',
      'pond': '黑坑',
    };
    return map[type] ?? '野钓';
  }

  // 去详情
  void _goDetail(Spot spot) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpotDetailPage(rid: spot.rid),
      ),
    );
  }
}

