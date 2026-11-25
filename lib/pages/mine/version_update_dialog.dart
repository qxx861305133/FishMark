import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/mock/mine_data.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 5.3.9 版本更新弹窗
class VersionUpdateDialog extends StatelessWidget {
  const VersionUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 44.w),
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 58.w, 24.w, 24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    Global.t(MineData.updateTitle, 'New Version Available'),
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Constants.INK,
                    ),
                  ),
                ),
                SizedBox(height: 18.w),
                // 更新说明
                ...MineData.updateNotes.map(
                  (note) => Padding(
                    padding: EdgeInsets.only(bottom: 14.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8.w),
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E6B3E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              height: 1.5,
                              color: Constants.INK,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.w),
                InkButton(
                  text: Global.t(MineData.updateButton, 'Update Now (~48 MB)'),
                  height: 46,
                  onPressed: () {
                    Fluttertoast.showToast(msg: '演示环境暂不支持');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: AppLogo(size: 88),
          ),
        ],
      ),
    );
  }
}
