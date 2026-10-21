// ignore_for_file: non_constant_identifier_names

/// @desc 装备档案
class Gear {
  // 装备ID
  String? rid;
  // 用户ID
  String? uid;
  // 分类：rod 路亚竿 / reel 渔轮 / line 鱼线 / lure 拟饵 / accessory 配件
  String? category;
  // 品牌
  String? brand;
  // 型号
  String? model;
  // 价格
  double? price;
  // 购入时间
  String? buy_at;
  // 图片
  List<String>? images;
  // 使用心得
  String? notes;
  // 累计使用次数（履历数据）
  int? usage_count;
  // 累计渔获（履历数据）
  int? catch_count;
  // 关联鱼获记录ID（履历）
  List<String>? catch_rids;
  // 创建时间
  String? created_at;

  Gear({
    this.rid,
    this.uid,
    this.category,
    this.brand,
    this.model,
    this.price,
    this.buy_at,
    this.images,
    this.notes,
    this.usage_count,
    this.catch_count,
    this.catch_rids,
    this.created_at,
  });

  Gear.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    uid = json['uid'];
    category = json['category'] ?? 'rod';
    brand = json['brand'];
    model = json['model'];
    price = json['price'] != null
        ? double.tryParse(json['price'].toString())
        : null;
    buy_at = json['buy_at'];
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    notes = json['notes'];
    usage_count = json['usage_count'] ?? 0;
    catch_count = json['catch_count'] ?? 0;
    catch_rids =
        json['catch_rids'] != null ? List<String>.from(json['catch_rids']) : null;
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['uid'] = uid;
    data['category'] = category;
    data['brand'] = brand;
    data['model'] = model;
    data['price'] = price;
    data['buy_at'] = buy_at;
    data['images'] = images;
    data['notes'] = notes;
    data['usage_count'] = usage_count;
    data['catch_count'] = catch_count;
    data['catch_rids'] = catch_rids;
    data['created_at'] = created_at;
    return data;
  }
}
