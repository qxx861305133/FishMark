import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/report_data.dart';
import 'package:FishMark/pages/report/catch_capture_page.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 3.2.3 AI 识鱼 - 识别结果
class AiFishIdentifyResultPage extends StatelessWidget {
  const AiFishIdentifyResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = ReportData.aiFishResult;
    return Scaffold(
      backgroundColor: Constants.INPUT_BG,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 64.w, 24.w, 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 识别照片
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    result.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : const NetImagePlaceholder(),
                    errorBuilder: (_, _, _) => const NetImagePlaceholder(),
                  ),
                ),
              ),
              SizedBox(height: 16.w),
              // 识别资料卡
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '搜索 ${result.keywordCount} 个关键词 · 参考 ${result.refCount} 篇资料',
                      style: TextStyle(fontSize: 12.sp, color: Constants.GRAY_LIGHT),
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      result.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Constants.INK,
                      ),
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      result.intro,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Constants.GRAY,
                        height: 1.7,
                      ),
                    ),
                    SizedBox(height: 16.w),
                    Text(
                      '✅ 外形识别',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Constants.INK,
                      ),
                    ),
                    SizedBox(height: 10.w),
                    for (final point in result.points) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 7.w),
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: const BoxDecoration(
                                color: Constants.INK,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              point,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Constants.INK,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.w),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 24.w),
            ],
            ),
          ),
          // 左上角关闭
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.w),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    RemixIcons.close_line,
                    size: 20.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 保存鱼获：黑底荧光绿字，固定底部
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 12.w),
          child: LimeButton(
            text: '保存鱼获',
            height: 48,
            background: Constants.INK,
            textColor: Constants.LIME,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CatchCapturePage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
