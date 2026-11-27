import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'package:FishMark/config/api_urls.dart';
import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/request_interceptor.dart';
import 'package:FishMark/mock/mock_data.dart';

/// API: 数据请求接口
///
/// 对接 FishMark 移动端 RESTful API（https://api.fishmark.me/apidocs/）：
/// - baseUrl: https://api.fishmark.me/api/v1
/// - 认证: Authorization: Bearer access_token（拦截器自动附加）
/// - 响应统一包裹为 success/data/message（错误为 error.code/message）
class Api {
  Api() {
    // skip
  }

  final Options _options = Options(
    extra: {},
  );

  // API 地址（FishMark 服务端）
  static const String baseUrl = 'https://api.fishmark.me/api/v1';
  static Dio dio = Dio();

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
      ),
    );
    // 添加请求插件
    dio.interceptors.add(RequestInterceptors());
  }

  /// 是否走本地 Mock：
  /// 1. 全局开关 Constants.useMock 开启时全部走 Mock
  /// 2. 真实 API 尚未提供的端点（如图片上传、挑战系统）始终走 Mock
  static bool _shouldMock(String pathName) =>
      Constants.useMock || !ApiUrls.containsKey(pathName);

  /// Get方法（返回服务端原始包裹结构 {success, data, ...}）
  Future<Map<String, dynamic>> get(String pathName,
      {Map<String, dynamic>? queryParameters, refresh = false}) async {
    if (_shouldMock(pathName)) {
      return MockApi.handle(pathName, query: queryParameters);
    }
    if (refresh) {
      // 列表下拉刷新，需要删除缓存（拦截器中会读取这些信息）
      _options.extra!.addAll({'refresh': true, 'list': true});
    }
    try {
      final result = await dio.get(ApiUrls[pathName]!,
          queryParameters: queryParameters, options: _options);
      LogUtil.v('Get Result >>>>> ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  /// Post方法（返回服务端原始包裹结构 {success, data, ...}）
  Future<Map<String, dynamic>> post(String pathName,
      {Map<String, dynamic>? data}) async {
    if (_shouldMock(pathName)) {
      return MockApi.handle(pathName, data: data);
    }
    LogUtil.v('Post data >>>>> $data');
    try {
      final result = await dio.post(ApiUrls[pathName]!, data: data);
      LogUtil.v('Post result >>>>> $result');
      return Map<String, dynamic>.from(result.data);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  /// Put方法
  Future<Map<String, dynamic>> put(String pathName,
      {Map<String, dynamic>? data}) async {
    if (_shouldMock(pathName)) {
      return MockApi.handle(pathName, data: data);
    }
    LogUtil.v('Put data >>>>> $data');
    try {
      final result = await dio.put(ApiUrls[pathName]!, data: data);
      LogUtil.v('Put result >>>>> $result');
      return Map<String, dynamic>.from(result.data);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  /// Delete方法
  Future<Map<String, dynamic>> delete(String pathName,
      {Map<String, dynamic>? queryParameters}) async {
    if (_shouldMock(pathName)) {
      return MockApi.handle(pathName, query: queryParameters);
    }
    try {
      final result = await dio.delete(ApiUrls[pathName]!,
          queryParameters: queryParameters);
      LogUtil.v('Delete result >>>>> $result');
      return Map<String, dynamic>.from(result.data);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  /// 统一错误信息提取
  Exception _wrapError(DioException e) {
    final resp = e.response;
    if (resp?.data is Map) {
      final data = Map<String, dynamic>.from(resp!.data);
      final error = data['error'];
      if (error is Map) {
        return Exception(error['message'] ?? '请求失败(${resp.statusCode})');
      }
      final message = data['message'];
      if (message != null) return Exception(message);
    }
    return Exception('网络请求失败: ${e.message}');
  }

  /// 上传附件
  ///
  /// 注意：真实服务端暂未暴露图片上传端点（各创建接口要求的 asset_ids 上传后获取），
  /// 当前上传流程保持本地 Mock，待服务端补充上传接口后接入。
  Future<Map<String, dynamic>> uploadAsset(
    XFile image,
    String endpoint, {
    int? userId,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (_shouldMock(endpoint)) {
      return MockApi.handle(endpoint);
    }
    LogUtil.v('上传附件path >>>>> ${image.path}');
    String path = image.path;
    final name = path.substring(path.lastIndexOf('/') + 1, path.length);
    final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
    final newName = '${DateTime.now().millisecondsSinceEpoch}-$name';

    var imageFile = await MultipartFile.fromFile(
      path,
      filename: name,
      contentType: DioMediaType.parse(mimeType),
    );

    FormData formData = FormData.fromMap({
      'file': imageFile,
      'filename': newName,
      'user_id': userId,
    });

    try {
      var result = await dio.post(
        ApiUrls[endpoint]!,
        data: formData,
        onSendProgress: onProgress,
      );
      LogUtil.v('上传附件result >>>>> $result');
      return Map<String, dynamic>.from(result.data);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  /// 上传字节数据（AI识鱼拍照直传等场景）
  ///
  /// 注意：真实服务端的 AI 识鱼接口为 POST /ai/recognize（JSON body，base64），
  /// 已由页面直接调用；本方法保留给未来二进制上传端点使用。
  Future<Map<String, dynamic>> uploadBytes(
    Uint8List bytes,
    String endpoint, {
    String filename = 'fish.jpg',
    void Function(int sent, int total)? onProgress,
  }) async {
    if (_shouldMock(endpoint)) {
      return MockApi.handle(endpoint);
    }
    final mimeType = lookupMimeType(filename) ?? 'image/jpeg';
    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(mimeType),
      ),
    });

    try {
      var result = await dio.post(
        ApiUrls[endpoint]!,
        data: formData,
        onSendProgress: onProgress,
      );
      LogUtil.v('上传字节result >>>>> $result');
      return Map<String, dynamic>.from(result.data);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  /// 下载文件
  Future<dynamic> downloadFile(String urlPath, String savePath,
      {void Function(int, int)? onProgress}) async {
    var result = await dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onProgress,
    );
    LogUtil.v('下载文件result >>>>> $result');
    return result;
  }
}
