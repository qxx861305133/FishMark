// ignore_for_file: non_constant_identifier_names

/// @desc 订阅套餐
class SubscriptionPlan {
  // 套餐ID
  String? rid;
  // 档位：free / pro / master
  String? tier;
  // 名称
  String? name;
  // 价格（元）
  double? price;
  // 时长（月）
  int? duration_months;
  // 权益说明
  List<String>? privileges;
  // 是否推荐
  bool? recommended;
  // 当前是否生效
  bool? current;

  SubscriptionPlan({
    this.rid,
    this.tier,
    this.name,
    this.price,
    this.duration_months,
    this.privileges,
    this.recommended,
    this.current,
  });

  SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    tier = json['tier'] ?? 'free';
    name = json['name'];
    price = json['price'] != null
        ? double.tryParse(json['price'].toString())
        : null;
    duration_months = json['duration_months'];
    privileges =
        json['privileges'] != null ? List<String>.from(json['privileges']) : null;
    recommended = json['recommended'] ?? false;
    current = json['current'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['tier'] = tier;
    data['name'] = name;
    data['price'] = price;
    data['duration_months'] = duration_months;
    data['privileges'] = privileges;
    data['recommended'] = recommended;
    data['current'] = current;
    return data;
  }
}
