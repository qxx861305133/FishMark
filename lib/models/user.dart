// ignore_for_file: non_constant_identifier_names

/// @desc 用户信息
class User {
  // 用户ID
  String? uid;
  // 昵称
  String? nickname;
  // 头像
  String? avatar;
  // 手机号
  String? mobile;
  // 账号（手机号或第三方唯一标识）
  String? account;
  // 是否已登录
  bool? is_login;
  // 订阅档位：free / pro / master
  String? subscribeTier;
  // 常驻地区
  String? region;
  // 兴趣标签（路亚鱼种/钓法等）
  List<String>? interests;
  // 注册时间
  String? created_at;

  User({
    this.uid,
    this.nickname,
    this.avatar,
    this.mobile,
    this.account,
    this.is_login,
    this.subscribeTier,
    this.region,
    this.interests,
    this.created_at,
  });

  User.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    nickname = json['nickname'];
    avatar = json['avatar'];
    mobile = json['mobile'];
    account = json['account'] ?? json['mobile'] ?? '';
    is_login = json['is_login'];
    subscribeTier = json['subscribe_tier'] ?? 'free';
    region = json['region'];
    interests = json['interests'] != null
        ? List<String>.from(json['interests'])
        : null;
    created_at = json['created_at'];
  }

  /// 从 FishMark API 的 User 结构映射
  /// （字段：id, nickname, avatar_url, phone, subscription_type, created_at ...）
  factory User.fromApiUser(Map<String, dynamic>? json, {String? phone}) {
    if (json == null) {
      return User(is_login: true, mobile: phone);
    }
    return User(
      uid: json['id']?.toString(),
      nickname: json['nickname'],
      avatar: json['avatar_url'],
      mobile: json['phone'] ?? phone,
      account: json['phone'] ?? phone ?? '',
      is_login: true,
      subscribeTier: json['subscription_type'] ?? 'free',
      created_at: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['nickname'] = nickname;
    data['avatar'] = avatar;
    data['mobile'] = mobile;
    data['account'] = account;
    data['is_login'] = is_login;
    data['subscribe_tier'] = subscribeTier;
    data['region'] = region;
    data['interests'] = interests;
    data['created_at'] = created_at;
    return data;
  }
}
