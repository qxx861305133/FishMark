import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/gear_data.dart';
import 'package:FishMark/pages/gear/gear_add_page.dart';
import 'package:FishMark/pages/gear/gear_combo_add_page.dart';
import 'package:FishMark/pages/gear/gear_detail_page.dart';
import 'package:FishMark/pages/gear/gear_widgets.dart';
import 'package:FishMark/widgets/net_image.dart';

/// @desc 4.1.1 装备 - 我的装备 / 4.1.2 装备 - 装备组合
class GearPage extends StatefulWidget {
  const GearPage({super.key});

  @override
  State<GearPage> createState() => _GearPageState();
}

class _GearPageState extends State<GearPage> {
  int _subIndex = 0; // 0 我的装备 1 装备组合
  int _catIndex = 0;
  // 我的装备列表（详情编辑保存后可更新）
  final List<MockGear> _gears = List.of(GearData.gears);

  bool get _isCombo => _subIndex == 1;

  /// 右上角入口：添加装备 / 新建组合
  void _openAdd() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          _isCombo ? const GearComboAddPage() : const GearAddPage(),
    ));
  }

  /// 装备详情：编辑保存后返回更新列表
  Future<void> _openDetail(MockGear gear) async {
    final updated = await Navigator.of(context).push<MockGear>(
      MaterialPageRoute(builder: (_) => GearDetailPage(gear: gear)),
    );
    if (updated == null || !mounted) return;
    setState(() {
      final i = _gears.indexWhere((g) => identical(g, gear));
      if (i >= 0) _gears[i] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isCombo ? Constants.INPUT_BG : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.w),
            // 顶部：分段切换 + 添加入口
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  GearSegmented(
                    index: _subIndex,
                    onChanged: (i) => setState(() => _subIndex = i),
                  ),
                  const Spacer(),
                  GearAddButton(text: _isCombo ? '新建组合' : '添加装备', onTap: _openAdd),
                ],
              ),
            ),
            // 分类筛选（仅我的装备）
            if (!_isCombo) ...[
              SizedBox(height: 16.w),
              _categoryBar(),
              SizedBox(height: 4.w),
            ],
            Expanded(
              child: _isCombo ? _comboList() : _gearList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 4.1.1 分类筛选行
  Widget _categoryBar() {
    return SizedBox(
      height: 32.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: GearData.categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          return GearCategoryChip(
            text: GearData.categories[index],
            active: index == _catIndex,
            onTap: () => setState(() => _catIndex = index),
          );
        },
      ),
    );
  }

  /// 4.1.1 我的装备列表
  Widget _gearList() {
    final cat = GearData.categories[_catIndex];
    final items = cat == '全部'
        ? _gears
        : _gears.where((g) => g.category == cat).toList();

    if (items.isEmpty) {
      return Center(
        child: Text(
          '暂无该分类装备',
          style: TextStyle(fontSize: 14.sp, color: Constants.GRAY_LIGHT),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 24.w),
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(
        height: 0.5,
        thickness: 0.5,
        color: Constants.BORDER,
        indent: 16.w,
      ),
      itemBuilder: (context, index) {
        final gear = items[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openDetail(gear),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NetImage(
                  url: gear.image,
                  width: 96.w,
                  height: 96.w,
                  borderRadius: 8,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gear.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Constants.INK,
                        ),
                      ),
                      SizedBox(height: 6.w),
                      Text(
                        '${gear.brand} · ${gear.model}',
                        style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
                      ),
                      SizedBox(height: 4.w),
                      Text(
                        gear.specLine,
                        style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
                      ),
                      if (gear.tag.isNotEmpty) ...[
                        SizedBox(height: 8.w),
                        GearTag(text: gear.tag, lime: gear.limeTag),
                      ],
                    ],
                  ),
                ),
                Icon(RemixIcons.arrow_right_s_line,
                    size: 22.w, color: kGearChevron),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 4.1.2 装备组合列表
  Widget _comboList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: GearData.combos.length,
      itemBuilder: (context, index) {
        final combo = GearData.combos[index];
        return _comboCard(combo);
      },
    );
  }

  Widget _comboCard(MockGearCombo combo) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Fluttertoast.showToast(msg: '演示数据，敬请期待'),
      child: Container(
      margin: EdgeInsets.only(bottom: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          SizedBox(
            width: double.infinity,
            height: 96.w,
            child: NetImage(url: combo.cover, borderRadius: 12),
          ),
          SizedBox(height: 12.w),
          // 标题 + 标签
          Row(
            children: [
              Expanded(
                child: Text(
                  combo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Constants.INK,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GearTag(text: combo.tag),
            ],
          ),
          SizedBox(height: 8.w),
          // 描述
          Text(
            combo.desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
          ),
          SizedBox(height: 12.w),
          // 组合装备缩略图
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final gear in combo.items)
                SizedBox(
                  width: 88.w,
                  child: Column(
                    children: [
                      NetImage(
                        url: gear.image,
                        width: 56.w,
                        height: 56.w,
                        borderRadius: 8,
                      ),
                      SizedBox(height: 6.w),
                      Text(
                        gear.shortName ?? gear.model,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: Constants.GRAY),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.w),
          Divider(height: 0.5, thickness: 0.5, color: Constants.BORDER),
          SizedBox(height: 12.w),
          // 底部统计
          Row(
            children: [
              Text('最近使用 ',
                  style: TextStyle(fontSize: 12.sp, color: Constants.GRAY)),
              Text(
                combo.lastUsed,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.INK,
                ),
              ),
              SizedBox(width: 24.w),
              Text('关联鱼获 ',
                  style: TextStyle(fontSize: 12.sp, color: Constants.GRAY)),
              Text(
                '${combo.fishCount}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.INK,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
