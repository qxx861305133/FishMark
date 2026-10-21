import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/http/api.dart';
import 'package:luji_app/models/gear.dart';
import 'package:luji_app/pages/upload/gear_upload.dart';
import 'package:luji_app/widgets/empty_widget.dart';
import 'package:luji_app/widgets/net_image.dart';

/// @desc 装备库页：分类Tab + 装备列表 + 组合
class GearLibraryPage extends StatefulWidget {
  const GearLibraryPage({super.key});

  @override
  State<GearLibraryPage> createState() => _GearLibraryPageState();
}

class _GearLibraryPageState extends State<GearLibraryPage> {
  final List<Gear> _gears = [];
  final List<Map<String, dynamic>> _combos = [];
  bool _loading = true;
  // 当前分类
  String _category = 'all';

  static const Map<String, String> _categoryMap = {
    'all': '全部',
    'rod': '路亚竿',
    'reel': '渔轮',
    'line': '鱼线',
    'lure': '拟饵',
    'accessory': '配件',
  };

  @override
  void initState() {
    super.initState();
    _loadGears();
    _loadCombos();
  }

  Future<void> _loadGears() async {
    try {
      final result = await Api().get('gears');
      if (!mounted) return;
      if (result['success'] && result['data'] is List) {
        setState(() {
          _loading = false;
          _gears.clear();
          for (final item in result['data']) {
            _gears.add(Gear.fromJson(Map<String, dynamic>.from(item)));
          }
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('装备列表加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCombos() async {
    try {
      final result = await Api().get('gear_combos');
      if (!mounted) return;
      if (result['success'] && result['data'] is List) {
        setState(() {
          for (final item in result['data']) {
            _combos.add(Map<String, dynamic>.from(item));
          }
        });
      }
    } catch (e) {
      LogUtil.e('装备组合加载失败: $e');
    }
  }

  // 当前分类下的装备
  List<Gear> get _filteredGears {
    if (_category == 'all') return _gears;
    return _gears.where((gear) => gear.category == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('装备库', style: TextStyle(fontSize: 34.sp)),
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GearUploadPage()),
              );
              _loadGears();
            },
            child: Text(
              '+ 添加',
              style: TextStyle(
                fontSize: 28.sp,
                color: Constants.PRIMARY_COLOR,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 分类Tab
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 24.w),
                  child: SizedBox(
                    height: 72.w,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _categoryMap.entries.map((entry) {
                        final selected = _category == entry.key;
                        return Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: selected,
                            selectedColor: Constants.PRIMARY_COLOR,
                            backgroundColor: Constants.BG_COLOR,
                            labelStyle: TextStyle(
                              fontSize: 26.sp,
                              color: selected
                                  ? Colors.white
                                  : Constants.TEXT_SECONDARY_COLOR,
                            ),
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => _category = entry.key),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // 装备列表
                Expanded(
                  child: _filteredGears.isEmpty && _combos.isEmpty
                      ? const EmptyWidget(text: '装备库还是空的，添加第一件装备吧',
                          icon: Icons.build_outlined)
                      : ListView(
                          padding: EdgeInsets.fromLTRB(
                              32.w, 24.w, 32.w, 160.w),
                          children: [
                            if (_filteredGears.isNotEmpty) ...[
                              ..._filteredGears.map(_buildGearCard),
                              SizedBox(height: 32.w),
                            ],
                            // 装备组合
                            if (_combos.isNotEmpty) ...[
                              Text(
                                '我的装备组合',
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 16.w),
                              ..._combos.map(_buildComboCard),
                            ],
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  // 装备卡片
  Widget _buildGearCard(Gear gear) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Row(
        children: [
          NetImage(
            url: (gear.images != null && gear.images!.isNotEmpty)
                ? gear.images!.first
                : null,
            width: 140.w,
            height: 140.w,
            borderRadius: 16.w,
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${gear.brand ?? ''} ${gear.model ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.w),
                Text(
                  _categoryMap[gear.category] ?? '装备',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Constants.TEXT_LIGHT_COLOR,
                  ),
                ),
                SizedBox(height: 8.w),
                Row(
                  children: [
                    if (gear.price != null)
                      Text(
                        '¥${gear.price}',
                        style: TextStyle(
                          fontSize: 26.sp,
                          color: Constants.HIGHLIGHT_COLOR,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    SizedBox(width: 24.w),
                    Text(
                      '使用${gear.usage_count ?? 0}次 · 渔获${gear.catch_count ?? 0}尾',
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

  // 组合卡片
  Widget _buildComboCard(Map<String, dynamic> combo) {
    return GestureDetector(
      onTap: () {
        Fluttertoast.showToast(msg: '组合详情开发中');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Constants.PRIMARY_COLOR.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24.w),
        ),
        child: Row(
          children: [
            Icon(Icons.category_outlined,
                size: 48.w, color: Constants.PRIMARY_COLOR),
            SizedBox(width: 24.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    combo['name'] ?? '未命名组合',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (combo['description'] != null) ...[
                    SizedBox(height: 8.w),
                    Text(
                      combo['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Constants.TEXT_SECONDARY_COLOR,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
