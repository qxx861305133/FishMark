import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/catch_record.dart';
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

  // 保存战报
  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final result = await Api().post('report_save', data: {
        'rid': widget.record.rid,
        'template': _templates.isNotEmpty
            ? _templates[_selectedTemplate]['rid']
            : 'default',
      });
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (result['success']) {
        Fluttertoast.showToast(msg: '战报已保存到相册');
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('战报保存失败: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('战报预览', style: TextStyle(fontSize: 34.sp)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(32.w),
              children: [
                _buildReportCard(),
                SizedBox(height: 32.w),
                // 模板选择
                if (_templates.isNotEmpty) ...[
                  Text(
                    '选择模板',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.w),
                  SizedBox(
                    height: 160.w,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _templates.length,
                      separatorBuilder: (_, _) => SizedBox(width: 16.w),
                      itemBuilder: (context, index) {
                        final template = _templates[index];
                        final selected = index == _selectedTemplate;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedTemplate = index),
                          child: Container(
                            width: 200.w,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Constants.PRIMARY_COLOR
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16.w),
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
                                  size: 48.w,
                                  color: selected
                                      ? Colors.white
                                      : Constants.PRIMARY_COLOR,
                                ),
                                SizedBox(height: 12.w),
                                Text(
                                  template['name'] ?? '模板${index + 1}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 24.sp,
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
        borderRadius: BorderRadius.circular(32.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24.w,
            offset: Offset(0, 8.w),
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
                height: 400.w,
                width: double.infinity,
                borderRadius: 0,
              ),
              Positioned(
                left: 24.w,
                top: 24.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
                  decoration: BoxDecoration(
                    color: Constants.HIGHLIGHT_COLOR,
                    borderRadius: BorderRadius.circular(24.w),
                  ),
                  child: Text(
                    '路亚战报',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 鱼种标题
                Text(
                  record.fish?.name ?? '今日战果',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w800,
                    color: Constants.TEXT_DEFAULT_COLOR,
                  ),
                ),
                SizedBox(height: 24.w),
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
                SizedBox(height: 24.w),
                Divider(height: 1, color: Constants.LINE_COLOR),
                SizedBox(height: 24.w),
                // 天气与时间
                Row(
                  children: [
                    Icon(Icons.cloud_outlined,
                        size: 28.w, color: Constants.TEXT_LIGHT_COLOR),
                    SizedBox(width: 8.w),
                    Text(
                      '${record.weather ?? '天气未知'} · ${record.caught_at ?? ''}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.w),
                // 心得
                if (record.notes != null && record.notes!.isNotEmpty)
                  Text(
                    record.notes!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Constants.TEXT_DEFAULT_COLOR,
                      height: 1.5,
                    ),
                  ),
                SizedBox(height: 24.w),
                // 底部品牌
                Row(
                  children: [
                    Icon(Icons.phishing,
                        size: 32.w, color: Constants.PRIMARY_COLOR),
                    SizedBox(width: 8.w),
                    Text(
                      '${Constants.APP_NAME} · ${Constants.APP_SLOGAN}',
                      style: TextStyle(
                        fontSize: 22.sp,
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
        padding: EdgeInsets.fromLTRB(32.w, 16.w, 32.w, 16.w),
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
            SizedBox(width: 24.w),
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

  // 分享战报
  Future<void> _handleShare() async {
    try {
      final result = await Api().post('report_share', data: {
        'rid': widget.record.rid,
      });
      if (result['success']) {
        Fluttertoast.showToast(msg: '战报分享成功');
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('战报分享失败: $e');
      Fluttertoast.showToast(msg: '分享功能开发中');
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
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: Constants.PRIMARY_COLOR,
          ),
        ),
        SizedBox(height: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 22.sp,
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
      height: 48.w,
      color: Constants.LINE_COLOR,
    );
  }
}
