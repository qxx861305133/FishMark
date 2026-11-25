import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:FishMark/config/tdt_keys.dart';

/// 天地图瓦片图层：普通 vec_w+cva_w / 卫星 img_w+cia_w
/// 底图与注记叠加；使用球面墨卡托（EPSG:3857），HTTPS + 分域负载均衡
/// retinaMode 开启模拟高清模式：高 DPR 屏幕下请求更高层级瓦片再缩小渲染，
/// 避免地图发糊（天地图支持 z 最大 18，flutter_map 内部会自动降一级 maxNativeZoom）
List<Widget> tdtTileLayers({bool satellite = false}) {
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
      retinaMode: true,
      keepBuffer: 4,
      userAgentPackageName: 'com.luji.lujiApp',
    ),
    TileLayer(
      urlTemplate:
          'https://t{s}.tianditu.gov.cn/DataServer?T=$label&x={x}&y={y}&l={z}&tk=$tdtApiKey',
      subdomains: subdomains,
      maxNativeZoom: 18,
      maxZoom: 18,
      retinaMode: true,
      keepBuffer: 4,
      userAgentPackageName: 'com.luji.lujiApp',
    ),
  ];
}
