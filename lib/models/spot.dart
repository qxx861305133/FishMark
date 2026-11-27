// ignore_for_file: non_constant_identifier_names

/// @desc 钓点
class Spot {
  // 钓点ID
  String? rid;
  // 钓点名称
  String? name;
  // 封面图
  String? cover;
  // 纬度
  double? lat;
  // 经度
  double? lng;
  // 地址
  String? address;
  // 类型：river 江河 / lake 湖泊 / reservoir 水库 / sea 海钓 / pond 黑坑
  String? type;
  // 评分
  double? rating;
  // 常见鱼种
  List<String>? fish_names;
  // 收费说明
  String? fee;
  // 开放时间
  String? open_time;
  // 点评数
  int? reviews_count;
  // 距离（km）
  double? distance;
  // 详情介绍
  String? description;
  // 上传用户
  String? uid;
  // 创建时间
  String? created_at;

  Spot({
    this.rid,
    this.name,
    this.cover,
    this.lat,
    this.lng,
    this.address,
    this.type,
    this.rating,
    this.fish_names,
    this.fee,
    this.open_time,
    this.reviews_count,
    this.distance,
    this.description,
    this.uid,
    this.created_at,
  });

  Spot.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    name = json['name'];
    cover = json['cover'];
    lat = json['lat'] != null ? double.tryParse(json['lat'].toString()) : null;
    lng = json['lng'] != null ? double.tryParse(json['lng'].toString()) : null;
    address = json['address'];
    type = json['type'] ?? 'river';
    rating = json['rating'] != null
        ? double.tryParse(json['rating'].toString())
        : null;
    fish_names = json['fish_names'] != null
        ? List<String>.from(json['fish_names'])
        : null;
    fee = json['fee'];
    open_time = json['open_time'];
    reviews_count = json['reviews_count'];
    distance = json['distance'] != null
        ? double.tryParse(json['distance'].toString())
        : null;
    description = json['description'];
    uid = json['uid'];
    created_at = json['created_at'];
  }

  /// 从 FishMark API 的 Spot 结构映射
  /// （字段：id, name, photo_urls/thumbnail_urls, latitude, longitude, address, water_type, description, checkin_count, like_count ...）
  factory Spot.fromApi(Map<String, dynamic> json, {double? distance}) {
    List<String>? fishNames;
    if (json['fish_species'] is List) {
      fishNames = (json['fish_species'] as List)
          .map((e) => e is Map ? (e['name']?.toString() ?? '') : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final photoUrls = json['thumbnail_urls'] ?? json['photo_urls'];
    return Spot(
      rid: (json['id'] ?? json['rid'])?.toString(),
      name: json['name'],
      cover: photoUrls is List && photoUrls.isNotEmpty
          ? photoUrls.first.toString()
          : json['cover'],
      lat: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      lng: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      address: json['address'],
      type: json['water_type'] ?? 'river',
      fish_names: fishNames,
      description: json['description'],
      reviews_count: json['checkin_count'],
      distance: distance ?? (json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null),
      uid: json['user_id']?.toString(),
      created_at: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['name'] = name;
    data['cover'] = cover;
    data['lat'] = lat;
    data['lng'] = lng;
    data['address'] = address;
    data['type'] = type;
    data['rating'] = rating;
    data['fish_names'] = fish_names;
    data['fee'] = fee;
    data['open_time'] = open_time;
    data['reviews_count'] = reviews_count;
    data['distance'] = distance;
    data['description'] = description;
    data['uid'] = uid;
    data['created_at'] = created_at;
    return data;
  }
}
