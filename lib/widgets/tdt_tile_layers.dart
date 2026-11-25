import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:FishMark/config/tdt_keys.dart';

/// 天地图瓦片图层：普通 vec_w+cva_w / 卫星 img_w+cia_w
/// 底图与注记叠加；使用球面墨卡托（EPSG:3857），HTTPS + 分域负载均衡
///
/// 高清渲染策略（解决高 DPR 屏文字模糊）：
/// - 天地图无 @2x 瓦片，flutter_map 只能走模拟模式（zoom+1 四块拼一块，
///   请求量 ×4/层）
/// - 两层全开实测 ×8 请求量连续放大即触发 DataServer 限流（整屏变灰）
/// - 折中方案：仅注记层（cva_w/cia_w，文字所在层）开启模拟模式，
///   文字清晰，总请求量 ×1（底图）+×4（注记）= ×5，限流风险更低；
///   底图线条仍为标清渲染，影响较小
/// - 若注记层单独开启仍触发限流，将 [_kRetinaLabelEnabled] 置 false 回退
const bool _kRetinaLabelEnabled = true;

List<Widget> tdtTileLayers({bool satellite = false, BuildContext? context}) {
  final bool retinaLabel = _kRetinaLabelEnabled &&
      (context != null) &&
      RetinaMode.isHighDensity(context);
  final String base = satellite ? 'img_w' : 'vec_w';
  final String label = satellite ? 'cia_w' : 'cva_w';
  const List<String> subdomains = [
    '0', '1', '2', '3', '4', '5', '6', '7',
  ];
  return [
    // 底图层：不开启模拟 retina（标清渲染，避免请求量叠加触发限流）
    TileLayer(
      urlTemplate:
          'https://t{s}.tianditu.gov.cn/DataServer?T=$base&x={x}&y={y}&l={z}&tk=$tdtApiKey',
      subdomains: subdomains,
      maxNativeZoom: 18,
      maxZoom: 18,
      keepBuffer: 3,
      panBuffer: 1,
      userAgentPackageName: 'com.luji.lujiApp',
    ),
    // 注记层（文字）：仅此层开启模拟 retina，提升文字清晰度
    // flutter_map 会自动把该层有效最大缩放降 1 级（18→17，17 以上放大显示）
    TileLayer(
      urlTemplate:
          'https://t{s}.tianditu.gov.cn/DataServer?T=$label&x={x}&y={y}&l={z}&tk=$tdtApiKey',
      subdomains: subdomains,
      maxNativeZoom: 18,
      maxZoom: 18,
      retinaMode: retinaLabel,
      keepBuffer: 3,
      panBuffer: 1,
      userAgentPackageName: 'com.luji.lujiApp',
    ),
  ];
}
