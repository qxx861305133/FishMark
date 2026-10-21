import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/http/api.dart';
import 'package:luji_app/models/catch_record.dart';
import 'package:luji_app/pages/report/report_preview.dart';
import 'package:luji_app/pages/upload/catch_upload.dart';
import 'package:luji_app/widgets/empty_widget.dart';
import 'package:luji_app/widgets/net_image.dart';

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
      final result = await Api().get('my_catches');
      if (!mounted) return;
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          setState(() {
            _loading = false;
            _catches.clear();
            for (final item in data) {
              _catches.add(CatchRecord.fromJson(Map<String, dynamic>.from(item)));
            }
          });
        } else {
          setState(() => _loading = false);
        }
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
            fontSize: 36.sp,
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
                    padding: EdgeInsets.fromLTRB(32.w, 24.w, 32.w, 160.w),
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
          SizedBox(height: 48.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 120.w),
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
                minimumSize: Size(320.w, 88.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(44.w),
                ),
              ),
              icon: Icon(Icons.add, size: 36.w),
              label: Text('记录鱼获', style: TextStyle(fontSize: 30.sp)),
            ),
          ),
        ],
      ),
    );
  }

  // 战报卡片
  Widget _buildCatchCard(CatchRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 首图
          NetImage(
            url: (record.images != null && record.images!.isNotEmpty)
                ? record.images!.first
                : null,
            width: 160.w,
            height: 160.w,
            borderRadius: 16.w,
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.fish?.name ?? '未知鱼种',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.w),
                Text(
                  '记录于 ${record.caught_at ?? record.created_at ?? '-'}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                  ),
                ),
                SizedBox(height: 8.w),
                Row(
                  children: [
                    if (record.weight != null)
                      _buildStat('重量', '${record.weight}kg'),
                    SizedBox(width: 24.w),
                    if (record.length != null)
                      _buildStat('长度', '${record.length}cm'),
                  ],
                ),
                if (record.spot?.name != null) ...[
                  SizedBox(height: 8.w),
                  Row(
                    children: [
                      Icon(Icons.place,
                          size: 26.w, color: Constants.TEXT_LIGHT_COLOR),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          record.spot!.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24.sp,
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
              decoration: BoxDecoration(
                color: Constants.HIGHLIGHT_COLOR.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(32.w),
              ),
              child: Text(
                '生成战报',
                style: TextStyle(
                  fontSize: 24.sp,
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
            fontSize: 24.sp,
            color: Constants.TEXT_LIGHT_COLOR,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: Constants.PRIMARY_COLOR,
          ),
        ),
      ],
    );
  }
}
