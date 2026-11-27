import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/pages/upload/catch_upload.dart';
import 'package:FishMark/widgets/empty_widget.dart';

/// @desc AI识鱼结果页：展示 POST /ai/recognize 的同步识别结果 → 确认鱼种 → 去记录鱼获
class AiFishResultPage extends StatefulWidget {
  // 识别结果（recognition：fish_species / scientific_name / confidence / description / suggestions）
  final Map<String, dynamic> recognition;

  const AiFishResultPage({
    super.key,
    required this.recognition,
  });

  @override
  State<AiFishResultPage> createState() => _AiFishResultPageState();
}

class _AiFishResultPageState extends State<AiFishResultPage> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // 服务端无 fish_species 视为识别失败
    final species = widget.recognition['fish_species'];
    if (species == null || species.toString().isEmpty) {
      _failed = true;
    }
  }

  // 去记录鱼获（携带识别的鱼种名）
  void _goCatchUpload() {
    final fishName = widget.recognition['fish_species']?.toString() ?? '';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatchUploadPage(initialFishName: fishName),
      ),
    );
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
      body: _failed ? _buildFailed() : _buildResult(),
      bottomNavigationBar: _failed ? null : _buildBottomBar(),
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
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
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
        ],
      ),
    );
  }

  // 识别结果
  Widget _buildResult() {
    final recognition = widget.recognition;
    final species = recognition['fish_species'] ?? '未知鱼种';
    final scientificName = recognition['scientific_name'];
    final description = recognition['description'];
    final suggestions = recognition['suggestions'];
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
                species.toString(),
                style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (scientificName != null &&
                  scientificName.toString().isNotEmpty) ...[
                SizedBox(height: 8.w),
                Text(
                  '学名：$scientificName',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                  ),
                ),
              ],
              SizedBox(height: 16.w),
              // 置信度
              if (recognition['confidence'] != null)
                Text(
                  '置信度 ${((double.tryParse(recognition['confidence'].toString()) ?? 0) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.HIGHLIGHT_COLOR,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        // 说明
        if (description != null && description.toString().isNotEmpty) ...[
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
                  '鱼种介绍',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.w),
                Text(
                  description.toString(),
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
        // 作钓建议
        if (suggestions is List && suggestions.isNotEmpty) ...[
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
                  suggestions.map((s) => '· $s').join('\n'),
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Constants.TEXT_DEFAULT_COLOR,
                    height: 1.6,
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
