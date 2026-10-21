import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';

/// @desc 圆角主按钮
class RoundButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final double? fontSize;
  final bool loading;

  const RoundButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.color,
    this.textColor,
    this.fontSize,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 88.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onPressed == null
              ? Constants.DISABLED_COLOR
              : color ?? Constants.PRIMARY_COLOR,
          borderRadius: BorderRadius.circular(44.w),
        ),
        child: loading
            ? SizedBox(
                width: 32.w,
                height: 32.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: fontSize ?? 30.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
