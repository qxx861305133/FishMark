/// @desc 1104 设计稿本地 mock 数据
class MockUser {
  final String name;
  final String level;
  final String badge;
  final String location;
  final String avatar;

  const MockUser({
    required this.name,
    required this.level,
    required this.badge,
    required this.location,
    required this.avatar,
  });
}

class MockChallenge {
  final String title;
  final String goal; // 目标文案，如 "125 条马口鱼"
  final int current;
  final int total;
  final MedalStyle style;
  final ChallengeStatus status;
  final String? grantedDate; // 已领取日期

  const MockChallenge({
    required this.title,
    required this.goal,
    required this.current,
    required this.total,
    required this.style,
    required this.status,
    this.grantedDate,
  });
}

enum MedalStyle { bronze, silver, gold, blue }

enum ChallengeStatus { claimable, claimed, inProgress }

class MockFeed {
  final String userName;
  final String avatar;
  final String date;
  final String image;
  final String fishName;
  final String weight;
  final String length;
  final String location;
  int likes;
  final int comments;
  bool liked;

  MockFeed({
    required this.userName,
    required this.avatar,
    required this.date,
    required this.image,
    required this.fishName,
    required this.weight,
    required this.length,
    required this.location,
    required this.likes,
    required this.comments,
    this.liked = false,
  });
}

class MockOfficialMessage {
  final String title;
  final String content;
  final String date;
  final bool unread;

  const MockOfficialMessage({
    required this.title,
    required this.content,
    required this.date,
    this.unread = false,
  });
}

class MockLikeMessage {
  final String userName;
  final String avatar;
  final String action;
  final String date;

  const MockLikeMessage({
    required this.userName,
    required this.avatar,
    required this.action,
    required this.date,
  });
}

class DesignData {
  static const user = MockUser(
    name: '路亚玩家',
    level: 'Lv.5',
    badge: '路亚先锋',
    location: '浙江 · 杭州',
    avatar: 'https://picsum.photos/seed/luji-avatar/120/120',
  );

  static final challenges = [
    MockChallenge(
      title: '精准猎手挑战',
      goal: '125 条马口鱼',
      current: 25,
      total: 25,
      style: MedalStyle.bronze,
      status: ChallengeStatus.claimable,
    ),
    MockChallenge(
      title: '年度鱼种挑战',
      goal: '125 条马口鱼',
      current: 5,
      total: 25,
      style: MedalStyle.blue,
      status: ChallengeStatus.claimed,
      grantedDate: '2026.12.22 获得',
    ),
    MockChallenge(
      title: '月度鱼获挑战',
      goal: '125 条马口鱼',
      current: 5,
      total: 25,
      style: MedalStyle.gold,
      status: ChallengeStatus.claimed,
      grantedDate: '2026.12.22 获得',
    ),
    MockChallenge(
      title: '溪流猎手挑战',
      goal: '60 条白条鱼',
      current: 42,
      total: 60,
      style: MedalStyle.silver,
      status: ChallengeStatus.claimable,
    ),
    MockChallenge(
      title: '夜钓王者挑战',
      goal: '30 条翘嘴鱼',
      current: 18,
      total: 30,
      style: MedalStyle.blue,
      status: ChallengeStatus.inProgress,
    ),
    MockChallenge(
      title: '大物猎人挑战',
      goal: '10 条鳜鱼',
      current: 10,
      total: 10,
      style: MedalStyle.gold,
      status: ChallengeStatus.claimable,
    ),
    MockChallenge(
      title: '全能钓手挑战',
      goal: '200 条鱼获',
      current: 86,
      total: 200,
      style: MedalStyle.bronze,
      status: ChallengeStatus.inProgress,
    ),
  ];

  /// 徽章列表页（3 列网格）
  static final medalGrid = [
    ...challenges,
    for (int i = 0; i < 9; i++)
      MockChallenge(
        title: i % 3 == 0
            ? '精准猎手挑战'
            : i % 3 == 1
                ? '年度鱼种挑战'
                : '月度鱼获挑战',
        goal: '125 条马口鱼',
        current: 5,
        total: 25,
        style: MedalStyle.silver,
        status: ChallengeStatus.inProgress,
      ),
  ];

  static final feeds = [
    MockFeed(
      userName: '路亚玩家',
      avatar: 'https://picsum.photos/seed/luji-avatar/80/80',
      date: '2026年12月22日 记录',
      image: 'https://picsum.photos/seed/luji-fish1/750/500',
      fishName: '马口鱼',
      weight: '6.25kg',
      length: '16.34cm',
      location: '杭州市 · 富春江水域',
      likes: 2580,
      comments: 224,
    ),
    MockFeed(
      userName: '路亚玩家',
      avatar: 'https://picsum.photos/seed/luji-avatar/80/80',
      date: '2026年12月22日 记录',
      image: 'https://picsum.photos/seed/luji-fish2/750/500',
      fishName: '翘嘴鲌',
      weight: '3.10kg',
      length: '42.50cm',
      location: '湖州市 · 千岛湖',
      likes: 1024,
      comments: 86,
    ),
  ];

  static const officialMessages = [
    MockOfficialMessage(
      title: '官方通知消息标题文案待替换',
      content: '官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换...',
      date: '2026年12月22日 18:34',
      unread: true,
    ),
    MockOfficialMessage(
      title: '官方通知消息标题文案待替换',
      content: '官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换...',
      date: '2026年12月22日 18:34',
      unread: true,
    ),
    MockOfficialMessage(
      title: '官方通知消息标题文案待替换',
      content: '官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换...',
      date: '2026年12月22日 18:34',
    ),
    MockOfficialMessage(
      title: '官方通知消息标题文案待替换',
      content: '官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换官方通知消息正文描述文案待替换...',
      date: '2026年12月22日 18:34',
    ),
  ];

  static final likeMessages = [
    const MockLikeMessage(
      userName: '路亚玩家',
      avatar: 'https://picsum.photos/seed/luji-avatar/80/80',
      action: '赞了你的渔获「马口鱼」',
      date: '2026年12月22日 18:34',
    ),
    const MockLikeMessage(
      userName: '钓鱼老王',
      avatar: 'https://picsum.photos/seed/luji-wang/80/80',
      action: '赞了你的渔获「翘嘴鲌」',
      date: '2026年12月22日 16:02',
    ),
  ];
}
