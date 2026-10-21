import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';

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
        placeholder: (_, _) => Container(
          width: width,
          height: height,
          color: Constants.LINE_COLOR,
          child: Center(
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, _, _) => Container(
          width: width,
          height: height,
          color: Constants.LINE_COLOR,
          child: Icon(Icons.image_not_supported_outlined,
              size: 56.w, color: Colors.black26),
        ),
      ),
    );
  }
}
