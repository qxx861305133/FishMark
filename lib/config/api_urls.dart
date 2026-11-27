/// @desc API urls —— FishMark 移动端 RESTful API（https://api.fishmark.me/apidocs/）
/// 所有路径基于 baseUrl：https://api.fishmark.me/api/v1
/// 含 {xxx} 占位符的路径由拦截器根据 queryParameters 自动替换
// ignore: constant_identifier_names
const ApiUrls = {
  // ===== 认证 =====
  'auth_login': '/auth/login', // POST 手机号+密码登录
  'auth_register': '/auth/register', // POST 用户注册
  'auth_logout': '/auth/logout', // POST 退出登录（Token 加入黑名单）
  'auth_refresh': '/auth/refresh', // POST 刷新访问令牌
  'auth_me': '/auth/me', // GET 当前登录用户信息
  'auth_password': '/auth/password', // PUT 修改密码
  'auth_email_send_code': '/auth/email/send-code', // POST 发送邮箱验证码
  'auth_email_verify': '/auth/email/verify', // POST 校验邮箱验证码
  'auth_wechat_login': '/auth/wechat/login', // POST 微信登录
  'auth_wechat_bind': '/auth/wechat/bind', // POST 绑定微信账号
  'auth_apple_login': '/auth/apple/login', // POST Apple 登录
  'auth_apple_bind': '/auth/apple/bind', // POST 绑定 Apple 账号
  'auth_apple_unbind': '/auth/apple/bind', // DELETE 解绑 Apple 账号
  'auth_wechat_unbind': '/auth/wechat/bind', // DELETE 解绑微信账号

  // ===== 用户 =====
  'user_update': '/users/me', // PUT 更新当前用户资料
  'user_stats': '/users/me/stats', // GET 当前用户统计数据
  'user_subscription': '/users/me/subscription', // GET 当前用户订阅信息
  'user_timeline': '/users/me/timeline', // GET 当前用户时间轴
  'user_units': '/users/me/units', // GET/PUT 计量单位偏好
  'user_badges': '/users/me/badges', // GET 当前用户已获得勋章
  'user_public': '/users/{user_id}', // GET 用户公开资料
  'user_public_catches': '/users/{user_id}/catches', // GET 用户公开鱼获列表

  // ===== 鱼获 =====
  'catches': '/catches', // GET 公开鱼获列表 / POST 创建鱼获记录
  'catch_detail': '/catches/{catch_id}', // GET 鱼获详情
  'catch_update': '/catches/{catch_id}', // PUT 更新鱼获记录
  'catch_delete': '/catches/{catch_id}', // DELETE 删除鱼获记录
  'catch_like': '/catches/{catch_id}/like', // POST 点赞鱼获
  'catch_unlike': '/catches/{catch_id}/unlike', // POST 取消点赞鱼获

  // ===== 钓点 =====
  'spots': '/spots', // GET 公开钓点列表 / POST 创建钓点
  'spot_detail': '/spots/{spot_id}', // GET 钓点详情
  'spot_update': '/spots/{spot_id}', // PUT 更新钓点
  'spot_delete': '/spots/{spot_id}', // DELETE 删除钓点
  'spots_nearby': '/spots/nearby', // GET 附近钓点
  'spot_checkin': '/spots/{spot_id}/checkin', // POST 钓点打卡
  'spot_checkins': '/spots/{spot_id}/checkins', // GET 钓点打卡记录
  'spot_like': '/spots/{spot_id}/like', // POST 点赞钓点
  'spot_verify': '/spots/{spot_id}/verify', // POST 验证钓点

  // ===== 装备 =====
  'gears': '/gears', // GET 当前用户装备列表 / POST 创建装备
  'gear_detail': '/gears/{gear_id}', // GET 装备详情
  'gear_update': '/gears/{gear_id}', // PUT 更新装备
  'gear_delete': '/gears/{gear_id}', // DELETE 删除装备
  'gear_combos': '/gear-combos', // GET 装备组合列表 / POST 创建装备组合
  'gear_combo_delete': '/gear-combos/{combo_id}', // DELETE 删除装备组合

  // ===== 鱼种图鉴 =====
  'fish_species': '/fish-species', // GET 鱼种图鉴列表
  'fish_species_detail': '/fish-species/{species_id}', // GET 鱼种详情

  // ===== 勋章 =====
  'badges': '/badges', // GET 全部可用勋章
  'badges_me': '/badges/me', // GET 当前用户勋章及进度
  'badge_detail': '/badges/{badge_id}', // GET 勋章详情
  'badge_request_physical': '/badges/{badge_id}/request-physical', // POST 申请实体勋章寄送

  // ===== 轮换图 / 静态页 / 笔记 =====
  'banner': '/banners/{serial_no}', // GET 指定页面位置的轮换图
  'page': '/pages/{name}', // GET 指定标识的可见静态页面
  'notes': '/notes', // GET 已发布笔记列表
  'note_detail': '/notes/{note_id}', // GET 笔记详情

  // ===== AI =====
  'ai_recognize': '/ai/recognize', // POST AI 识鱼（image_base64 / image_url 二选一）
  'ai_generate_report': '/ai/generate-report', // POST 生成鱼获分享战报

  // ===== 通用 =====
  'health': '/health', // GET 健康检查
};
