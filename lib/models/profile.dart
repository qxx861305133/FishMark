// ignore_for_file: non_constant_identifier_names
import 'package:FishMark/models/user.dart';

/// @desc 持久化系统配置
class Profile {
  // 登录凭证
  String? token;
  // 刷新令牌（POST /auth/refresh 用）
  String? refreshToken;
  // 用户信息
  User? user;

  Profile({this.token, this.refreshToken, this.user});

  Profile.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    refreshToken = json['refresh_token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (refreshToken != null) {
      data['refresh_token'] = refreshToken;
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
