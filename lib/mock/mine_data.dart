// @desc 我的 / 订阅模块 mock 数据（1104 设计稿）
import 'package:FishMark/mock/design_data.dart';

/// 我的图鉴鱼种
class GalleryFish {
  final String name;
  final String image;

  const GalleryFish({required this.name, required this.image});
}

/// 我的勋章
class MineMedal {
  final String title;
  final MedalStyle style;

  const MineMedal({required this.title, required this.style});
}

/// 时间轴事件类型
enum TimelineType { record, spot, medal }

/// 时间轴富文本片段
class TimelineSeg {
  final String text;
  final bool bold;

  const TimelineSeg(this.text, {this.bold = false});
}

/// 时间轴事件
class TimelineEvent {
  final TimelineType type;
  final String? image;
  final List<TimelineSeg> title;
  final String date;

  const TimelineEvent({
    required this.type,
    this.image,
    required this.title,
    required this.date,
  });
}

/// 设置项
class SettingsItem {
  final String icon;
  final String label;
  final String? value;

  const SettingsItem(this.icon, this.label, {this.value});
}

/// 设置分组
class SettingsGroup {
  final List<SettingsItem> items;

  const SettingsGroup(this.items);
}

/// 计量单位选项
class UnitOption {
  final String code; // 图标上的单位文案
  final String label; // 公制 / 英制

  const UnitOption({required this.code, required this.label});
}

/// 计量单位分组
class UnitGroup {
  final String title;
  final List<UnitOption> options;

  const UnitGroup({required this.title, required this.options});
}

/// 会员套餐卡
class VipPlan {
  final String name;
  final String desc;

  const VipPlan({required this.name, required this.desc});
}

/// 会员计费周期
class VipBilling {
  final String name;
  final String price;
  final String unit;

  const VipBilling({required this.name, required this.price, required this.unit});
}

/// 会员权益
class VipBenefit {
  final String label;

  const VipBenefit(this.label);
}

class MineData {
  /// 头部统计
  static const stats = [
    {'value': '128', 'label': '累计渔获'},
    {'value': '28', 'label': '解锁鱼种'},
    {'value': '285.6kg', 'label': '累计重量'},
    {'value': '24.8cm', 'label': '最大渔获'},
  ];

  /// 我的图鉴（横滑）
  static final gallery = [
    const GalleryFish(name: '花鲈鱼', image: 'https://picsum.photos/seed/luji-fish-a/240/240'),
    const GalleryFish(name: '马口鱼', image: 'https://picsum.photos/seed/luji-fish-b/240/240'),
    const GalleryFish(name: '麦穗鱼', image: 'https://picsum.photos/seed/luji-fish-c/240/240'),
    const GalleryFish(name: '海鲈鱼', image: 'https://picsum.photos/seed/luji-fish-d/240/240'),
    const GalleryFish(name: '翘嘴鲌', image: 'https://picsum.photos/seed/luji-fish-e/240/240'),
    const GalleryFish(name: '鳜鱼', image: 'https://picsum.photos/seed/luji-fish-f/240/240'),
  ];

  /// 我的勋章
  static const medals = [
    MineMedal(title: '精准猎手挑战', style: MedalStyle.bronze),
    MineMedal(title: '年度鱼种挑战', style: MedalStyle.blue),
    MineMedal(title: '月度鱼获挑战', style: MedalStyle.gold),
    MineMedal(title: '月度鱼获挑战', style: MedalStyle.blue),
  ];

  /// 我的时间轴
  static final timeline = [
    const TimelineEvent(
      type: TimelineType.record,
      image: 'https://picsum.photos/seed/luji-tl-1/240/240',
      title: [TimelineSeg('25 ', bold: true), TimelineSeg('鱼获')],
      date: '2026年 12月22日 13:58:01',
    ),
    const TimelineEvent(
      type: TimelineType.spot,
      title: [TimelineSeg('发现新钓点')],
      date: '2026年 12月22日 13:58:01',
    ),
    const TimelineEvent(
      type: TimelineType.medal,
      title: [
        TimelineSeg('完成'),
        TimelineSeg('“精准猎手挑战”', bold: true),
        TimelineSeg('获得成就徽章'),
      ],
      date: '2026年 12月22日 13:58:01',
    ),
    const TimelineEvent(
      type: TimelineType.record,
      image: 'https://picsum.photos/seed/luji-tl-2/240/240',
      title: [
        TimelineSeg('刷新了'),
        TimelineSeg('“海鲈鱼”', bold: true),
        TimelineSeg('渔获记录'),
      ],
      date: '2026年 12月22日 13:58:01',
    ),
    const TimelineEvent(
      type: TimelineType.spot,
      title: [TimelineSeg('发现新钓点')],
      date: '2026年 12月22日 13:58:01',
    ),
  ];

  /// 用户（复用设计稿 mock）
  static MockUser get user => DesignData.user;

  /// 5.2.1 更多设置分组
  static const settingsGroups = [
    SettingsGroup([
      SettingsItem('user_settings', '个人资料'),
    ]),
    SettingsGroup([
      SettingsItem('unit', '计量单位'),
      SettingsItem('language', '多语言', value: '中文（简体）'),
      SettingsItem('notification', '通知设置'),
    ]),
    SettingsGroup([
      SettingsItem('feedback', '帮助与反馈'),
      SettingsItem('about', '关于路记'),
    ]),
    SettingsGroup([
      SettingsItem('share', '分享给朋友'),
      SettingsItem('score', '去评分'),
      SettingsItem('version', '版本更新', value: '版本号 2.1.1'),
    ]),
    SettingsGroup([
      SettingsItem('logout', '退出登录'),
    ]),
  ];

  /// 5.3.3 计量单位分组
  static const unitGroups = [
    UnitGroup(
      title: '深度 / 距离',
      options: [UnitOption(code: 'M', label: '公制'), UnitOption(code: 'FT', label: '英制')],
    ),
    UnitGroup(
      title: '重量',
      options: [UnitOption(code: 'KG', label: '公制'), UnitOption(code: 'LB', label: '英制')],
    ),
    UnitGroup(
      title: '尺寸',
      options: [UnitOption(code: 'M', label: '公制'), UnitOption(code: 'FT', label: '英制')],
    ),
    UnitGroup(
      title: '气瓶压力',
      options: [UnitOption(code: 'BAR', label: '公制'), UnitOption(code: 'PSI', label: '英制')],
    ),
    UnitGroup(
      title: '温度',
      options: [UnitOption(code: '°C', label: '公制'), UnitOption(code: '°F', label: '英制')],
    ),
  ];

  /// 5.3.9 版本更新文案
  static const updateTitle = '发现新版本';
  static const updateNotes = [
    '新增渔获相册，支持批量管理',
    '优化钓点地图加载速度',
    '修复已知问题，提升稳定性',
  ];
  static const updateButton = '立即更新（约 48 MB）';

  /// 5.x 帮助与反馈 - 常见问题（首页数据）
  static const faqs = [
    {'q': '如何记录一次渔获？', 'a': '点击底部“上传”按钮，拍照或从相册选择鱼获照片，填写重量、钓点等信息后提交即可。'},
    {'q': '如何解锁鱼种图鉴？', 'a': '每次记录渔获时，AI 会自动识别鱼种并计入您的图鉴收集进度。'},
    {'q': '如何修改计量单位？', 'a': '前往“我的 > 更多设置 > 计量单位”，在公制与英制之间切换。'},
    {'q': '会员权益包含哪些内容？', 'a': '无限渔获记录、私密钓点、更多 AI 识鱼额度、AI 语音等专属权益。'},
    {'q': '如何联系客服？', 'a': '您可以通过“帮助与反馈”提交问题，或发送邮件至 support@luji.cn。'},
  ];

  /// 帮助页上拉加载：按页码生成模拟 FAQ
  static List<Map<String, String>> moreFaqs(int page) {
    return List.generate(5, (i) {
      final n = page * 5 + i + 1;
      return {
        'q': '常见问题 #$n',
        'a': '这是第 $n 条模拟加载的常见问题答案，用于演示上拉加载更多（数据为 mock）。',
      };
    });
  }

  /// 6.1 会员中心
  static const vipPlans = [
    VipPlan(name: '体验版', desc: '功能说明简介文案待替换'),
    VipPlan(name: 'Pro 专业版', desc: '功能说明简介文案待替换'),
    VipPlan(name: 'Master 大师版', desc: '功能说明简介文案待替换'),
  ];

  static const vipBillings = [
    VipBilling(name: '月度会员', price: '29', unit: '/月'),
    VipBilling(name: '年度会员', price: '299', unit: '/月'),
  ];

  static const vipBenefits = [
    VipBenefit('无限渔获记录'),
    VipBenefit('私密钓点'),
    VipBenefit('更多AI识鱼额度'),
    VipBenefit('AI语音'),
    VipBenefit('专属活动'),
    VipBenefit('高阶荣誉'),
  ];
}
