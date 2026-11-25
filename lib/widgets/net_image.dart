import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';

/// @desc 统一网络图片占位图（加载中 / 加载失败共用；后续替换占位实现只需改这里）
class NetImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const NetImagePlaceholder({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: Icon(
        RemixIcons.image_line,
        size: 32.w,
        color: const Color(0xFFBBBBBB),
      ),
    );
  }
}

/// @desc 网络图片（带占位与错误兜底）
class NetImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const NetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.w),
      child: CachedNetworkImage(
        imageUrl: url ?? Constants.DEFAULT_PLACEHOLDER,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) =>
            NetImagePlaceholder(width: width, height: height),
        errorWidget: (_, _, _) =>
            NetImagePlaceholder(width: width, height: height),
      ),
    );
  }
}
