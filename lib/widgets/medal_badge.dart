import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:luji_app/config/constants.dart';

/// @desc 勋章稀有度徽标
class MedalBadge extends StatelessWidget {
  final String rarity; // common / rare / epic / legend
  final String name;
  final IconData? icon;
  final bool unlocked;

  const MedalBadge({
    super.key,
    required this.rarity,
    required this.name,
    this.icon,
    this.unlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Constants.MEDAL_RARITY_COLORS[rarity] ??
        Constants.MEDAL_RARITY_COLORS['common']!;

    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? color.withValues(alpha: 0.12) : Colors.black12,
            border: Border.all(
              color: unlocked ? color : Colors.black26,
              width: 3.w,
            ),
          ),
          child: Icon(
            icon ?? Icons.workspace_premium_outlined,
            size: 64.w,
            color: unlocked ? color : Colors.black26,
          ),
        ),
        SizedBox(height: 12.w),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24.sp,
            color: unlocked
                ? Constants.TEXT_DEFAULT_COLOR
                : Constants.TEXT_LIGHT_COLOR,
          ),
        ),
      ],
    );
  }
}
