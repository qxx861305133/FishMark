import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/pages/upload/catch_upload.dart';
import 'package:FishMark/widgets/empty_widget.dart';

/// @desc AI识鱼结果页：轮询任务结果 → 确认鱼种 → 去记录鱼获
class AiFishResultPage extends StatefulWidget {
  // 识别任务ID
  final String taskId;
  // 已有结果（免轮询）
  final Map<String, dynamic>? initialData;

  const AiFishResultPage({
    super.key,
    required this.taskId,
    this.initialData,
  });

  @override
  State<AiFishResultPage> createState() => _AiFishResultPageState();
}

class _AiFishResultPageState extends State<AiFishResultPage> {
  Map<String, dynamic>? _result;
  bool _loading = true;
  bool _failed = false;
  int _retryCount = 0;
  static const int _maxRetry = 10;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      setState(() {
        _result = widget.initialData;
        _loading = false;
      });
    } else {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // 轮询识别结果
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_retryCount >= _maxRetry) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _loading = false;
          _failed = true;
        });
        return;
      }
      _retryCount++;
      try {
        final result = await Api().get(
          'ai_fish_result',
          queryParameters: {'task_id': widget.taskId},
        );
        if (!mounted) return;
        if (result['success'] && result['data'] != null) {
          final status = result['data']['status'];
          if (status == 'done' || result['data']['fish'] != null) {
            timer.cancel();
            setState(() {
              _result = Map<String, dynamic>.from(result['data']);
              _loading = false;
            });
          } else if (status == 'failed') {
            timer.cancel();
            setState(() {
              _loading = false;
              _failed = true;
            });
          }
        }
      } catch (e) {
        LogUtil.e('查询识别结果失败: $e');
      }
    });
  }

  // 重试
  void _retry() {
    setState(() {
      _loading = true;
      _failed = false;
      _retryCount = 0;
    });
    _startPolling();
  }

  // 去记录鱼获（携带识别的鱼种名）
  void _goCatchUpload() {
    final fishName = _result?['fish']?['name'] ?? _result?['fish_name'] ?? '';
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CatchUploadPage()),
    );
    // 预填鱼种名
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Fluttertoast.showToast(msg: '已选择鱼种：$fishName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('识别结果', style: TextStyle(fontSize: 34.sp)),
      ),
      body: _loading
          ? _buildLoading()
          : _failed
              ? _buildFailed()
              : _buildResult(),
      bottomNavigationBar: (_result != null && !_failed)
          ? _buildBottomBar()
          : null,
    );
  }

  // 识别中
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 32.w),
          Text(
            '百炼大模型识别中…',
            style: TextStyle(
              fontSize: 30.sp,
              color: Constants.TEXT_SECONDARY_COLOR,
            ),
          ),
          SizedBox(height: 12.w),
          Text(
            '通常需要 3~10 秒',
            style: TextStyle(
              fontSize: 24.sp,
              color: Constants.TEXT_LIGHT_COLOR,
            ),
          ),
        ],
      ),
    );
  }

  // 识别失败
  Widget _buildFailed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyWidget(text: '未能识别出鱼种，换个角度试试', icon: Icons.help_outline),
          SizedBox(height: 48.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  minimumSize: Size(240.w, 88.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(44.w),
                  ),
                ),
                child: Text('重新识别', style: TextStyle(fontSize: 30.sp)),
              ),
              SizedBox(width: 24.w),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CatchUploadPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constants.PRIMARY_COLOR,
                  minimumSize: Size(240.w, 88.w),
                  side: BorderSide(color: Constants.PRIMARY_COLOR),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(44.w),
                  ),
                ),
                child: Text('手动填写', style: TextStyle(fontSize: 30.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 识别结果
  Widget _buildResult() {
    final fish = _result?['fish'] ?? {};
    final candidates = _result?['candidates'] ?? [];
    return ListView(
      padding: EdgeInsets.all(32.w),
      children: [
        // 主结果卡
        Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.w),
          ),
          child: Column(
            children: [
              Icon(Icons.set_meal,
                  size: 120.w, color: Constants.PRIMARY_COLOR),
              SizedBox(height: 16.w),
              Text(
                fish['name'] ?? '未知鱼种',
                style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (fish['alias'] != null) ...[
                SizedBox(height: 8.w),
                Text(
                  '别名：${fish['alias']}',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                  ),
                ),
              ],
              SizedBox(height: 16.w),
              // 置信度
              if (_result?['confidence'] != null)
                Text(
                  '置信度 ${((double.tryParse(_result!['confidence'].toString()) ?? 0) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.HIGHLIGHT_COLOR,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        // 候选鱼种
        if (candidates is List && candidates.isNotEmpty) ...[
          SizedBox(height: 24.w),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '可能是这些鱼',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.w),
                ...candidates.map((item) {
                  final candidate = Map<String, dynamic>.from(item);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.w),
                    child: Row(
                      children: [
                        Text(
                          candidate['name'] ?? '',
                          style: TextStyle(fontSize: 28.sp),
                        ),
                        const Spacer(),
                        Text(
                          '${((double.tryParse(candidate['confidence'].toString()) ?? 0) * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 26.sp,
                            color: Constants.TEXT_LIGHT_COLOR,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        // 建议钓法
        if (fish['bait'] != null) ...[
          SizedBox(height: 24.w),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Constants.PRIMARY_COLOR.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '推荐拟饵/钓法',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: Constants.PRIMARY_COLOR,
                  ),
                ),
                SizedBox(height: 12.w),
                Text(
                  fish['bait'] ?? '',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_DEFAULT_COLOR,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constants.TEXT_SECONDARY_COLOR,
                  minimumSize: Size(double.infinity, 88.w),
                  side: BorderSide(color: Constants.LINE_COLOR),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(44.w),
                  ),
                ),
                child: Text('返回', style: TextStyle(fontSize: 30.sp)),
              ),
            ),
            SizedBox(width: 24.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _goCatchUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 88.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(44.w),
                  ),
                ),
                child: Text('去记录鱼获', style: TextStyle(fontSize: 30.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
