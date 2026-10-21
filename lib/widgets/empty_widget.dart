import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// @desc 空数据占位
class EmptyWidget extends StatelessWidget {
  final String text;
  final IconData icon;

  const EmptyWidget({
    super.key,
    this.text = '暂无数据',
    this.icon = Icons.waves,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120.w, color: Colors.black12),
          SizedBox(height: 24.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.black38,
              fontSize: 28.sp,
            ),
          ),
        ],
      ),
    );
  }
}
