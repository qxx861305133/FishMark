import 'package:FishMark/config/log_util.dart';

/// @desc 本地模拟数据（Constants.useMock = true 时接管全部接口）
/// 所有状态保存在内存中，模拟一次完整的用户会话：
/// 登录 → 初始化 → 首页浏览/点赞 → 记录鱼获 → 生成战报 → 挑战 → 勋章 → 订阅
class MockApi {
  // 模拟网络延迟
  static Future<Map<String, dynamic>> handle(
    String pathName, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    LogUtil.v('🧪 Mock处理 >>>>> $pathName data=$data query=$query');
    switch (pathName) {
      // 启动与通用
      case 'initial_settings':
        return _ok({'ad_open': false, 'min_version': '1.0.0'});
      case 'agreement':
        return _ok({'title': '用户协议与隐私政策', 'content': '模拟协议内容'});
      case 'regions':
        return _ok([
          {'name': '浙江省'},
          {'name': '江苏省'},
          {'name': '广东省'},
          {'name': '湖北省'},
          {'name': '四川省'},
        ]);
      case 'interests':
        return _ok([
          {'name': '翘嘴'},
          {'name': '鲈鱼'},
          {'name': '鳜鱼'},
          {'name': '黑鱼'},
          {'name': '马口'},
          {'name': '青稍'},
        ]);

      // 用户系统
      case 'send_sms':
        return _ok(null, message: '验证码已发送（模拟：任意6位数字均可登录）');
      case 'sms_login':
        return _ok({
          'token': 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
          'user': _loginUser,
        });
      case 'user_info':
        return _ok(_loginUser);
      case 'user_update':
        _loginUser.addAll(data ?? {});
        return _ok(_loginUser);
      case 'user_init_profile':
        _loginUser['region'] = data?['region'];
        _loginUser['interests'] = data?['interests'];
        return _ok(null, message: '初始化完成');

      // 首页
      case 'banners':
        return _ok(_banners);
      case 'home_feeds':
        return _ok(_feeds);
      case 'feed_like':
        final rid = data?['rid'];
        for (final feed in _feeds) {
          if (feed['rid'] == rid) {
            feed['liked'] = !(feed['liked'] ?? false);
            feed['likes'] = (feed['likes'] ?? 0) + (feed['liked'] ? 1 : -1);
            return _ok({'liked': feed['liked'], 'likes': feed['likes']});
          }
        }
        return _fail('动态不存在');
      case 'feed_comments':
        return _ok([
          {
            'user': {'nickname': '老张爱路亚', 'avatar': _img('avatar2', 100)},
            'content': '这个标点我也常去，下午口不错！',
            'created_at': '2026-10-18 20:12',
          },
        ]);
      case 'feed_comment':
        return _ok(null, message: '评论成功');

      // 探索
      case 'spots':
        return _ok(_spots);
      case 'spot_map':
        return _ok(_spots);
      case 'spot_detail':
        return _ok(_findById(_spots, query?['rid']) ?? _spots.first);
      case 'spot_reviews':
        return _ok(_spotReviews);
      case 'spot_submit':
        _spots.insert(0, {
          'rid': 'sp${_spots.length + 1}',
          'name': data?['name'],
          'address': data?['address'],
          'type': data?['type'] ?? 'river',
          'lat': data?['lat'],
          'lng': data?['lng'],
          'fee': data?['fee'],
          'open_time': data?['open_time'],
          'rating': 0,
          'reviews_count': 0,
          'cover': _img('spot-new${_spots.length}', 640, 420),
          'fish_names': ['翘嘴', '马口'],
        });
        return _ok(null, message: '钓点提交成功，感谢分享');
      case 'fish_species':
        return _ok(_species);
      case 'fish_species_detail':
        return _ok(_findById(_species, query?['rid']) ?? _species.first);

      // 上传
      case 'catch_submit':
        final record = {
          'rid': 'c${_catches.length + 1}',
          'uid': 'u001',
          'fish': {'name': data?['fish_name'] ?? '未知鱼种'},
          'weight': data?['weight'],
          'length': data?['length'],
          'notes': data?['notes'],
          'weather': data?['weather'],
          'caught_at': data?['caught_at'],
          'images': data?['images'] ?? [],
          'status': 'normal',
          'created_at': _now(),
        };
        _catches.insert(0, record);
        return _ok(record, message: '鱼获记录成功');
      case 'catch_detail':
        return _ok(_findById(_catches, query?['rid']));
      case 'catch_delete':
        _catches.removeWhere((c) => c['rid'] == data?['rid']);
        return _ok(null, message: '已删除');

      // AI识鱼（百炼模拟：直接返回完成态结果）
      case 'ai_fish_recognize':
        final taskId = 'ai${DateTime.now().millisecondsSinceEpoch}';
        return _ok({
          'task_id': taskId,
          'status': 'done',
          'confidence': 0.92,
          'fish': {
            'rid': 'f001',
            'name': '翘嘴',
            'alias': '白鱼、翘嘴巴',
            'bait': 'VIB、亮片，搜索远投收线',
          },
          'candidates': [
            {'name': '翘嘴', 'confidence': 0.92},
            {'name': '青梢', 'confidence': 0.05},
            {'name': '蒙古鲌', 'confidence': 0.03},
          ],
        });
      case 'ai_fish_result':
        return _ok({
          'status': 'done',
          'confidence': 0.92,
          'fish': {
            'rid': 'f001',
            'name': '翘嘴',
            'alias': '白鱼、翘嘴巴',
            'bait': 'VIB、亮片，搜索远投收线',
          },
          'candidates': [
            {'name': '翘嘴', 'confidence': 0.92},
          ],
        });

      // 战报
      case 'report_templates':
        return _ok([
          {'rid': 't1', 'name': '深海蓝经典'},
          {'rid': 't2', 'name': '鱼获金荣耀'},
          {'rid': 't3', 'name': '极简白'},
        ]);
      case 'report_generate':
      case 'report_save':
      case 'report_share':
        return _ok(null, message: '战报${pathName.contains('share') ? '分享' : '保存'}成功');

      // 装备库
      case 'gears':
        return _ok(_gears);
      case 'gear_detail':
        return _ok(_findById(_gears, query?['rid']));
      case 'gear_submit':
        _gears.insert(0, {
          'rid': 'g${_gears.length + 1}',
          'category': data?['category'] ?? 'rod',
          'brand': data?['brand'],
          'model': data?['model'],
          'price': data?['price'],
          'buy_at': data?['buy_at'],
          'usage_count': 0,
          'catch_count': 0,
        });
        return _ok(null, message: '装备已入库');
      case 'gear_combos':
        return _ok([
          {
            'name': '翘嘴夜钓组合',
            'description': 'M调直柄竿 + 纺车轮 + VIB',
          },
          {
            'name': '微物马口组合',
            'description': 'UL调 + 1000型轮 + 小亮片',
          },
        ]);

      // 挑战系统
      case 'challenges':
        return _ok(_challenges);
      case 'challenge_detail':
        return _ok(_findById(_challenges, query?['rid']) ?? _challenges.first);
      case 'challenge_join':
        final challenge = _findById(_challenges, data?['rid']);
        if (challenge != null) challenge['status'] = 'doing';
        return _ok(null, message: '参与成功，快去完成挑战吧');
      case 'challenge_feedback':
        final challenge = _findById(_challenges, data?['rid']);
        if (challenge != null) {
          challenge['progress'] = challenge['target_count'] ?? 1;
          challenge['status'] = 'finished';
          challenge['finished_at'] = _now();
          // 解锁奖励勋章
          final reward = challenge['reward'];
          if (reward is Map) {
            final medal = _findById(_medals, reward['rid']);
            if (medal != null && medal['unlocked'] != true) {
              medal['unlocked'] = true;
              medal['unlocked_at'] = _now();
            }
          }
        }
        return _ok(null, message: '反馈成功，奖励已发放');

      // 勋章与成就
      case 'medals':
        return _ok(_medals);
      case 'medal_detail':
        return _ok(_findById(_medals, query?['rid']));
      case 'achievements':
        return _ok([]);

      // 我的/数字履历
      case 'my_overview':
        return _ok({
          'catch_count': _catches.length,
          'species_count':
              _species.where((s) => s['unlocked'] == true).length,
          'medal_count': _medals.where((m) => m['unlocked'] == true).length,
          'challenge_count':
              _challenges.where((c) => c['status'] == 'finished').length,
        });
      case 'my_timeline':
        return _ok(_buildTimeline());
      case 'my_catches':
        return _ok(_catches);
      case 'my_collection':
        return _ok(_species.where((s) => s['unlocked'] == true).toList());

      // 订阅系统
      case 'subscription_plans':
        return _ok(_plans);
      case 'subscription_buy':
        final target = _findById(_plans, data?['rid']);
        if (target != null) {
          for (final plan in _plans) {
            plan['current'] = plan['rid'] == target['rid'];
          }
        }
        return _ok(null, message: '订阅成功（模拟），尽享权益');
      case 'subscription_renew':
      case 'subscription_cancel':
        return _ok(null, message: '操作成功');

      // 通用
      case 'upload_asset':
        _uploadSeq++;
        return _ok({'url': _img('upload$_uploadSeq', 640, 480)}, message: '上传成功');
      case 'bind_device':
        return _ok(null, message: '设备绑定成功');

      default:
        return _fail('该接口暂未提供模拟数据：$pathName');
    }
  }

  // ---------- 内部状态 ----------

  static int _uploadSeq = 0;

  // 我的鱼获记录（catch_submit 写入）
  static final List<Map<String, dynamic>> _catches = [];

  // 统一图片（在线时加载，离线走 NetImage 错误兜底）
  static String _img(String seed, [int w = 400, int h = 300]) {
    return 'https://picsum.photos/seed/luji-$seed/$w/$h';
  }

  static String _now() {
    final dt = DateTime.now();
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd $hh:$mi';
  }

  static Map<String, dynamic>? _findById(
    List<Map<String, dynamic>> list,
    dynamic rid,
  ) {
    for (final item in list) {
      if (item['rid'] == rid) return item;
    }
    return null;
  }

  static Map<String, dynamic> _ok(dynamic data, {String message = 'ok'}) {
    return {'success': true, 'status': {'message': message}, 'data': data};
  }

  static Map<String, dynamic> _fail(String message) {
    return {'success': false, 'status': {'message': message}, 'data': null};
  }

  // 登录用户（region 置空 -> 首次登录走初始化引导流程）
  static final Map<String, dynamic> _loginUser = {
    'uid': 'u001',
    'nickname': '路亚新手·小路',
    'avatar': _img('avatar1', 200, 200),
    'mobile': '138****0000',
    'subscribe_tier': 'free',
    'region': null,
    'interests': [],
  };

  static final List<Map<String, dynamic>> _banners = [
    {
      'rid': 'b1',
      'title': '秋季路亚挑战赛开启',
      'image': _img('banner1', 750, 400),
      'link': 'challenge_list',
    },
    {
      'rid': 'b2',
      'title': 'AI识鱼，拍一拍就知道',
      'image': _img('banner2', 750, 400),
      'link': 'catch_upload',
    },
  ];

  static final List<Map<String, dynamic>> _feeds = [
    {
      'rid': 'fd1',
      'user': {'nickname': '老张爱路亚', 'avatar': _img('avatar2', 100, 100)},
      'content': '青山湖大坝夜钓，VIB远投第三竿就中了！手感太好了',
      'images': [_img('feed1a', 400, 300), _img('feed1b', 400, 300), _img('feed1c', 400, 300)],
      'likes': 36,
      'comments_count': 8,
      'liked': false,
      'created_at': '2026-10-18 22:40',
      'catch': {
        'fish': {'name': '翘嘴'},
        'weight': 1.8,
      },
    },
    {
      'rid': 'fd2',
      'user': {'nickname': '溪流猎人', 'avatar': _img('avatar3', 100, 100)},
      'content': '上游浅滩马口连竿，微物亮片YYDS',
      'images': [_img('feed2a', 400, 300), _img('feed2b', 400, 300)],
      'likes': 18,
      'comments_count': 3,
      'liked': true,
      'created_at': '2026-10-18 18:05',
      'catch': {
        'fish': {'name': '马口'},
        'weight': 0.1,
      },
    },
    {
      'rid': 'fd3',
      'user': {'nickname': '海钓老王', 'avatar': _img('avatar4', 100, 100)},
      'content': '防波堤根钓黑头，虾型软饵慢拖，中鱼瞬间过瘾',
      'images': [_img('feed3a', 400, 300)],
      'likes': 52,
      'comments_count': 12,
      'liked': false,
      'created_at': '2026-10-17 16:30',
      'catch': {
        'fish': {'name': '褐菖鲉'},
        'weight': 0.6,
      },
    },
  ];

  static final List<Map<String, dynamic>> _challenges = [
    {
      'rid': 'ch1',
      'title': '七日连钓挑战',
      'description': '连续7天记录鱼获，养成作钓好习惯',
      'type': 'weekly',
      'target': '累计7条鱼获记录',
      'target_count': 7,
      'progress': 2,
      'points': 300,
      'status': 'doing',
      'end_at': '2026-10-26',
      'cover': _img('ch1', 400, 300),
      'reward': {'rid': 'm2', 'name': '坚持者勋章'},
    },
    {
      'rid': 'ch2',
      'title': '翘嘴猎人',
      'description': '本赛季钓获5尾翘嘴，赢取限定勋章',
      'type': 'season',
      'target': '钓获翘嘴5尾',
      'target_count': 5,
      'progress': 0,
      'points': 500,
      'status': 'not_join',
      'end_at': '2026-12-31',
      'cover': _img('ch2', 400, 300),
      'reward': {'rid': 'm1', 'name': '翘嘴猎人（史诗）'},
    },
    {
      'rid': 'ch3',
      'title': '每日一签',
      'description': '打开App记录一次作钓计划',
      'type': 'daily',
      'target': '记录1次作钓',
      'target_count': 1,
      'progress': 1,
      'points': 20,
      'status': 'finished',
      'end_at': '2026-10-19',
      'cover': _img('ch3', 400, 300),
      'reward': {'rid': 'm5', 'name': '早起鸟勋章'},
    },
  ];

  static final List<Map<String, dynamic>> _spots = [
    {
      'rid': 'sp1',
      'name': '青山湖大坝夜钓位',
      'address': '浙江省杭州市临安区青山湖街道',
      'type': 'reservoir',
      'lat': 30.22,
      'lng': 119.72,
      'rating': 4.8,
      'distance': 3.2,
      'reviews_count': 2,
      'fee': '免费',
      'open_time': '全天开放',
      'cover': _img('spot1', 640, 420),
      'fish_names': ['翘嘴', '鳜鱼', '青稍'],
      'description': '大坝南侧台阶下水，夜钓为主，水深3-5米，风大时注意安全。',
    },
    {
      'rid': 'sp2',
      'name': '苕溪碧水湾段',
      'address': '浙江省湖州市安吉县递铺镇',
      'type': 'river',
      'lat': 30.63,
      'lng': 119.68,
      'rating': 4.5,
      'distance': 12.6,
      'reviews_count': 1,
      'fee': '免费',
      'open_time': '6:00-19:00',
      'cover': _img('spot2', 640, 420),
      'fish_names': ['马口', '青稍', '白条'],
      'description': '溪流缓流区，微物装备友好，水质清澈。',
    },
    {
      'rid': 'sp3',
      'name': '千岛湖进贤湾',
      'address': '浙江省杭州市淳安县千岛湖镇',
      'type': 'lake',
      'lat': 29.60,
      'lng': 119.03,
      'rating': 4.9,
      'distance': 86.0,
      'reviews_count': 1,
      'fee': '100元/天',
      'open_time': '全天开放',
      'cover': _img('spot3', 640, 420),
      'fish_names': ['翘嘴', '鲈鱼', '鳜鱼'],
      'description': '湖湾结构点多，早晚窗口期有炸水，适合远投。',
    },
    {
      'rid': 'sp4',
      'name': '象山港防波堤',
      'address': '浙江省宁波市象山县',
      'type': 'sea',
      'lat': 29.48,
      'lng': 121.87,
      'rating': 4.3,
      'distance': 150.0,
      'reviews_count': 0,
      'fee': '免费',
      'open_time': '全天开放',
      'cover': _img('spot4', 640, 420),
      'fish_names': ['黑头', '鲈鱼'],
      'description': '根钓天堂，潮汐影响大，出 fishing 前查好潮汐表。',
    },
  ];

  static final List<Map<String, dynamic>> _spotReviews = [
    {
      'user': {'nickname': '老张爱路亚', 'avatar': _img('avatar2', 100, 100)},
      'content': '傍晚炸水一片，翘嘴口很猛，推荐VIB',
      'created_at': '2026-10-15',
    },
    {
      'user': {'nickname': '溪流猎人', 'avatar': _img('avatar3', 100, 100)},
      'content': '周末人多，建议工作日去',
      'created_at': '2026-10-12',
    },
  ];

  static final List<Map<String, dynamic>> _species = [
    {
      'rid': 'f001',
      'name': '翘嘴',
      'alias': '白鱼、翘嘴巴',
      'cover': _img('fish1', 300, 300),
      'habitat': 'reservoir',
      'bait': 'VIB、亮片、米诺',
      'season': '5-10月',
      'difficulty': 'medium',
      'description': '中上层掠食性鱼类，晨昏窗口期活跃，炸水明显。',
      'unlocked': true,
      'unlocked_at': '2026-09-12',
    },
    {
      'rid': 'f002',
      'name': '马口',
      'alias': '桃花鱼',
      'cover': _img('fish2', 300, 300),
      'habitat': 'river',
      'bait': '小亮片、飞蝇',
      'season': '全年',
      'difficulty': 'easy',
      'description': '溪流代表性鱼种，色彩艳丽，微物作钓首选目标。',
      'unlocked': true,
      'unlocked_at': '2026-10-01',
    },
    {
      'rid': 'f003',
      'name': '鳜鱼',
      'alias': '桂花鱼',
      'cover': _img('fish3', 300, 300),
      'habitat': 'lake',
      'bait': '铅头钩+软虫、德洲钓组',
      'season': '4-11月',
      'difficulty': 'hard',
      'description': '底栖伏击型掠食鱼，结构区作钓，咬口凶猛。',
      'unlocked': false,
    },
    {
      'rid': 'f004',
      'name': '黑鱼',
      'alias': '乌鳢、雷鱼',
      'cover': _img('fish4', 300, 300),
      'habitat': 'river',
      'bait': '雷蛙',
      'season': '5-9月',
      'difficulty': 'medium',
      'description': '护巢性强，水草区打黑刺激感拉满。',
      'unlocked': false,
    },
    {
      'rid': 'f005',
      'name': '鲈鱼',
      'alias': '海鲈、七星鲈',
      'cover': _img('fish5', 300, 300),
      'habitat': 'sea',
      'bait': '米诺、铁板',
      'season': '春秋季',
      'difficulty': 'medium',
      'description': '近岸洄游掠食鱼，潮汐窗口期口好。',
      'unlocked': false,
    },
    {
      'rid': 'f006',
      'name': '青稍',
      'alias': '青桔子',
      'cover': _img('fish6', 300, 300),
      'habitat': 'reservoir',
      'bait': '小亮片、瓜子亮片',
      'season': '全年',
      'difficulty': 'easy',
      'description': '集群性强，连竿快感的来源。',
      'unlocked': false,
    },
  ];

  static final List<Map<String, dynamic>> _gears = [
    {
      'rid': 'g1',
      'category': 'rod',
      'brand': '达瓦',
      'model': 'Steez 632ML',
      'price': 2380,
      'buy_at': '2025-06-01',
      'usage_count': 46,
      'catch_count': 12,
    },
    {
      'rid': 'g2',
      'category': 'reel',
      'brand': '禧玛诺',
      'model': 'Stella 2500S',
      'price': 3200,
      'buy_at': '2025-03-15',
      'usage_count': 38,
      'catch_count': 9,
    },
    {
      'rid': 'g3',
      'category': 'lure',
      'brand': 'Megabass',
      'model': 'Vibration-X',
      'price': 168,
      'buy_at': '2026-04-20',
      'usage_count': 21,
      'catch_count': 7,
    },
    {
      'rid': 'g4',
      'category': 'line',
      'brand': 'YGK',
      'model': 'G-Soul PE 1.0号',
      'price': 138,
      'buy_at': '2026-01-10',
      'usage_count': 46,
      'catch_count': 12,
    },
  ];

  static final List<Map<String, dynamic>> _medals = [
    {
      'rid': 'm1',
      'name': '翘嘴猎人',
      'rarity': 'epic',
      'description': '钓获5尾翘嘴的荣耀证明',
      'condition': '完成「翘嘴猎人」挑战',
      'unlocked': false,
      'progress': 0,
    },
    {
      'rid': 'm2',
      'name': '坚持者勋章',
      'rarity': 'rare',
      'description': '连续7天记录鱼获',
      'condition': '完成「七日连钓」挑战',
      'unlocked': false,
      'progress': 28,
    },
    {
      'rid': 'm3',
      'name': '首尾纪念',
      'rarity': 'common',
      'description': '记录你的第一条鱼获',
      'condition': '提交1条鱼获记录',
      'unlocked': true,
      'unlocked_at': '2026-08-15',
      'progress': 100,
    },
    {
      'rid': 'm4',
      'name': '百战老兵',
      'rarity': 'legend',
      'description': '累计100条鱼获记录',
      'condition': '累计鱼获100尾',
      'unlocked': false,
      'progress': 12,
    },
    {
      'rid': 'm5',
      'name': '早起鸟勋章',
      'rarity': 'common',
      'description': '完成一次每日签到挑战',
      'condition': '完成「每日一签」',
      'unlocked': true,
      'unlocked_at': '2026-10-19',
      'progress': 100,
    },
    {
      'rid': 'm6',
      'name': '夜钓行者',
      'rarity': 'rare',
      'description': '夜间作钓10次',
      'condition': '累计夜钓10次',
      'unlocked': false,
      'progress': 40,
    },
  ];

  static final List<Map<String, dynamic>> _plans = [
    {
      'rid': 'p1',
      'tier': 'free',
      'name': '免费版',
      'price': 0,
      'current': true,
      'recommended': false,
      'privileges': [
        '基础鱼获记录（每日3条）',
        '钓点探索与图鉴浏览',
        '标准战报模板',
      ],
    },
    {
      'rid': 'p2',
      'tier': 'pro',
      'name': 'Pro会员',
      'price': 18,
      'duration_months': 1,
      'current': false,
      'recommended': true,
      'privileges': [
        '无限鱼获记录',
        'AI识鱼每日30次',
        '全部战报模板',
        '装备履历分析',
      ],
    },
    {
      'rid': 'p3',
      'tier': 'master',
      'name': 'Master大师',
      'price': 128,
      'duration_months': 12,
      'current': false,
      'recommended': false,
      'privileges': [
        '包含Pro全部权益',
        'AI识鱼无限次',
        '限定传说勋章优先解锁',
        '专属客服与优先内测',
      ],
    },
  ];

  // 数字履历时间轴（由各模块状态汇总）
  static List<Map<String, dynamic>> _buildTimeline() {
    final List<Map<String, dynamic>> timeline = [];
    for (final c in _catches) {
      timeline.add({
        'type': 'catch',
        'title': '钓获${c['fish']?['name'] ?? '鱼获'}一尾',
        'description': c['notes'],
        'created_at': c['created_at'],
      });
    }
    for (final ch in _challenges) {
      if (ch['status'] == 'finished') {
        timeline.add({
          'type': 'challenge',
          'title': '完成挑战「${ch['title']}」',
          'description': '获得${ch['points']}积分',
          'created_at': ch['finished_at'] ?? ch['end_at'],
        });
      }
    }
    for (final m in _medals) {
      if (m['unlocked'] == true && m['unlocked_at'] != null) {
        timeline.add({
          'type': 'medal',
          'title': '解锁勋章「${m['name']}」',
          'description': m['description'],
          'created_at': m['unlocked_at'],
        });
      }
    }
    timeline.sort(
      (a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
    );
    return timeline;
  }
}
