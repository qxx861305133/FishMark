// ignore_for_file: non_constant_identifier_names
import 'package:luji_app/models/user.dart';

/// @desc 持久化系统配置
class Profile {
  // 登录凭证
  String? token;
  // 用户信息
  User? user;

  Profile({this.token, this.user});

  Profile.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
