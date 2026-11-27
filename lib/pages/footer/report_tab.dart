import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/catch_record.dart';
import 'package:FishMark/pages/report/report_preview.dart';
import 'package:FishMark/pages/upload/catch_upload.dart';
import 'package:FishMark/widgets/empty_widget.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 战报Tab：我的鱼获战报列表 + 生成分享卡
class ReportTab extends StatefulWidget {
  const ReportTab({super.key});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  final List<CatchRecord> _catches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCatches();
  }

  Future<void> _loadCatches() async {
    try {
      // GET /catches：当前用户的鱼获列表
      final result = await Api().get('catches', queryParameters: {
        'page': 1,
        'per_page': 20,
        if (Global.profile.user?.uid != null)
          'user_id': Global.profile.user!.uid,
      });
      if (!mounted) return;
      if (result['success'] == true && result['data'] is List) {
        setState(() {
          _loading = false;
          _catches.clear();
          for (final item in result['data']) {
            _catches.add(
                CatchRecord.fromApi(Map<String, dynamic>.from(item)));
          }
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('战报列表加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '战报',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _catches.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadCatches,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 80.w),
                    itemCount: _catches.length,
                    itemBuilder: (context, index) =>
                        _buildCatchCard(_catches[index]),
                  ),
                ),
    );
  }

  // 空态：引导去记录鱼获
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyWidget(text: '还没有战报，去记录你的第一尾鱼获吧', icon: Icons.description_outlined),
          SizedBox(height: 24.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60.w),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CatchUploadPage()),
                );
                _loadCatches();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.PRIMARY_COLOR,
                foregroundColor: Colors.white,
                minimumSize: Size(160.w, 44.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.w),
                ),
              ),
              icon: Icon(Icons.add, size: 18.w),
              label: Text('记录鱼获', style: TextStyle(fontSize: 15.sp)),
            ),
          ),
        ],
      ),
    );
  }

  // 战报卡片
  Widget _buildCatchCard(CatchRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 首图
          NetImage(
            url: (record.images != null && record.images!.isNotEmpty)
                ? record.images!.first
                : null,
            width: 80.w,
            height: 80.w,
            borderRadius: 8.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.fish?.name ?? '未知鱼种',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.w),
                Text(
                  '记录于 ${record.caught_at ?? record.created_at ?? '-'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                  ),
                ),
                SizedBox(height: 4.w),
                Row(
                  children: [
                    if (record.weight != null)
                      _buildStat('重量', '${record.weight}kg'),
                    SizedBox(width: 12.w),
                    if (record.length != null)
                      _buildStat('长度', '${record.length}cm'),
                  ],
                ),
                if (record.spot?.name != null) ...[
                  SizedBox(height: 4.w),
                  Row(
                    children: [
                      Icon(Icons.place,
                          size: 13.w, color: Constants.TEXT_LIGHT_COLOR),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          record.spot!.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Constants.TEXT_SECONDARY_COLOR,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 生成战报按钮
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReportPreviewPage(record: record),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.w),
              decoration: BoxDecoration(
                color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.w),
              ),
              child: Text(
                '生成战报',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Constants.HIGHLIGHT_COLOR,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 数据小项
  Widget _buildStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 12.sp,
            color: Constants.TEXT_LIGHT_COLOR,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Constants.PRIMARY_COLOR,
          ),
        ),
      ],
    );
  }
}
