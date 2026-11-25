/// @desc 探索模块 mock 数据（2.1 探索 / 2.2 鱼种图鉴）
class ExploreStats {
  final int waters; // 附近水域
  final int spots; // 附近钓点
  final int catches; // 附近渔获

  const ExploreStats({
    required this.waters,
    required this.spots,
    required this.catches,
  });
}

/// 钓点记录（地图详情 - 渔获打卡）
class ExploreRecord {
  final String user;
  final String avatar;
  final String date; // 记录日期
  final String fishName; // 渔获鱼种
  final String weight; // 重量
  final String photo; // 渔获照片

  const ExploreRecord({
    required this.user,
    required this.avatar,
    required this.date,
    required this.fishName,
    required this.weight,
    required this.photo,
  });
}

/// 附近钓点
class ExploreSpot {
  final String name;
  final String areaLabel; // 水域面积文案
  final String? badge; // 「路记」标记
  final List<String> tags; // 常见鱼种
  final String thumb; // 列表缩略图
  final double x; // 地图 pin 位置（0~1）
  final double y;
  final ExploreRecord record;

  const ExploreSpot({
    required this.name,
    required this.areaLabel,
    required this.tags,
    required this.thumb,
    required this.x,
    required this.y,
    required this.record,
    this.badge,
  });
}

String _img(String seed, int w, int h) =>
    'https://picsum.photos/seed/$seed/$w/$h';

const exploreStats = ExploreStats(waters: 184, spots: 26, catches: 109);

final List<ExploreSpot> exploreSpots = _buildBaseSpots();

List<ExploreSpot> _buildBaseSpots() {
  return [
    ExploreSpot(
      name: '环站北路花园府',
      areaLabel: '水域面积: 1.28 km²',
      badge: '路记',
      tags: ['花鲈', '马口鱼', '麦穗鱼', '麦穗鱼'],
      thumb: _img('lj-dam-1', 300, 300),
      x: 0.78,
      y: 0.16,
      record: ExploreRecord(
        user: '路亚玩家',
        avatar: _img('lj-avatar-1', 120, 120),
        date: '2026年12月22日',
        fishName: '马口鱼',
        weight: '6.25kg',
        photo: _img('lj-catch-1', 900, 460),
      ),
    ),
    for (var i = 2; i <= 6; i++)
      ExploreSpot(
        name: '浙江省杭州市西湖区双浦镇郑家路',
        areaLabel: '水域面积: 1.28 km²',
        tags: ['花鲈', '马口鱼', '麦穗鱼'],
        thumb: _img('lj-dam-$i', 300, 300),
        x: 0.18 + 0.13 * i,
        y: 0.30 + 0.09 * (i % 3),
        record: ExploreRecord(
          user: '路亚玩家',
          avatar: _img('lj-avatar-$i', 120, 120),
          date: '2026年12月2$i日',
          fishName: '马口鱼',
          weight: '4.2kg',
          photo: _img('lj-catch-$i', 900, 460),
        ),
      ),
  ];
}

/// 模拟上拉加载：从 startIndex 起追加 count 个钓点
List<ExploreSpot> makeMoreSpots(int startIndex, int count) {
  return [
    for (var i = 0; i < count; i++)
      ExploreSpot(
        name: '附近钓点 #${startIndex + i + 1}',
        areaLabel: '水域面积: 1.28 km²',
        tags: ['花鲈', '马口鱼', '麦穗鱼'],
        thumb: _img('lj-spot-${startIndex + i}', 300, 300),
        x: 0.08 + ((startIndex + i) * 0.17) % 0.84,
        y: 0.10 + ((startIndex + i) * 0.23) % 0.62,
        record: ExploreRecord(
          user: '路亚玩家',
          avatar: _img('lj-avatar-${startIndex + i}', 120, 120),
          date: '2026年11月${((startIndex + i) % 28) + 1}日',
          fishName: '马口鱼',
          weight: '3.8kg',
          photo: _img('lj-catch-${startIndex + i}', 900, 460),
        ),
      ),
  ];
}

/// 模拟下拉刷新：重置为初始数据
void resetExploreSpots() {
  exploreSpots
    ..clear()
    ..addAll(_buildBaseSpots());
}

/// 鱼种图鉴 - 新鱼种（2.2.2）
class NewFishRecord {
  final String bgImage; // 背景模糊图
  final String heroImage; // 主图
  final String name; // 鱼名
  final String length; // 长度
  final String weight; // 重量
  final String place; // 地点
  final String date; // 日期
  final String achievement; // 成就名
  final String achievementDesc; // 成就描述

  const NewFishRecord({
    required this.bgImage,
    required this.heroImage,
    required this.name,
    required this.length,
    required this.weight,
    required this.place,
    required this.date,
    required this.achievement,
    required this.achievementDesc,
  });
}

const newFishRecord = NewFishRecord(
  bgImage: _guideBg,
  heroImage: _guideHero,
  name: '贝加尔雅罗鱼',
  length: '17.31cm',
  weight: '4.2kg',
  place: '杭州市 · 富春江水域',
  date: '2025年12月23日',
  achievement: '钓鱼大师',
  achievementDesc: '钓到超过 5kg 的马口鱼获得成就',
);

const _guideBg = 'https://picsum.photos/seed/lj-guide-bg/780/1692';
const _guideHero = 'https://picsum.photos/seed/lj-hero-fish/640/740';
