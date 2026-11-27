// ignore_for_file: non_constant_identifier_names
import 'package:FishMark/models/gear.dart';
import 'package:FishMark/models/spot.dart';

/// @desc 鱼获记录
class CatchRecord {
  // 鱼获ID
  String? rid;
  // 用户ID
  String? uid;
  // 鱼种
  FishSpecies? fish;
  // 钓点
  Spot? spot;
  // 重量（kg）
  double? weight;
  // 长度（cm）
  double? length;
  // 使用装备
  Gear? gear;
  // 鱼获照片
  List<String>? images;
  // 心得笔记
  String? notes;
  // 上钩时间
  String? caught_at;
  // 天气
  String? weather;
  // 气温
  String? temperature;
  // 状态：draft / normal / deleted
  String? status;
  // 创建时间
  String? created_at;

  CatchRecord({
    this.rid,
    this.uid,
    this.fish,
    this.spot,
    this.weight,
    this.length,
    this.gear,
    this.images,
    this.notes,
    this.caught_at,
    this.weather,
    this.temperature,
    this.status,
    this.created_at,
  });

  CatchRecord.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    uid = json['uid'];
    fish = json['fish'] != null ? FishSpecies.fromJson(json['fish']) : null;
    spot = json['spot'] != null ? Spot.fromJson(json['spot']) : null;
    gear = json['gear'] != null ? Gear.fromJson(json['gear']) : null;
    weight = json['weight'] != null
        ? double.tryParse(json['weight'].toString())
        : null;
    length = json['length'] != null
        ? double.tryParse(json['length'].toString())
        : null;
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    notes = json['notes'];
    caught_at = json['caught_at'];
    weather = json['weather'];
    temperature = json['temperature'];
    status = json['status'] ?? 'normal';
    created_at = json['created_at'];
  }

  /// 从 FishMark API 的 Catch 结构映射
  /// （字段：id, user_id, fish_species, weight, length, photo_urls, note, catch_date, weather, temperature, created_at）
  factory CatchRecord.fromApi(Map<String, dynamic> json) {
    return CatchRecord(
      rid: (json['id'] ?? json['rid'])?.toString(),
      uid: (json['user_id'] ?? json['uid'])?.toString(),
      fish: FishSpecies(
        rid: json['fish_species_id']?.toString(),
        name: json['fish_species'],
      ),
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      length: json['length'] != null
          ? double.tryParse(json['length'].toString())
          : null,
      images: json['photo_urls'] != null
          ? List<String>.from(json['photo_urls'])
          : null,
      notes: json['note'] ?? json['notes'],
      caught_at: json['catch_date'] ?? json['caught_at'],
      weather: json['weather'],
      temperature: json['temperature']?.toString(),
      status: json['is_public'] == false ? 'draft' : 'normal',
      created_at: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['uid'] = uid;
    if (fish != null) {
      data['fish'] = fish!.toJson();
    }
    if (spot != null) {
      data['spot'] = spot!.toJson();
    }
    if (gear != null) {
      data['gear'] = gear!.toJson();
    }
    data['weight'] = weight;
    data['length'] = length;
    data['images'] = images;
    data['notes'] = notes;
    data['caught_at'] = caught_at;
    data['weather'] = weather;
    data['temperature'] = temperature;
    data['status'] = status;
    data['created_at'] = created_at;
    return data;
  }
}

/// @desc 鱼种图鉴
class FishSpecies {
  // 鱼种ID
  String? rid;
  // 鱼种名称
  String? name;
  // 别名
  String? alias;
  // 图片
  String? cover;
  // 栖息水域：river / lake / reservoir / sea
  String? habitat;
  // 推荐饵/拟饵
  String? bait;
  // 最佳季节
  String? season;
  // 作钓难度：easy / medium / hard
  String? difficulty;
  // 介绍
  String? description;
  // 图鉴是否已解锁（钓到过）
  bool? unlocked;
  // 首次解锁时间
  String? unlocked_at;

  FishSpecies({
    this.rid,
    this.name,
    this.alias,
    this.cover,
    this.habitat,
    this.bait,
    this.season,
    this.difficulty,
    this.description,
    this.unlocked,
    this.unlocked_at,
  });

  FishSpecies.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    name = json['name'];
    alias = json['alias'];
    cover = json['cover'];
    habitat = json['habitat'];
    bait = json['bait'];
    season = json['season'];
    difficulty = json['difficulty'];
    description = json['description'];
    unlocked = json['unlocked'] ?? false;
    unlocked_at = json['unlocked_at'];
  }

  /// 从 FishMark API 的 FishSpecies 结构映射
  /// （字段：id, name, name_en, scientific_name, category, rarity, image_url, description, catch_count ...）
  factory FishSpecies.fromApi(Map<String, dynamic> json) {
    final catchCount = json['catch_count'] ?? 0;
    return FishSpecies(
      rid: (json['id'] ?? json['rid'])?.toString(),
      name: json['name'],
      alias: json['name_en'] ?? json['scientific_name'],
      cover: json['image_url'] ?? json['cover'],
      habitat: json['category'],
      description: json['description'],
      unlocked: json['unlocked'] ?? (catchCount is num && catchCount > 0),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['name'] = name;
    data['alias'] = alias;
    data['cover'] = cover;
    data['habitat'] = habitat;
    data['bait'] = bait;
    data['season'] = season;
    data['difficulty'] = difficulty;
    data['description'] = description;
    data['unlocked'] = unlocked;
    data['unlocked_at'] = unlocked_at;
    return data;
  }
}
