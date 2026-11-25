import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/design_data.dart';
import 'package:FishMark/pages/medal/medal_achieved_sheet.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 1.2.1 我的挑战 / 徽章列表
class MedalListPage extends StatelessWidget {
  const MedalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: Stack(
        children: [
          GridView.builder(
            padding: EdgeInsets.fromLTRB(pagePadding, 8.w, pagePadding, 100.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 24.w,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.62,
            ),
            itemCount: DesignData.medalGrid.length,
            itemBuilder: (context, index) {
              return _MedalCell(challenge: DesignData.medalGrid[index]);
            },
          ),
          // 底部固定按钮
          Positioned(
            left: pagePadding,
            right: pagePadding,
            bottom: 24.w,
            child: LimeButton(
              text: '炫耀我的成就',
              onPressed: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(RemixIcons.arrow_left_s_line, size: 26.w, color: Constants.INK),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        '我的挑战',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Constants.INK,
        ),
      ),
    );
  }
}

class _MedalCell extends StatelessWidget {
  final MockChallenge challenge;

  const _MedalCell({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final claimable = challenge.status == ChallengeStatus.claimable;
    final claimed = challenge.status == ChallengeStatus.claimed;
    final locked = challenge.status == ChallengeStatus.inProgress;

    return Column(
      children: [
        HexMedal(style: challenge.style, size: 76),
        SizedBox(height: 12.w),
        Text(
          challenge.title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Constants.INK,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.w),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '125 ',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3BA55D),
                ),
              ),
              TextSpan(
                text: challenge.goal.replaceFirst('125 ', ''),
                style: TextStyle(fontSize: 12.sp, color: Constants.GRAY),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.w),
        if (claimable)
          GestureDetector(
            onTap: () => MedalAchievedSheet.show(context),
            child: Container(
              width: double.infinity,
              height: 30.w,
              decoration: BoxDecoration(
                color: Constants.LIME,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Center(
                child: Text(
                  '领取徽章',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Constants.INK,
                  ),
                ),
              ),
            ),
          )
        else if (claimed)
          Text(
            challenge.grantedDate ?? '',
            style: TextStyle(fontSize: 11.sp, color: Constants.GRAY_LIGHT),
          )
        else if (locked)
          Container(
            width: double.infinity,
            height: 30.w,
            decoration: BoxDecoration(
              color: Constants.INPUT_BG,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${challenge.current} ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Constants.INK,
                      ),
                    ),
                    TextSpan(
                      text: '/${challenge.total}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Constants.GRAY_LIGHT,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
