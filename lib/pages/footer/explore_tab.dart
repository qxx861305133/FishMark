import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/explore_data.dart';
import 'package:FishMark/pages/explore/fish_guide_page.dart';
import 'package:FishMark/utils/location_permission_util.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/tdt_tile_layers.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 2.1.1 探索 - 地图模式（高德地图）/ 2.1.2 探索 - 列表模式 / 2.1.3 探索 - 地图详情

// 地图色板（取色自设计稿）
const Color _kMapBg = Color(0xFFE6E8EB);
const Color _kPinGreen = Color(0xFF32C43A);

enum _ExploreMode { map, detail }

/// 地图初始中心（杭州，与 mock 钓点区域一致）
const LatLng _kMapCenter = LatLng(30.19, 120.10);

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with WidgetsBindingObserver {
  _ExploreMode _mode = _ExploreMode.map;
  ExploreSpot? _selected;

  static const Color _iconMuted = Color(0xFFC6CFDA);
  static const Color _starMuted = Color(0xFFDEE3EE);

  bool _starred = false;

  // 底部面板两种状态：收起（地图统计）/ 展开（钓点列表），支持手势拖拽
  bool _expanded = false;
  double? _dragH; // 拖拽中的实时高度（非空时关闭动画跟手）
  double _dragBase = 0;
  double _collapsedH = 158;
  double _expandedH = 400;
  bool _loadingMore = false;
  int _loadMoreCount = 0;
  final ScrollController _listCtrl = ScrollController();
  MapController? _mapCtrl;
  bool _satellite = false; // 底图样式：普通/卫星
  LatLng? _userLatLng; // 当前定位坐标

  // mock x/y（0~1）映射到中心附近的经纬度
  LatLng _spotLatLng(ExploreSpot spot) {
    return LatLng(
      _kMapCenter.latitude + (0.5 - spot.y) * 0.08,
      _kMapCenter.longitude + (spot.x - 0.5) * 0.12,
    );
  }

  // 钓点标点（设计稿样式：白底 + 绿色圆环，Flutter Widget Marker）
  List<Marker> _buildMarkers() {
    return [
      for (var i = 0; i < exploreSpots.length; i++)
        Marker(
          point: _spotLatLng(exploreSpots[i]),
          width: 22.w,
          height: 22.w,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _openDetail(exploreSpots[i]),
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6.w,
                  ),
                ],
              ),
              padding: EdgeInsets.all(3.w),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kPinGreen, width: 3.5.w),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listCtrl.addListener(_onListScroll);
    // 进入地图页申请定位权限，授权通过后获取当前位置
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await ensureLocationPermission(context);
      if (ok && mounted) _fetchUserLocation();
    });
  }

  // 从系统设置页返回 App 时，自动刷新授权状态（开启定位后立即获取位置）
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      hasLocationPermission().then((ok) {
        if (ok && mounted && _userLatLng == null) {
          _fetchUserLocation();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _listCtrl.dispose();
    super.dispose();
  }

  // 上拉加载：滚动到列表底部时追加 mock 数据
  void _onListScroll() {
    if (!_listCtrl.hasClients || _loadingMore || _loadMoreCount >= 5) return;
    final pos = _listCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 60) _loadMore();
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      exploreSpots.addAll(makeMoreSpots(exploreSpots.length, 4));
      _loadMoreCount++;
      _loadingMore = false;
    });
  }

  // 下拉刷新：重置 mock 数据
  Future<void> _refreshSpots() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      resetExploreSpots();
      _loadMoreCount = 0;
      _loadingMore = false;
    });
  }

  // 把手拖拽：跟手改变面板高度
  void _onHandleDragStart(DragStartDetails d) {
    _dragBase = _dragH ?? (_expanded ? _expandedH : _collapsedH);
  }

  void _onHandleDragUpdate(DragUpdateDetails d) {
    final double nh =
        (_dragBase - d.delta.dy).clamp(_collapsedH, _expandedH);
    setState(() => _dragH = nh);
  }

  void _onHandleDragEnd(DragEndDetails d) {
    final double v = d.primaryVelocity ?? 0;
    final double cur = _dragH ?? (_expanded ? _expandedH : _collapsedH);
    final bool expand;
    if (v < -300) {
      expand = true;
    } else if (v > 300) {
      expand = false;
    } else {
      expand = cur > (_collapsedH + _expandedH) / 2;
    }
    setState(() {
      _dragH = null;
      _expanded = expand;
    });
  }

  void _openDetail(ExploreSpot spot) {
    setState(() {
      _selected = spot;
      _starred = false;
      _mode = _ExploreMode.detail;
    });
  }

  void _openFishGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FishGuidePage()),
    );
  }

  // 地图缩放
  void _zoomBy(double delta) {
    final ctrl = _mapCtrl;
    if (ctrl == null) return;
    ctrl.move(
      ctrl.camera.center,
      (ctrl.camera.zoom + delta).clamp(3.0, 18.0),
    );
  }

  // 获取当前位置（含定位蓝点展示）并移动相机
  Future<void> _fetchUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() {
        _userLatLng = LatLng(pos.latitude, pos.longitude);
      });
      final ctrl = _mapCtrl;
      if (ctrl != null) {
        ctrl.move(_userLatLng!, 15);
      }
    } catch (_) {
      if (mounted) {
        Fluttertoast.showToast(msg: '定位失败，请稍后重试');
      }
    }
  }

  // 定位按钮：申请权限 → 获取当前位置 → 移动相机
  Future<void> _locateUser() async {
    final ok = await ensureLocationPermission(context);
    if (!ok) return;
    await _fetchUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: _kMapBg,
      body: LayoutBuilder(builder: (context, cons) {
        final double h = cons.maxHeight;
        final double collapsed = 158.w;
        final double expanded = h - 147.w;
        _collapsedH = collapsed;
        _expandedH = expanded;
        final double sheetH = _mode == _ExploreMode.detail
            ? h - 251.w
            : (_dragH ?? (_expanded ? expanded : collapsed));
        return Stack(
          children: [
            // 天地图 + flutter_map（点击地图退出详情）
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapCtrl ??= MapController(),
                options: MapOptions(
                  initialCenter: _kMapCenter,
                  initialZoom: 15, // 街道级，拖动幅度与设计稿一致
                  minZoom: 3,
                  maxZoom: 18,
                  onTap: (_, __) {
                    if (_mode == _ExploreMode.detail) {
                      setState(() => _mode = _ExploreMode.map);
                    }
                  },
                ),
                children: [
                  ...tdtTileLayers(satellite: _satellite),
                  // 当前位置（绿点）
                  if (_userLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLatLng!,
                          width: 14.w,
                          height: 14.w,
                          alignment: Alignment.center,
                          child: Container(
                            width: 14.w,
                            height: 14.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _kPinGreen,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // 附近钓点标点
                  MarkerLayer(markers: _buildMarkers()),
                ],
              ),
            ),
            // 左上角鱼种图鉴入口
            Positioned(
              left: 16.w,
              top: topPadding + 10.w,
              child: _FishGuideEntry(onTap: _openFishGuide),
            ),
            // 右侧缩放/定位控件（面板展开时隐藏）
            Positioned(
              right: 16.w,
              bottom: (_mode == _ExploreMode.detail ? h - 251.w : collapsed) +
                  8.w,
              child: IgnorePointer(
                ignoring: _expanded,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _expanded ? 0 : 1,
                  child: Column(
                    children: [
                      _ZoomCard(
                        onZoomIn: () => _zoomBy(1),
                        onZoomOut: () => _zoomBy(-1),
                      ),
                      SizedBox(height: 18.w),
                      _CircleIconButton(
                        size: 40.w,
                        icon: RemixIcons.focus_2_line,
                        onTap: _locateUser,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 底部面板（上滑可拖起展开成钓点列表）
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: _dragH != null
                    ? Duration.zero
                    : const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                height: sheetH,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: _mode == _ExploreMode.detail
                      ? Constants.INPUT_BG
                      : Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20.w,
                      offset: Offset(0, -4.w),
                    ),
                  ],
                ),
                child: _mode == _ExploreMode.detail
                    ? _buildDetailSheet()
                    : _buildMapSheet(),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ===== 2.1.1/2.1.2 底部面板：把手 + 统计（上滑展开）+ 钓点列表 =====
  Widget _buildMapSheet() {
    return Column(
      children: [
        // 把手 + 统计：点按切换展开，上滑拖拽跟手
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          onVerticalDragStart: _onHandleDragStart,
          onVerticalDragUpdate: _onHandleDragUpdate,
          onVerticalDragEnd: _onHandleDragEnd,
          child: Column(
            children: [
              SizedBox(height: 10.w),
              const _DragHandle(),
              SizedBox(height: 10.w),
              _buildStatsRow(),
            ],
          ),
        ),
        // 展开后显示钓点列表（下拉刷新 + 上拉加载更多）
        Expanded(
          child: (_expanded || _dragH != null)
              ? _buildSpotList()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // 钓点列表：RefreshIndicator + 滚动到底追加 mock 数据
  Widget _buildSpotList() {
    return Column(
      children: [
        SizedBox(height: 12.w),
        Container(height: 0.5, color: Constants.BORDER),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshSpots,
            child: ListView.separated(
              controller: _listCtrl,
              padding: EdgeInsets.only(bottom: 24.w),
              itemCount: exploreSpots.length + 1,
              separatorBuilder: (_, _) => Container(
                height: 0.5,
                color: Constants.BORDER,
              ),
              itemBuilder: (context, index) {
                if (index == exploreSpots.length) {
                  return _loadingMore
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.w),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }
                return _buildSpotRow(exploreSpots[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  // 统计行：184 附近水域 / 26 附近钓点 / 109 附近渔获
  Widget _buildStatsRow() {
    final items = [
      ('${exploreStats.waters}', '附近水域'),
      ('${exploreStats.spots}', '附近钓点'),
      ('${exploreStats.catches}', '附近渔获'),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        children: [
          for (final (value, label) in items)
            Expanded(
              child: Column(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 25.sp,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Constants.INK,
                    ),
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Constants.GRAY,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 钓点列表行
  Widget _buildSpotRow(ExploreSpot spot) {
    return InkWell(
      onTap: () => _openDetail(spot),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NetImage(url: spot.thumb, width: 80.w, height: 80.w, borderRadius: 12),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Constants.INK,
                    ),
                  ),
                  SizedBox(height: 6.w),
                  Text(
                    spot.areaLabel,
                    style: TextStyle(fontSize: 12.sp, color: Constants.GRAY),
                  ),
                  SizedBox(height: 8.w),
                  Row(
                    children: [
                      for (final tag in spot.tags)
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _FishTag(text: tag),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(RemixIcons.arrow_right_s_line,
                size: 22.w, color: _iconMuted),
          ],
        ),
      ),
    );
  }

  // ===== 2.1.3 地图详情面板：内容滚动，打卡记录按钮固定底部 =====
  Widget _buildDetailSheet() {
    final spot = _selected ?? exploreSpots.first;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSpotHeaderCard(spot),
                SizedBox(height: 12.w),
                _buildFishCard(spot),
                SizedBox(height: 12.w),
                _buildRecordCard(spot),
              ],
            ),
          ),
        ),
        // 固定在底部的打卡记录按钮（不随内容滚动）
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.w, 16.w, 16.w),
          child: InkButton(
            text: '打卡记录',
            height: 44,
            onPressed: () => Fluttertoast.showToast(msg: '演示数据，敬请期待'),
          ),
        ),
      ],
    );
  }

  // 钓点信息卡
  Widget _buildSpotHeaderCard(ExploreSpot spot) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: _kMapBg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: const CustomPaint(
                painter: _MiniMapPainter(),
                child: SizedBox.expand(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Constants.INK,
                  ),
                ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    if (spot.badge != null) ...[
                      Container(
                        height: 22.w,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Constants.LIME,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          spot.badge!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Constants.INK,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        spot.areaLabel,
                        style: TextStyle(
                            fontSize: 12.sp, color: Constants.GRAY),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => setState(() => _starred = !_starred),
            child: Icon(
              RemixIcons.star_fill,
              size: 22.w,
              color: _starred ? Constants.LIME : _starMuted,
            ),
          ),
        ],
      ),
    );
  }

  // 常见鱼种卡（点击鱼种进入鱼种图鉴）
  Widget _buildFishCard(ExploreSpot spot) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '常见鱼种',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Constants.INK,
            ),
          ),
          SizedBox(height: 12.w),
          SizedBox(
            height: 96.w,
            child: Row(
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: spot.tags.length,
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) => _FishTile(
                      name: spot.tags[index],
                      image:
                          'https://picsum.photos/seed/lj-fish-${index + 1}/240/200',
                      onTap: _openFishGuide,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 渔获记录卡
  Widget _buildRecordCard(ExploreSpot spot) {
    final record = spot.record;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetImage(
                url: record.avatar,
                width: 26.w,
                height: 26.w,
                borderRadius: 13,
              ),
              SizedBox(width: 8.w),
              Text(
                record.user,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.INK,
                ),
              ),
              const Spacer(),
              Text(
                '${record.date} 记录',
                style: TextStyle(fontSize: 12.sp, color: Constants.GRAY_LIGHT),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          Stack(
            children: [
              NetImage(url: record.photo, width: double.infinity, height: 142.w, borderRadius: 12),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                bottom: 12.w,
                child: Text(
                  record.fishName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 16.w,
                bottom: 8.w,
                child: Text(
                  record.weight,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: Constants.LIME,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Engagement(icon: RemixIcons.heart_line, label: '2,580'),
              SizedBox(width: 36.w),
              _Engagement(icon: RemixIcons.chat_1_line, label: '224'),
              SizedBox(width: 36.w),
              _Engagement(icon: RemixIcons.share_forward_line, label: '分享'),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== 通用小部件 =====

/// 拖拽把手
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 4.w,
      decoration: BoxDecoration(
        color: Constants.BORDER,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

/// 鱼种标签（列表）
class _FishTag extends StatelessWidget {
  final String text;

  const _FishTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE4EBE6),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF21582F),
        ),
      ),
    );
  }
}

/// 鱼种瓷片（详情 - 常见鱼种）
class _FishTile extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback? onTap;

  const _FishTile({required this.name, required this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70.w,
        child: Column(
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Constants.INPUT_BG,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: NetImage(url: image, width: 54.w, height: 54.w, borderRadius: 8),
            ),
            SizedBox(height: 8.w),
            Text(
              name,
              style: TextStyle(fontSize: 12.sp, color: Constants.INK),
            ),
          ],
        ),
      ),
    );
  }
}

/// 互动数据（点赞/评论/分享）
class _Engagement extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Engagement({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.w, color: const Color(0xFFC0C4CC)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFFC0C4CC)),
        ),
      ],
    );
  }
}

/// 左上角鱼种图鉴入口卡片
class _FishGuideEntry extends StatelessWidget {
  final VoidCallback? onTap;

  const _FishGuideEntry({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 101.w,
        padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16.w,
              offset: Offset(0, 4.w),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Constants.LIME,
                  ),
                ),
                NetImage(
                  url: 'https://picsum.photos/seed/lj-fish-guide/160/160',
                  width: 42.w,
                  height: 42.w,
                  borderRadius: 21,
                ),
              ],
            ),
            SizedBox(height: 8.w),
            Text(
              '鱼种图鉴',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Constants.INK,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 缩放控件（+ / −）
class _ZoomCard extends StatelessWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  const _ZoomCard({this.onZoomIn, this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.w,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onZoomIn,
              child: Icon(RemixIcons.add_line, size: 20.w, color: Constants.INK),
            ),
          ),
          Container(width: 24.w, height: 0.5, color: Constants.BORDER),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onZoomOut,
              child: Icon(RemixIcons.subtract_line,
                  size: 20.w, color: Constants.INK),
            ),
          ),
        ],
      ),
    );
  }
}

/// 圆形操作按钮（定位）
class _CircleIconButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.size,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12.w,
            ),
          ],
        ),
        child: Icon(icon, size: 20.w, color: Constants.INK),
      ),
    );
  }
}

/// 详情卡左上角小地图缩略图
class _MiniMapPainter extends CustomPainter {
  const _MiniMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = _kMapBg);

    // 水系斜带
    canvas.drawLine(
      Offset(-4, h * 0.75),
      Offset(w * 0.55, h * 1.05),
      Paint()
        ..color = const Color(0xFFACD4F4)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    // 道路
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.72, -4), Offset(w * 0.95, h + 4), road);
    canvas.drawLine(Offset(-4, h * 0.30), Offset(w * 0.5, h * 0.18), road);
    // 中心绿色圆环 pin
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.42),
      7.5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.42),
      7.5,
      Paint()
        ..color = _kPinGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
