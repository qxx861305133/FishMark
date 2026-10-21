import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/pages/upload/ai_fish_id.dart';
import 'package:luji_app/pages/upload/catch_upload.dart';
import 'package:luji_app/pages/upload/gear_upload.dart';
import 'package:luji_app/pages/upload/spot_upload.dart';

/// @desc 中间发布按钮唤起的上传面板
class PublishSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _PublishSheetBody(),
    );
  }
}

class _PublishSheetBody extends StatelessWidget {
  const _PublishSheetBody();

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.set_meal, 'label': '鱼获记录', 'desc': '记录你的每一尾战果', 'route': 'catch'},
      {'icon': Icons.auto_awesome, 'label': 'AI识鱼', 'desc': '拍照自动识别鱼种', 'route': 'ai'},
      {'icon': Icons.add_location_alt_outlined, 'label': '钓点上传', 'desc': '分享你的秘密钓位', 'route': 'spot'},
      {'icon': Icons.build_outlined, 'label': '装备上传', 'desc': '晒出你的装备库', 'route': 'gear'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.w)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 32.w),
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 80.w),
                Text(
                  '上传',
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: SizedBox(
                    width: 80.w,
                    child: Icon(Icons.close,
                        size: 40.w, color: Constants.TEXT_SECONDARY_COLOR),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.w),
            // 宫格入口
            Padding(
              padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 48.w),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 24.w,
                crossAxisSpacing: 24.w,
                childAspectRatio: 1.9,
                children: items.map((item) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleRoute(context, item['route'] as String);
                    },
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Constants.BG_COLOR,
                        borderRadius: BorderRadius.circular(24.w),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 88.w,
                            height: 88.w,
                            decoration: BoxDecoration(
                              color: Constants.PRIMARY_COLOR.withValues(
                                  alpha: 0.1),
                              borderRadius: BorderRadius.circular(24.w),
                            ),
                            child: Icon(item['icon'] as IconData,
                                size: 44.w, color: Constants.PRIMARY_COLOR),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6.w),
                                Text(
                                  item['desc'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Constants.TEXT_LIGHT_COLOR,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 跳转对应上传页
  void _handleRoute(BuildContext context, String route) {
    switch (route) {
      case 'catch':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CatchUploadPage()),
        );
        break;
      case 'ai':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AiFishIdPage()),
        );
        break;
      case 'spot':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SpotUploadPage()),
        );
        break;
      case 'gear':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GearUploadPage()),
        );
        break;
    }
  }
}
