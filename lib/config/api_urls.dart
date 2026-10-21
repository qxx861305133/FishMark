/// @desc API urls
// ignore: constant_identifier_names
const ApiUrls = {
  // 启动与通用
  'initial_settings': '/settings/init', // GET 初始化配置
  'agreement': '/settings/agreement', // GET 用户协议/隐私政策
  'regions': '/regions', // GET 地区列表（省市区）
  'interests': '/interests', // GET 兴趣标签

  // 用户系统
  'send_sms': '/sms/send', // POST 发送验证码
  'sms_login': '/auth/sms_login', // POST 验证码登录
  'auth_logout': '/auth/logout', // POST 退出登录
  'user_info': '/user/info', // GET 当前用户信息
  'user_update': '/user/update', // POST 更新个人信息
  'user_init_profile': '/user/init_profile', // POST 兴趣/地区初始化

  // 首页
  'banners': '/banners', // GET Banner列表
  'home_feeds': '/feeds', // GET 鱼获动态列表
  'feed_detail': '/feeds/get_feed', // GET 鱼获动态详情
  'feed_like': '/feeds/like', // POST 点赞/取消点赞
  'feed_comments': '/feeds/comments', // GET 动态评论
  'feed_comment': '/feeds/comment', // POST 发表评论

  // 探索
  'spots': '/spots', // GET 钓点列表
  'spot_map': '/spots/map', // GET 地图钓点聚合
  'spot_detail': '/spots/get_spot', // GET 钓点详情
  'spot_submit': '/spots/submit', // POST 钓点上传
  'spot_reviews': '/spots/reviews', // GET 钓点点评
  'fish_species': '/fishes', // GET 鱼种图鉴列表
  'fish_species_detail': '/fishes/get_fish', // GET 鱼种详情

  // 上传
  'catch_submit': '/catches/submit', // POST 鱼获记录提交
  'catch_detail': '/catches/get_catch', // GET 鱼获详情
  'catch_delete': '/catches/delete', // POST 删除鱼获

  // AI识鱼
  'ai_fish_recognize': '/ai/fish/recognize', // POST AI识鱼（阿里云百炼）
  'ai_fish_result': '/ai/fish/result', // GET 识别结果轮询

  // 战报
  'report_templates': '/reports/templates', // GET 战报模板
  'report_generate': '/reports/generate', // POST 生成战报分享卡
  'report_save': '/reports/save', // POST 保存战报
  'report_share': '/reports/share', // POST 分享战报

  // 装备库
  'gears': '/gears', // GET 装备列表
  'gear_detail': '/gears/get_gear', // GET 装备详情
  'gear_submit': '/gears/submit', // POST 装备上传
  'gear_combos': '/gears/combos', // GET 装备组合列表
  'gear_combo_submit': '/gears/combos/submit', // POST 装备组合上传
  'gear_delete': '/gears/delete', // POST 删除装备

  // 挑战系统
  'challenges': '/challenges', // GET 挑战列表
  'challenge_detail': '/challenges/get_challenge', // GET 挑战详情
  'challenge_join': '/challenges/join', // POST 参与挑战
  'challenge_feedback': '/challenges/feedback', // POST 完成反馈

  // 勋章与成就
  'medals': '/medals', // GET 勋章列表
  'medal_detail': '/medals/get_medal', // GET 勋章详情
  'achievements': '/achievements', // GET 成就列表

  // 我的/数字履历
  'my_overview': '/user/overview', // GET 数据总览
  'my_timeline': '/user/timeline', // GET 履历时间轴
  'my_catches': '/catches/my_list', // GET 我的鱼获
  'my_collection': '/user/collection', // GET 我的图鉴

  // 订阅系统
  'subscription_plans': '/subscription/plans', // GET 套餐列表
  'subscription_buy': '/subscription/buy', // POST 购买订阅
  'subscription_renew': '/subscription/renew', // POST 续费管理
  'subscription_cancel': '/subscription/cancel', // POST 取消订阅

  // 通用
  'upload_asset': '/assets/upload', // POST 上传附件
  'bind_device': '/devices/bind', // POST 绑定设备
};
