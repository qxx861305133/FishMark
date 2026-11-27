import 'package:dio/dio.dart';

import 'package:FishMark/config/api_keys.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';

/// @desc 请求拦截器
///
/// 自动附加：
/// - X-API-Key：应用识别与限流（后台 /admin/api-clients 创建）
/// - Authorization: Bearer <access_token>：用户登录凭据
/// - 路径参数替换：catches/catch_id ← queryParameters['catch_id']
class RequestInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    LogUtil.v('Request base url：${options.baseUrl}');
    LogUtil.v('Request path：${options.path}');

    // 路径参数替换：{key} / :key 两种占位符均支持
    final params = Map<String, dynamic>.from(options.queryParameters);
    params.forEach((key, value) {
      if (options.path.contains('{$key}')) {
        options.path = options.path.replaceAll('{$key}', value.toString());
        params.remove(key);
      } else if (options.path.contains(':$key')) {
        options.path = options.path.replaceAll(':$key', value.toString());
        params.remove(key);
      }
    });
    options.queryParameters
      ..clear()
      ..addAll(params);

    // 应用标识与限流
    options.headers['X-API-Key'] = fishMarkApiKey;

    // 用户登录凭据
    LogUtil.v('Token：${Global.profile.token}');
    if (Global.profile.token != null) {
      options.headers['Authorization'] = 'Bearer ${Global.profile.token}';
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
