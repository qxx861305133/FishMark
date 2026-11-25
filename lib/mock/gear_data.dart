/// @desc 4.x 装备模块 mock 数据（图片为 picsum 占位图）
class MockGear {
  final String name; // 列表标题
  final String? detailName; // 详情页标题（空则用 name）
  final String? shortName; // 组合卡片缩略图名称
  final String brand;
  final String model;
  final String category; // 鱼竿 / 鱼轮 / 路亚饵 / 其他
  final String specLine; // 2.13m · ML · 5～18g
  final String tag; // 状态标签文案（空则不展示）
  final bool limeTag; // 标签是否荧光绿样式
  final String image;

  const MockGear({
    required this.name,
    this.detailName,
    this.shortName,
    required this.brand,
    required this.model,
    required this.category,
    required this.specLine,
    this.tag = '',
    this.limeTag = false,
    required this.image,
  });

  /// 编辑保存后生成更新后的装备
  MockGear copyWith({
    String? name,
    String? detailName,
    String? shortName,
    String? brand,
    String? model,
    String? category,
    String? specLine,
    String? tag,
    bool? limeTag,
    String? image,
  }) {
    return MockGear(
      name: name ?? this.name,
      detailName: detailName ?? this.detailName,
      shortName: shortName ?? this.shortName,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      category: category ?? this.category,
      specLine: specLine ?? this.specLine,
      tag: tag ?? this.tag,
      limeTag: limeTag ?? this.limeTag,
      image: image ?? this.image,
    );
  }
}

/// 详情页规格项
class MockGearSpec {
  final String label;
  final String value;

  const MockGearSpec({required this.label, required this.value});
}

/// 装备组合
class MockGearCombo {
  final String name;
  final String tag;
  final String desc;
  final String cover;
  final List<MockGear> items;
  final String lastUsed;
  final int fishCount;

  const MockGearCombo({
    required this.name,
    required this.tag,
    required this.desc,
    required this.cover,
    required this.items,
    required this.lastUsed,
    required this.fishCount,
  });
}

class GearData {
  /// 4.1.1 分类筛选
  static const List<String> categories = ['全部', '鱼竿', '鱼轮', '路亚饵', '其他'];

  /// 4.1.1 我的装备列表
  static const List<MockGear> gears = [
    MockGear(
      name: '路亚竿 Shimano Expride',
      detailName: 'Shimano Expride',
      brand: 'Shimano',
      model: 'STREAM',
      category: '鱼竿',
      specLine: '2.13m · ML · 5～18g',
      tag: '常用',
      image: 'https://picsum.photos/seed/gear-rod-1/400/400',
    ),
    MockGear(
      name: '路亚竿 Shimano Expride',
      detailName: 'Shimano Expride',
      brand: 'Shimano',
      model: 'STREAM',
      category: '鱼竿',
      specLine: '2.13m · ML · 5～18g',
      tag: '使用中',
      limeTag: true,
      image: 'https://picsum.photos/seed/gear-rod-2/400/400',
    ),
    MockGear(
      name: '路亚竿 Shimano Expride',
      detailName: 'Shimano Expride',
      brand: 'Shimano',
      model: 'STREAM',
      category: '路亚饵',
      specLine: '2.13m · ML · 5～18g',
      tag: '数量 *3',
      image: 'https://picsum.photos/seed/gear-lure-1/400/400',
    ),
    MockGear(
      name: '路亚竿 Shimano Expride',
      detailName: 'Shimano Expride',
      brand: 'Shimano',
      model: 'STREAM',
      category: '鱼竿',
      specLine: '2.13m · ML · 5～18g',
      image: 'https://picsum.photos/seed/gear-rod-3/400/400',
    ),
    MockGear(
      name: '路亚竿 Shimano Expride',
      detailName: 'Shimano Expride',
      brand: 'Shimano',
      model: 'STREAM',
      category: '鱼轮',
      specLine: '2.13m · ML · 5～18g',
      image: 'https://picsum.photos/seed/gear-reel-1/400/400',
    ),
  ];

  /// 4.4.1 可选组合装备（同时用于 4.1.2 组合卡片缩略图）
  static const List<MockGear> comboCandidates = [
    MockGear(
      name: 'STREAM 705ML 路亚竿',
      shortName: 'STREAM 702ML',
      brand: 'Shimano',
      model: 'STREAM 705ML',
      category: '鱼竿',
      specLine: '2.13m · ML · 5–18g',
      tag: '常用',
      image: 'https://picsum.photos/seed/gear-rod-1/400/400',
    ),
    MockGear(
      name: 'Zillion SV 水滴轮',
      shortName: 'Zillion SV 7.1:1',
      brand: 'Daiwa',
      model: 'Zillion SV',
      category: '鱼轮',
      specLine: '7.1:1 · 右手',
      tag: '数量 *3',
      image: 'https://picsum.photos/seed/gear-reel-2/400/400',
    ),
    MockGear(
      name: 'Vision 90 路亚饵',
      shortName: 'Vision90',
      brand: 'Rapala',
      model: 'Vision 90',
      category: '路亚饵',
      specLine: '90mm · 12g',
      tag: '使用中',
      limeTag: true,
      image: 'https://picsum.photos/seed/gear-lure-2/400/400',
    ),
  ];

  /// 4.1.2 装备组合列表
  static const List<MockGearCombo> combos = [
    MockGearCombo(
      name: '溪流轻量组合',
      tag: '常用',
      desc: '溪流小型鱼种，轻量灵敏，适合马口、白条、巧嘴等',
      cover: 'https://picsum.photos/seed/combo-lake-1/750/420',
      items: comboCandidates,
      lastUsed: '11月22日',
      fishCount: 25,
    ),
    MockGearCombo(
      name: '溪流轻量组合',
      tag: '常用',
      desc: '溪流小型鱼种，轻量灵敏，适合马口、白条、巧嘴等',
      cover: 'https://picsum.photos/seed/combo-stream-1/750/420',
      items: comboCandidates,
      lastUsed: '11月22日',
      fishCount: 25,
    ),
  ];

  /// 4.2.1 详情规格（2 行 x 3 列）
  static const List<MockGearSpec> detailSpecs = [
    MockGearSpec(label: '长度', value: '2.13m'),
    MockGearSpec(label: '硬度', value: 'ML'),
    MockGearSpec(label: '重量', value: '5-18g'),
    MockGearSpec(label: '调性', value: 'Fast'),
    MockGearSpec(label: '节数', value: '2'),
    MockGearSpec(label: '软度', value: '110cm'),
  ];

  /// 4.2.1 使用记录
  static const String detailFishCount = '12';
  static const String detailLastUsed = '12月24日';
  static const String detailMoreCount = '+9';
  static const List<String> recordPhotos = [
    'https://picsum.photos/seed/gear-fish-1/240/180',
    'https://picsum.photos/seed/gear-fish-2/240/180',
    'https://picsum.photos/seed/gear-fish-3/240/180',
  ];

  /// 4.2.1 备注
  static const String detailNote =
      '日常主力竿，手感轻盈，使用流畅，适合 5～18g 的常用搭配，主要用于溪流和水库。';

  /// 4.3.1 已上传照片占位
  static const List<String> addPhotos = [
    'https://picsum.photos/seed/gear-add-1/300/300',
    'https://picsum.photos/seed/gear-add-2/300/300',
  ];
}
