/// @desc 3.x 上传/记录模块 mock 数据
class AiFishResultData {
  final String image;
  final int keywordCount;
  final int refCount;
  final String name;
  final String intro;
  final List<String> points;

  const AiFishResultData({
    required this.image,
    required this.keywordCount,
    required this.refCount,
    required this.name,
    required this.intro,
    required this.points,
  });
}

class CatchRecordData {
  final String photo;
  final String species;
  final String length;
  final String weight;
  final String time;
  final String spot;

  const CatchRecordData({
    required this.photo,
    required this.species,
    required this.length,
    required this.weight,
    required this.time,
    required this.spot,
  });
}

/// 我的装备条目（记录渔获内）
class RecordGearItem {
  final String image;
  final String name;
  final String sub;
  final String tag;
  final bool selected;

  const RecordGearItem({
    required this.image,
    required this.name,
    required this.sub,
    required this.tag,
    this.selected = false,
  });
}

/// 常用组合条目（记录渔获内）
class RecordComboItem {
  final String image;
  final String name;
  final String desc;
  final bool selected;

  const RecordComboItem({
    required this.image,
    required this.name,
    required this.desc,
    this.selected = false,
  });
}

/// 常见鱼种（钓点信息内）
class SpotFishItem {
  final String name;
  final String image;

  const SpotFishItem({required this.name, required this.image});
}

class SpotInfoData {
  final List<String> photos;
  final String name;
  final List<String> waterTypes;
  final String selectedType;
  final List<SpotFishItem> fishes;
  final String desc;

  const SpotInfoData({
    required this.photos,
    required this.name,
    required this.waterTypes,
    required this.selectedType,
    required this.fishes,
    required this.desc,
  });
}

class GearFormData {
  final List<String> photos;
  final List<List<String>> rows; // [label, value]
  final String remark;
  final String status;

  const GearFormData({
    required this.photos,
    required this.rows,
    required this.remark,
    required this.status,
  });
}

class ReportData {
  ReportData._();

  /// 相机预览占位图（拍照页 / 识别中背景）
  static const String cameraImage =
      'https://picsum.photos/seed/luji-camera-fish/900/1600';

  /// AI 识鱼识别结果
  static const AiFishResultData aiFishResult = AiFishResultData(
    image: 'https://picsum.photos/seed/luji-fish-id/780/560',
    keywordCount: 5,
    refCount: 26,
    name: '海鲈鱼（花鲈 / 七星鲈）',
    intro: '俗称：七星鲈、寨花、鲈板、鲈鲛，路亚圈简称海鲈，是杭州钱塘江、九堡大桥一带入海口很热门的目标鱼。',
    points: [
      '身体延长侧扁、纺锤形，下颌明显长于上颌，口大，嘴里布满细牙，攻击性强',
      '前鳃盖骨边缘带锯齿、硬刺，摘鱼要小心扎手',
      '背青灰、腹部银白；体侧上方、背鳍散布不规则黑斑（"七星鲈"名字来源），鱼越大黑斑会慢慢变淡变少',
      '分白鲈（斑点清晰）、黑鲈（体色深、斑点模糊）',
      '常见个体 0.5–3kg，野生大个体可达 1m+、15kg 以上',
      '两个背鳍，第一背鳍全是硬棘，第二背鳍软条为主',
    ],
  );

  /// 记录渔获预填数据
  static const CatchRecordData catchRecord = CatchRecordData(
    photo: 'https://picsum.photos/seed/luji-catch-fish/960/640',
    species: '翘嘴（红尾鲌）',
    length: '42.0cm',
    weight: '0.9kg',
    time: '2024年12月25日 15:28',
    spot: '青龙湖水库',
  );

  /// 我的装备
  static const List<RecordGearItem> myGears = [
    RecordGearItem(
      image: 'https://picsum.photos/seed/luji-gear-rod-1/160/160',
      name: '路亚竿 Shimano Expride',
      sub: 'Shimano · STREAM',
      tag: '常用',
      selected: true,
    ),
    RecordGearItem(
      image: 'https://picsum.photos/seed/luji-gear-rod-2/160/160',
      name: '路亚竿 Shimano Expride',
      sub: 'Shimano · STREAM',
      tag: '常用',
      selected: true,
    ),
    RecordGearItem(
      image: 'https://picsum.photos/seed/luji-gear-rod-3/160/160',
      name: '路亚竿 Daiwa Silver Wolf',
      sub: 'Daiwa · AGS',
      tag: '常用',
    ),
  ];

  /// 常用组合
  static const List<RecordComboItem> combos = [
    RecordComboItem(
      image: 'https://picsum.photos/seed/luji-combo-1/160/160',
      name: '溪流轻量组合',
      desc: '溪流小型鱼种，轻量灵敏，适合马口白条等。',
      selected: true,
    ),
    RecordComboItem(
      image: 'https://picsum.photos/seed/luji-combo-2/160/160',
      name: '溪流轻量组合',
      desc: '溪流小型鱼种，轻量灵敏，适合马口白条等。',
    ),
    RecordComboItem(
      image: 'https://picsum.photos/seed/luji-combo-3/160/160',
      name: '水库远投组合',
      desc: '深水远投搜索，适合翘嘴鳜鱼等目标鱼。',
    ),
  ];

  /// 钓点搜索联想
  static const List<String> spotSuggestions = [
    '浙江省杭州市淳安县千岛湖景区',
    '浙江省杭州市淳安县千岛湖景区',
    '浙江省杭州市淳安县千岛湖景区',
    '浙江省杭州市淳安县千岛湖景区',
    '浙江省杭州市淳安县千岛湖景区',
    '浙江省杭州市淳安县千岛湖景区',
  ];

  /// 填写钓点信息
  static const SpotInfoData spotInfo = SpotInfoData(
    photos: [
      'https://picsum.photos/seed/luji-spot-1/400/400',
      'https://picsum.photos/seed/luji-spot-2/400/400',
    ],
    name: '千岛湖大坝外湾',
    waterTypes: ['湖泊', '河流', '水库', '其他'],
    selectedType: '河流',
    fishes: [
      SpotFishItem(
        name: '花鲈',
        image: 'https://picsum.photos/seed/luji-fish-hualu/160/160',
      ),
      SpotFishItem(
        name: '马口鱼',
        image: 'https://picsum.photos/seed/luji-fish-makou/160/160',
      ),
      SpotFishItem(
        name: '麦穗鱼',
        image: 'https://picsum.photos/seed/luji-fish-maisui/160/160',
      ),
    ],
    desc: '溪流小型鱼种，轻量灵敏，适合马口白条等。',
  );

  /// 添加装备
  static const GearFormData gearForm = GearFormData(
    photos: [
      'https://picsum.photos/seed/luji-gear-photo-1/400/400',
      'https://picsum.photos/seed/luji-gear-photo-2/400/400',
    ],
    rows: [
      ['品牌', 'Shimano'],
      ['型号', 'STREAM 702ML'],
      ['长度', '2.13m'],
      ['硬度', 'ML（中轻）'],
      ['调性', 'Fast（快）'],
      ['节数', '3'],
      ['适用饵重', '5-18g'],
      ['适用线号', 'PE 0.6-1.5号'],
      ['购入时间', '2025年12月28日'],
    ],
    remark: '日常主力竿，手感轻盈，使用流畅，适合 5～18g 的常用搭配，主要用于溪流和水库。',
    status: '常用',
  );
}
