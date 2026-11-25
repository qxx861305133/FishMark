import 'package:dio/dio.dart';

import 'package:FishMark/config/tdt_keys.dart';

/// @desc 天地图搜索/逆地理编码（DataServer 之外的公开服务，tk 同底图密钥）
class TdtPoi {
  final String name;
  final String address;
  final double lat;
  final double lng;

  const TdtPoi({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class TdtApi {
  TdtApi._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  /// 中国范围（经度,纬度：minLon,minLat,maxLon,maxLat）
  static const String _chinaBound = '73.6,3.8,135.1,53.6';

  /// 地点搜索：返回候选 POI（名称 + 地址 + 坐标）
  /// [mapBound] 传当前地图视野 "minLon,minLat,maxLon,maxLat"，默认全国范围
  static Future<List<TdtPoi>> searchPlaces(
    String keyword, {
    String? mapBound,
  }) async {
    final kw = keyword.trim();
    if (kw.isEmpty) return const [];
    final bound = (mapBound == null || mapBound.isEmpty)
        ? _chinaBound
        : mapBound;
    final postStr =
        '{"keyWord":"$kw","mapBound":"$bound","queryType":"1","start":"0","count":"10"}';
    try {
      final resp = await _dio.get(
        'https://api.tianditu.gov.cn/search',
        queryParameters: {'postStr': postStr, 'type': 'query', 'tk': tdtApiKey},
      );
      final data = resp.data;
      if (data is! Map) return const [];

      // resultType: 1=POI列表 2=建议词(无坐标) 3=统计 …；POI 可能在 pois 字段
      final pois = data['pois'];
      if (pois is List && pois.isNotEmpty) {
        return pois.map(_parsePoi).whereType<TdtPoi>().toList();
      }

      // 建议词列表：取第一条作为新关键词再精确搜索一次
      final suggests = data['suggests'];
      if (suggests is List && suggests.isNotEmpty) {
        final first = suggests.first;
        final name = first is Map ? (first['name'] ?? '') as String : '';
        if (name.isNotEmpty && name != kw) {
          return searchPlaces(name, mapBound: mapBound);
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  static TdtPoi? _parsePoi(dynamic item) {
    if (item is! Map) return null;
    final raw = item['lonlat']?.toString() ?? '';
    if (raw.isEmpty) return null;
    // lonlat 格式 "lon,lat"，容错空格/中文逗号
    final parts = raw.split(RegExp('[,，\\s]+'));
    if (parts.length < 2) return null;
    final lng = double.tryParse(parts[0]);
    final lat = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    return TdtPoi(
      name: (item['name'] ?? '').toString(),
      address: (item['address'] ?? '').toString(),
      lat: lat,
      lng: lng,
    );
  }

  /// 逆地理编码：坐标 → 省 · 市 文本（个人资料「所在地」等场景）
  /// 返回 null 表示查询失败
  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final resp = await _dio.get(
        'https://api.tianditu.gov.cn/geocoder',
        queryParameters: {
          'postStr': '{"lon":$lng,"lat":$lat,"ver":1}',
          'tk': tdtApiKey,
        },
      );
      final data = resp.data;
      if (data is! Map) return null;
      final result = data['result'];
      if (result is! Map) return null;
      final comp = result['addressComponent'];
      String province = '';
      String city = '';
      if (comp is Map) {
        province = (comp['province'] ?? '').toString();
        city = (comp['city'] ?? '').toString();
        // 直辖市 city 可能为空，用 county 兜底
        if (city.isEmpty || city == province) {
          city = (comp['county'] ?? '').toString();
        }
      }
      // 去掉「省/市」后缀，展示更简洁：浙江 · 杭州
      province = province.replaceAll(RegExp(r'(省|自治区|特别行政区)$'), '');
      city = city.replaceAll(RegExp(r'市$'), '');
      if (province.isEmpty && city.isEmpty) {
        return (result['formatted_address'] ?? '').toString();
      }
      if (city.isEmpty || city == province) return province;
      return '$province · $city';
    } catch (_) {
      return null;
    }
  }
}
