// ignore_for_file: non_constant_identifier_names
import 'package:luji_app/models/catch_record.dart';
import 'package:luji_app/models/user.dart';

/// @desc 鱼获动态（社区Feed）
class Feed {
  // 动态ID
  String? rid;
  // 发布者
  User? user;
  // 关联鱼获
  CatchRecord? catch_record;
  // 图片
  List<String>? images;
  // 文案
  String? content;
  // 点赞数
  int? likes;
  // 评论数
  int? comments_count;
  // 当前用户是否已点赞
  bool? liked;
  // 发布时间
  String? created_at;

  Feed({
    this.rid,
    this.user,
    this.catch_record,
    this.images,
    this.content,
    this.likes,
    this.comments_count,
    this.liked,
    this.created_at,
  });

  Feed.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    catch_record = json['catch'] != null
        ? CatchRecord.fromJson(json['catch'])
        : null;
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    content = json['content'];
    likes = json['likes'] ?? 0;
    comments_count = json['comments_count'] ?? 0;
    liked = json['liked'] ?? false;
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (catch_record != null) {
      data['catch'] = catch_record!.toJson();
    }
    data['images'] = images;
    data['content'] = content;
    data['likes'] = likes;
    data['comments_count'] = comments_count;
    data['liked'] = liked;
    data['created_at'] = created_at;
    return data;
  }
}
