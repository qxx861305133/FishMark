import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/challenge.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/round_button.dart';

/// @desc 挑战详情页：详情 + 进度 + 参与/完成反馈
class ChallengeDetailPage extends StatefulWidget {
  // 挑战ID
  final String? rid;

  const ChallengeDetailPage({super.key, this.rid});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  Challenge? _challenge;
  bool _loading = true;
  bool _isSubmiting = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final result = await Api().get(
        'challenge_detail',
        queryParameters: {'rid': widget.rid},
      );
      if (!mounted) return;
      if (result['success'] && result['data'] != null) {
        setState(() {
          _challenge =
              Challenge.fromJson(Map<String, dynamic>.from(result['data']));
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('挑战详情加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // 参与挑战
  Future<void> _handleJoin() async {
    setState(() => _isSubmiting = true);
    try {
      final result = await Api().post('challenge_join', data: {
        'rid': widget.rid,
      });
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      if (result['success']) {
        Fluttertoast.showToast(msg: '参与成功，快去完成挑战吧');
        _loadDetail();
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('参与挑战失败: $e');
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  // 完成反馈
  Future<void> _handleFeedback() async {
    setState(() => _isSubmiting = true);
    try {
      final result = await Api().post('challenge_feedback', data: {
        'rid': widget.rid,
      });
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      if (result['success']) {
        Fluttertoast.showToast(msg: '反馈成功，等待审核');
        _loadDetail();
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('完成反馈失败: $e');
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _challenge == null
              ? const Center(child: Text('挑战不存在'))
              : _buildBody(),
      bottomNavigationBar:
          _challenge != null && !_loading ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    final challenge = _challenge!;
    final progress = challenge.progress ?? 0;
    final target = challenge.target_count ?? 1;
    final ratio = (progress / target).clamp(0.0, 1.0);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 封面
        Stack(
          children: [
            NetImage(
              url: challenge.cover,
              height: 200.w,
              width: double.infinity,
            ),
            SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back,
                      size: 18.w, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        // 标题区
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.title ?? '',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.w),
              Text(
                challenge.description ?? '',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Constants.TEXT_SECONDARY_COLOR,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 12.w),
              // 奖励
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.military_tech,
                        size: 24.w, color: Constants.HIGHLIGHT_COLOR),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '完成奖励：${challenge.reward?.name ?? '神秘勋章'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '+${challenge.points ?? 0} 积分',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Constants.HIGHLIGHT_COLOR,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.w),
        // 进度区
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '挑战目标',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    challenge.target ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Constants.TEXT_SECONDARY_COLOR,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.w),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8.w,
                  backgroundColor: Constants.BG_COLOR,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ratio >= 1
                        ? Constants.HIGHLIGHT_COLOR
                        : Constants.PRIMARY_COLOR,
                  ),
                ),
              ),
              SizedBox(height: 8.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '当前进度',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Constants.TEXT_LIGHT_COLOR,
                    ),
                  ),
                  Text(
                    '$progress / $target',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: ratio >= 1
                          ? Constants.HIGHLIGHT_COLOR
                          : Constants.PRIMARY_COLOR,
                    ),
                  ),
                ],
              ),
              if (challenge.end_at != null) ...[
                SizedBox(height: 12.w),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 14.w, color: Constants.TEXT_LIGHT_COLOR),
                    SizedBox(width: 4.w),
                    Text(
                      '截止时间：${challenge.end_at}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Constants.TEXT_LIGHT_COLOR,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 24.w),
      ],
    );
  }

  // 底部操作
  Widget _buildBottomBar() {
    final status = _challenge!.status ?? 'not_join';
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 8.w),
        child: RoundButton(
          text: status == 'not_join'
              ? '参与挑战'
              : status == 'doing'
                  ? '我已完成，提交反馈'
                  : status == 'finished'
                      ? '已完成'
                      : '已过期',
          loading: _isSubmiting,
          onPressed: status == 'not_join'
              ? _handleJoin
              : status == 'doing'
                  ? _handleFeedback
                  : null,
        ),
      ),
    );
  }
}
