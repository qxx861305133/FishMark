import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:FishMark/config/tdt_keys.dart';

/// 天地图瓦片图层：普通 vec_w+cva_w / 卫星 img_w+cia_w
/// 底图与注记叠加；使用球面墨卡托（EPSG:3857），HTTPS + 分域负载均衡
/// retinaMode：天地图无 @2x 瓦片，开启后走 flutter_map 模拟模式（请求量
/// ×4/层），实测连续放大即触发 DataServer 限流返回空瓦片（整屏变灰），
/// 故默认关闭；保留开关便于后续换支持高清瓦片的地图源时再启用
const bool _kRetinaEnabled = false;

List<Widget> tdtTileLayers({bool satellite = false, BuildContext? context}) {
  final bool retina =
      _kRetinaEnabled && (context != null) && RetinaMode.isHighDensity(context);
  final String base = satellite ? 'img_w' : 'vec_w';
  final String label = satellite ? 'cia_w' : 'cva_w';
  const List<String> subdomains = [
    '0', '1', '2', '3', '4', '5', '6', '7',
  ];
  return [
    TileLayer(
      urlTemplate:
          'https://t{s}.tianditu.gov.cn/DataServer?T=$base&x={x}&y={y}&l={z}&tk=$tdtApiKey',
      subdomains: subdomains,
      maxNativeZoom: 18,
      maxZoom: 18,
      retinaMode: retina,
      keepBuffer: 3,
      panBuffer: 1,
      userAgentPackageName: 'com.luji.lujiApp',
    ),
    TileLayer(
      urlTemplate:
          'https://t{s}.tianditu.gov.cn/DataServer?T=$label&x={x}&y={y}&l={z}&tk=$tdtApiKey',
      subdomains: subdomains,
      maxNativeZoom: 18,
      maxZoom: 18,
      retinaMode: retina,
      keepBuffer: 3,
      panBuffer: 1,
      userAgentPackageName: 'com.luji.lujiApp',
    ),
  ];
}
