import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:luji_app/config/constants.dart';

/// @desc 区块标题
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 32.w,
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  color: Constants.PRIMARY_COLOR,
                  borderRadius: BorderRadius.circular(4.w),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w600,
                  color: Constants.TEXT_DEFAULT_COLOR,
                ),
              ),
            ],
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionText!,
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Constants.TEXT_SECONDARY_COLOR,
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 32.w, color: Constants.TEXT_LIGHT_COLOR),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
