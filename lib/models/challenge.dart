// ignore_for_file: non_constant_identifier_names

/// @desc 挑战
class Challenge {
  // 挑战ID
  String? rid;
  // 标题
  String? title;
  // 封面
  String? cover;
  // 简介
  String? description;
  // 类型：daily 日常 / weekly 周常 / season 赛季 / event 活动
  String? type;
  // 目标说明（如：钓获翘嘴5尾）
  String? target;
  // 目标数量
  int? target_count;
  // 当前进度
  int? progress;
  // 奖励勋章
  Medal? reward;
  // 奖励积分
  int? points;
  // 截止时间
  String? end_at;
  // 状态：not_join / doing / finished / expired
  String? status;
  // 完成时间
  String? finished_at;

  Challenge({
    this.rid,
    this.title,
    this.cover,
    this.description,
    this.type,
    this.target,
    this.target_count,
    this.progress,
    this.reward,
    this.points,
    this.end_at,
    this.status,
    this.finished_at,
  });

  Challenge.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    title = json['title'];
    cover = json['cover'];
    description = json['description'];
    type = json['type'] ?? 'daily';
    target = json['target'];
    target_count = json['target_count'] ?? 1;
    progress = json['progress'] ?? 0;
    reward = json['reward'] != null ? Medal.fromJson(json['reward']) : null;
    points = json['points'] ?? 0;
    end_at = json['end_at'];
    status = json['status'] ?? 'not_join';
    finished_at = json['finished_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['title'] = title;
    data['cover'] = cover;
    data['description'] = description;
    data['type'] = type;
    data['target'] = target;
    data['target_count'] = target_count;
    data['progress'] = progress;
    if (reward != null) {
      data['reward'] = reward!.toJson();
    }
    data['points'] = points;
    data['end_at'] = end_at;
    data['status'] = status;
    data['finished_at'] = finished_at;
    return data;
  }
}

/// @desc 勋章与成就
class Medal {
  // 勋章ID
  String? rid;
  // 名称
  String? name;
  // 图标
  String? icon;
  // 稀有度：common 普通 / rare 稀有 / epic 史诗 / legend 传说
  String? rarity;
  // 描述
  String? description;
  // 达成条件说明
  String? condition;
  // 是否已解锁
  bool? unlocked;
  // 解锁时间
  String? unlocked_at;
  // 解锁进度（0-100）
  int? progress;

  Medal({
    this.rid,
    this.name,
    this.icon,
    this.rarity,
    this.description,
    this.condition,
    this.unlocked,
    this.unlocked_at,
    this.progress,
  });

  Medal.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    name = json['name'];
    icon = json['icon'];
    rarity = json['rarity'] ?? 'common';
    description = json['description'];
    condition = json['condition'];
    unlocked = json['unlocked'] ?? false;
    unlocked_at = json['unlocked_at'];
    progress = json['progress'] ?? 0;
  }

  /// 从 FishMark API 的 UserBadge 结构映射
  /// （字段：badge{id,name,icon_url,rarity,description,...}, is_unlocked, progress, unlocked_at）
  factory Medal.fromApi(Map<String, dynamic> json) {
    final badge = json['badge'] is Map
        ? Map<String, dynamic>.from(json['badge'])
        : <String, dynamic>{};
    return Medal(
      rid: (badge['id'] ?? json['badge_id'] ?? json['rid'])?.toString(),
      name: badge['name'],
      icon: badge['icon_url'] ?? badge['icon'],
      rarity: badge['rarity'] ?? 'common',
      description: badge['description'],
      condition: badge['condition_type'] != null
          ? '${badge['condition_type']} ${badge['condition_value'] ?? ''}'
          : null,
      unlocked: json['is_unlocked'] ?? false,
      unlocked_at: json['unlocked_at'],
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['name'] = name;
    data['icon'] = icon;
    data['rarity'] = rarity;
    data['description'] = description;
    data['condition'] = condition;
    data['unlocked'] = unlocked;
    data['unlocked_at'] = unlocked_at;
    data['progress'] = progress;
    return data;
  }
}
