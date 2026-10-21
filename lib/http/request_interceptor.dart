import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';

/// @desc 请求拦截器
class RequestInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    LogUtil.v('Request base url：${options.baseUrl}');
    LogUtil.v('Request path：${options.path}');

    // 参数处理
    options.queryParameters.forEach((key, value) {
      if (options.path.contains(key)) {
        options.path = options.path.replaceAll(':$key', value.toString());
      }
    });

    // 添加Token
    LogUtil.v('Token：${Global.profile.token}');
    if (Global.profile.token != null) {
      String basic =
          'Basic ${base64.encode(utf8.encode('${Global.profile.token}:${Global.profile.token}'))}';
      options.headers['authorization'] = basic;
    }

    LogUtil.v('Request headers：${options.headers}');

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    LogUtil.e('请求异常：${err.message}');
    handler.next(err);
  }
}
