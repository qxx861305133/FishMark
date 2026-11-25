import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/pages/upload/spot_info_page.dart';
import 'package:FishMark/utils/location_permission_util.dart';
import 'package:FishMark/utils/tdt_api.dart';
import 'package:FishMark/widgets/tdt_tile_layers.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 3.4.1 上传钓点（天地图选点：默认当前区域 + 关键词搜索联动地图）
const Color _kPinGreen = Color(0xFF32C43A); // 主色绿

class SpotMapPage extends StatefulWidget {
  const SpotMapPage({super.key});

  @override
  State<SpotMapPage> createState() => _SpotMapPageState();
}

class _SpotMapPageState extends State<SpotMapPage>
    with WidgetsBindingObserver {
  // 搜索联想结果（天地图地点搜索）
  List<TdtPoi> _results = [];
  // 当前选中的 POI（null 时用地图中心点坐标）
  TdtPoi? _selectedPoi;
  Timer? _debounce;
  bool _searching = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // 地图中心兜底（定位失败/未授权时：杭州双浦镇一带）
  static const LatLng _kFallbackCenter = LatLng(30.1713, 120.0900);
  LatLng? _userLatLng; // 当前定位坐标
  MapController? _mapCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 进入选点页申请定位权限，授权通过后获取当前位置并把地图移到当前区域
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await ensureLocationPermission(context);
      if (ok && mounted) _fetchUserLocation();
    });
  }

  // 从系统设置页返回 App 时，自动刷新授权状态
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

  // 获取当前位置（绿点展示）并移动相机，中心 pin 即为选点
  Future<void> _fetchUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;
      setState(() {
        _userLatLng = LatLng(pos.latitude, pos.longitude);
        // 默认选中当前区域（搜索框清空态下「下一步」用定位坐标）
        _selectedPoi = null;
      });
      _mapCtrl?.move(_userLatLng!, 15);
    } catch (_) {
      // 定位失败不阻塞选点流程，地图保持兜底中心
    }
  }

  // 搜索框输入（400ms 防抖 → 天地图地点搜索）
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _doSearch(value);
    });
  }

  Future<void> _doSearch(String keyword) async {
    final kw = keyword.trim();
    if (kw.isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
        _selectedPoi = null;
      });
      return;
    }
    setState(() => _searching = true);
    // 以当前地图视野为搜索范围（找不到时 API 内部会兜底全国）
    String? bound;
    try {
      final bounds = _mapCtrl?.camera.visibleBounds;
      if (bounds != null) {
        bound =
            '${bounds.southWest.longitude},${bounds.southWest.latitude},${bounds.northEast.longitude},${bounds.northEast.latitude}';
      }
    } catch (_) {}
    final list = await TdtApi.searchPlaces(kw, mapBound: bound);
    if (!mounted) return;
    setState(() {
      _results = list;
      _searching = false;
      _selectedPoi = null;
    });
  }

  // 选中联想项：地图移动到该地点
  void _selectPoi(TdtPoi poi) {
    setState(() {
      _selectedPoi = poi;
      _searchController.text = poi.name;
      _results = [];
      _searching = false;
    });
    _searchFocus.unfocus();
    _mapCtrl?.move(LatLng(poi.lat, poi.lng), 16);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(RemixIcons.arrow_left_line, size: 24.w, color: Constants.INK),
        ),
        title: Text(
          '上传钓点',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Constants.INK,
          ),
        ),
      ),
      body: Column(
        children: [
          // 天地图（中心 pin 随地图拖动选点）
          Expanded(
            flex: 46,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: _mapCtrl ??= MapController(),
                  options: MapOptions(
                    initialCenter: _userLatLng ?? _kFallbackCenter,
                    initialZoom: 15,
                    minZoom: 3,
                    maxZoom: 18,
                    // 拖动地图后清除已选联想项（中心 pin 即选点）
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture && _selectedPoi != null) {
                        setState(() => _selectedPoi = null);
                      }
                    },
                  ),
                  children: [
                    ...tdtTileLayers(),
                    // 当前定位（绿点）
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
                  ],
                ),
                Center(
                  child: IgnorePointer(
                    child: Icon(
                      RemixIcons.map_pin_2_fill,
                      size: 46.w,
                      color: const Color(0xFF2F9EFF),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                // 当前选中地点名（贴在 pin 上方）
                if (_selectedPoi != null)
                  Positioned(
                    left: 24.w,
                    right: 24.w,
                    bottom: 12.w,
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          _selectedPoi!.address.isEmpty
                              ? _selectedPoi!.name
                              : '${_selectedPoi!.name} · ${_selectedPoi!.address}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Constants.INK,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 底部白色面板
          Expanded(
            flex: 54,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 16.w, 24.w, 0),
                    child: FillInput(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      hint: '搜索钓点地址',
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  SizedBox(height: 12.w),
                  Expanded(child: _buildResultList()),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 12.w),
                      child: InkButton(
                        text: '下一步',
                        height: 48,
                        onPressed: _goNext,
                      ),
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

  // 联想结果列表（含搜索中/空态）
  Widget _buildResultList() {
    // 搜索中
    if (_searching) {
      return Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: const CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    // 空态：输入关键词搜索，或提示选中了当前区域
    if (_results.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          children: [
            Icon(RemixIcons.map_pin_2_fill,
                size: 16.w, color: Constants.GRAY_LIGHT),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _selectedPoi != null
                    ? '已选择：${_selectedPoi!.name}'
                    : (_userLatLng != null
                        ? '已定位到当前位置，可直接拖动地图选点'
                        : '输入关键词搜索钓点地址'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Constants.GRAY_LIGHT),
              ),
            ),
          ],
        ),
      );
    }
    // 联想列表
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 12.w),
      itemCount: _results.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.w),
      itemBuilder: (_, i) {
        final poi = _results[i];
        return GestureDetector(
          onTap: () => _selectPoi(poi),
          child: Container(
            constraints: BoxConstraints(minHeight: 48.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: Constants.INPUT_BG,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(RemixIcons.map_pin_2_fill,
                    size: 16.w, color: Constants.GRAY_LIGHT),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        poi.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Constants.INK,
                        ),
                      ),
                      if (poi.address.isNotEmpty) ...[
                        SizedBox(height: 2.w),
                        Text(
                          poi.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Constants.GRAY_LIGHT,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 下一步：带选中地点信息进入填写页
  void _goNext() {
    LatLng center;
    String name = '';
    String address = '';
    if (_selectedPoi != null) {
      center = LatLng(_selectedPoi!.lat, _selectedPoi!.lng);
      name = _selectedPoi!.name;
      address = _selectedPoi!.address;
    } else {
      // 未选联想项：用地图中心（默认即当前定位区域）
      try {
        center = _mapCtrl?.camera.center ?? _userLatLng ?? _kFallbackCenter;
      } catch (_) {
        center = _userLatLng ?? _kFallbackCenter;
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpotInfoPage(
          initialName: name,
          initialAddress: address,
          latLng: center,
        ),
      ),
    );
  }
}
