import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/gear_data.dart';
import 'package:FishMark/pages/gear/gear_add_page.dart';
import 'package:FishMark/pages/gear/gear_widgets.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 4.2.1 装备详情
class GearDetailPage extends StatefulWidget {
  final MockGear gear;

  const GearDetailPage({super.key, required this.gear});

  @override
  State<GearDetailPage> createState() => _GearDetailPageState();
}

class _GearDetailPageState extends State<GearDetailPage> {
  late MockGear _gear = widget.gear;

  /// 编辑装备：进入编辑页（回填），保存后更新详情
  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<MockGear>(
      MaterialPageRoute(builder: (_) => GearAddPage(gear: _gear)),
    );
    if (updated != null && mounted) {
      setState(() => _gear = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gear = _gear;
    // 任意方式返回（关闭按钮/侧滑/系统返回）时，把当前装备数据回传给列表页
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_gear);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // 可滚动内容
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(top: 8.w, bottom: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 产品大图
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40.w, vertical: 8.w),
                              child: NetImage(
                                url: gear.image,
                                width: double.infinity,
                                height: 220.w,
                                borderRadius: 12,
                              ),
                            ),
                            // 标题 + 状态
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gear.detailName ?? gear.name,
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Constants.INK,
                                    ),
                                  ),
                                  SizedBox(height: 10.w),
                                  Row(
                                    children: [
                                      if (gear.tag.isNotEmpty) ...[
                                        GearTag(
                                            text: gear.tag,
                                            lime: gear.limeTag),
                                        SizedBox(width: 10.w),
                                      ],
                                      Expanded(
                                        child: Text(
                                          '${gear.category} · ${gear.brand} · ${gear.model}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Constants.GRAY),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.w),
                            // 规格参数（2 行 x 3 列）
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                children: [
                                  for (int r = 0; r < 2; r++) ...[
                                    if (r > 0) SizedBox(height: 12.w),
                                    Row(
                                      children: [
                                        for (int c = 0; c < 3; c++) ...[
                                          if (c > 0) SizedBox(width: 12.w),
                                          Expanded(
                                            child: _specCard(GearData
                                                .detailSpecs[r * 3 + c]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: 24.w),
                            // 使用记录
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                '使用记录',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Constants.INK,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.w),
                            _statsRow(),
                            SizedBox(height: 16.w),
                            // 鱼获照片
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  for (final url in GearData.recordPhotos)
                                    NetImage(
                                      url: url,
                                      width: 82.w,
                                      height: 58.w,
                                      borderRadius: 8,
                                    ),
                                  Container(
                                    width: 82.w,
                                    height: 58.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Constants.INPUT_BG,
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      GearData.detailMoreCount,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: kGearChipText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.w),
                            // 备注
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                GearData.detailNote,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.6,
                                  color: Constants.INK,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 关闭按钮：固定顶部，浮在内容上方不随内容滚动
                    Positioned(
                      top: 8.w,
                      left: 16.w,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(RemixIcons.close_line,
                              size: 18.w, color: Constants.INK),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // 底部操作
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GhostButton(
                        text: '编辑装备',
                        height: 48,
                        onPressed: _edit,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: InkButton(
                        text: '加入组合',
                        height: 48,
                        onPressed: () => Fluttertoast.showToast(msg: '演示环境暂不支持'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// 规格卡片
  Widget _specCard(MockGearSpec spec) {
    return Container(
      height: 60.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Constants.INPUT_BG,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spec.label,
            style: TextStyle(fontSize: 12.sp, color: kGearSpecLabel),
          ),
          SizedBox(height: 5.w),
          Text(
            spec.value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Constants.INK,
            ),
          ),
        ],
      ),
    );
  }

  /// 关联鱼获 / 最近使用 统计
  Widget _statsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _stat(RemixIcons.anchor_line, '关联鱼获',
                GearData.detailFishCount),
          ),
          Container(width: 1, height: 36.w, color: Constants.BORDER),
          Expanded(
            child: _stat(RemixIcons.history_line, '最近使用',
                GearData.detailLastUsed),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.w, color: Constants.INK),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(fontSize: 13.sp, color: Constants.GRAY)),
          ],
        ),
        SizedBox(height: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Constants.INK,
          ),
        ),
      ],
    );
  }
}

