import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/catch_record.dart';
import 'package:FishMark/utils/wechat_share_util.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/round_button.dart';

/// @desc 战报分享卡预览页（模板选择 + 保存/分享）
class ReportPreviewPage extends StatefulWidget {
  // 关联鱼获
  final CatchRecord record;

  const ReportPreviewPage({super.key, required this.record});

  @override
  State<ReportPreviewPage> createState() => _ReportPreviewPageState();
}

class _ReportPreviewPageState extends State<ReportPreviewPage> {
  final List<Map<String, dynamic>> _templates = [];
  int _selectedTemplate = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  // 加载战报模板
  Future<void> _loadTemplates() async {
    try {
      final result = await Api().get('report_templates');
      if (!mounted) return;
      if (result['success'] && result['data'] is List) {
        setState(() {
          for (final item in result['data']) {
            _templates.add(Map<String, dynamic>.from(item));
          }
        });
      }
    } catch (e) {
      LogUtil.e('战报模板加载失败: $e');
    }
  }

  // 保存战报：调用 POST /ai/generate-report 生成战报图
  Future<void> _handleSave() async {
    if (_isSaving) return;
    final catchId = int.tryParse(widget.record.rid ?? '');
    setState(() => _isSaving = true);
    try {
      final result = await Api().post('ai_generate_report', data: {
        if (catchId != null) 'catch_id': catchId,
      });
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (result['success'] == true) {
        final report = result['data']?['report'];
        final imageUrl = report?['image_url'];
        Fluttertoast.showToast(
            msg: imageUrl != null ? '战报已生成：$imageUrl' : '战报已生成');
      } else {
        final error = result['error'];
        Fluttertoast.showToast(
            msg: error is Map ? error['message'] ?? '生成失败' : '生成失败');
      }
    } catch (e) {
      LogUtil.e('战报生成失败: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      Fluttertoast.showToast(msg: '$e'.replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('战报预览', style: TextStyle(fontSize: 17.sp)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _buildReportCard(),
                SizedBox(height: 16.w),
                // 模板选择
                if (_templates.isNotEmpty) ...[
                  Text(
                    '选择模板',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.w),
                  SizedBox(
                    height: 80.w,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _templates.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final template = _templates[index];
                        final selected = index == _selectedTemplate;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedTemplate = index),
                          child: Container(
                            width: 100.w,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Constants.PRIMARY_COLOR
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8.w),
                              border: Border.all(
                                color: selected
                                    ? Constants.PRIMARY_COLOR
                                    : Constants.LINE_COLOR,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.style_outlined,
                                  size: 24.w,
                                  color: selected
                                      ? Colors.white
                                      : Constants.PRIMARY_COLOR,
                                ),
                                SizedBox(height: 6.w),
                                Text(
                                  template['name'] ?? '模板${index + 1}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: selected
                                        ? Colors.white
                                        : Constants.TEXT_DEFAULT_COLOR,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 底部操作
          _buildBottomBar(),
        ],
      ),
    );
  }

  // 战报分享卡
  Widget _buildReportCard() {
    final record = widget.record;
    final hasCover = record.images != null && record.images!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12.w,
            offset: Offset(0, 4.w),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          Stack(
            children: [
              NetImage(
                url: hasCover ? record.images!.first : null,
                height: 200.w,
                width: double.infinity,
                borderRadius: 0,
              ),
              Positioned(
                left: 12.w,
                top: 12.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                  decoration: BoxDecoration(
                    color: Constants.HIGHLIGHT_COLOR,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Text(
                    '路亚战报',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 鱼种标题
                Text(
                  record.fish?.name ?? '今日战果',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: Constants.TEXT_DEFAULT_COLOR,
                  ),
                ),
                SizedBox(height: 12.w),
                // 数据行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('重量',
                        record.weight != null ? '${record.weight}kg' : '-'),
                    _verticalLine(),
                    _buildStatItem('长度',
                        record.length != null ? '${record.length}cm' : '-'),
                    _verticalLine(),
                    _buildStatItem('钓点', record.spot?.name ?? '野钓'),
                  ],
                ),
                SizedBox(height: 12.w),
                Divider(height: 1, color: Constants.LINE_COLOR),
                SizedBox(height: 12.w),
                // 天气与时间
                Row(
                  children: [
                    Icon(Icons.cloud_outlined,
                        size: 14.w, color: Constants.TEXT_LIGHT_COLOR),
                    SizedBox(width: 4.w),
                    Text(
                      '${record.weather ?? '天气未知'} · ${record.caught_at ?? ''}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.w),
                // 心得
                if (record.notes != null && record.notes!.isNotEmpty)
                  Text(
                    record.notes!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Constants.TEXT_DEFAULT_COLOR,
                      height: 1.5,
                    ),
                  ),
                SizedBox(height: 12.w),
                // 底部品牌
                Row(
                  children: [
                    Icon(Icons.phishing,
                        size: 16.w, color: Constants.PRIMARY_COLOR),
                    SizedBox(width: 4.w),
                    Text(
                      '${Constants.APP_NAME} · ${Constants.APP_SLOGAN}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Constants.TEXT_LIGHT_COLOR,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 底部操作栏
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 8.w),
        child: Row(
          children: [
            Expanded(
              child: RoundButton(
                text: '保存到相册',
                loading: _isSaving,
                onPressed: _handleSave,
                color: Colors.white,
                textColor: Constants.PRIMARY_COLOR,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: RoundButton(
                text: '分享',
                onPressed: _handleShare,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 分享战报：生成战报图后弹出微信分享面板（好友 / 朋友圈）
  Future<void> _handleShare() async {
    try {
      final catchId = int.tryParse(widget.record.rid ?? '');
      final result = await Api().post('ai_generate_report', data: {
        if (catchId != null) 'catch_id': catchId,
      });
      if (!mounted) return;
      if (result['success'] == true) {
        WechatShareUtil.show(context, title: '我的路亚战报 | 路记');
      } else {
        final error = result['error'];
        Fluttertoast.showToast(
            msg: error is Map ? error['message'] ?? '生成失败' : '生成失败');
      }
    } catch (e) {
      LogUtil.e('战报分享失败: $e');
      if (!mounted) return;
      // 生成失败时仍走本地微信分享面板
      WechatShareUtil.show(context, title: '我的路亚战报 | 路记');
    }
  }

  // 数据项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Constants.PRIMARY_COLOR,
          ),
        ),
        SizedBox(height: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Constants.TEXT_LIGHT_COLOR,
          ),
        ),
      ],
    );
  }

  // 分隔线
  Widget _verticalLine() {
    return Container(
      width: 1,
      height: 24.w,
      color: Constants.LINE_COLOR,
    );
  }
}
