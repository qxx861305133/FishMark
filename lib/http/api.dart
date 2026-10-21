import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luji_app/config/api_urls.dart';
import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/http/request_interceptor.dart';
import 'package:luji_app/mock/mock_data.dart';

/// API: 数据请求接口
class Api {
  // 在网络请求过程中可能会需要使用当前的context信息，比如在请求失败时
  // 打开一个新路由，而打开新路由需要context信息。
  Api() {
    // skip
  }

  final Options _options = Options(
    extra: {},
  );
  static SharedPreferences? _prefs;
  static bool _isProduction = true; // true 正式。 false 测试

  // API 地址配置
  static const String _prodUrl = 'https://api.luji.cn/v1.0';
  static const String _devUrl = 'https://api-dev.luji.cn/v1.0';
  static String get _currentEnvironment => _isProduction ? _prodUrl : _devUrl;
  static Dio dio = Dio();

  static Future<void> init() async {
    // 初始化 SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    // 从本地读取保存的环境设置 默认正式环境（true）
    final savedValue = _prefs?.getBool('is_production');
    _isProduction = savedValue ?? true; // 如果没有保存过，默认正式环境
    dio = Dio(
      BaseOptions(
        baseUrl: _currentEnvironment,
        connectTimeout: const Duration(seconds: 30),
      ),
    );
    // 添加请求插件
    dio.interceptors.add(RequestInterceptors());
  }

  // 切换环境
  Future<void> toggleEnvironment() async {
    _isProduction = !_isProduction;
    _updateBaseUrl();

    // 保存到本地
    if (_prefs != null) {
      await _prefs!.setBool('is_production', _isProduction);
    }
  }

  void _updateBaseUrl() {
    if (_isProduction) {
      Fluttertoast.showToast(
        msg: '已切换到正式环境',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    } else {
      Fluttertoast.showToast(
        msg: '已切换到测试环境',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
    dio.options.baseUrl = _currentEnvironment;
  }

  /// Get方法
  Future<Map<String, dynamic>> get(String pathName,
      {Map<String, dynamic>? queryParameters, refresh = false}) async {
    // 本地模拟数据
    if (Constants.useMock) {
      return MockApi.handle(pathName, query: queryParameters);
    }
    if (refresh) {
      // 列表下拉刷新，需要删除缓存（拦截器中会读取这些信息）
      _options.extra!.addAll({'refresh': true, 'list': true});
    }
    var result = await dio.get(ApiUrls[pathName]!,
        queryParameters: queryParameters, options: _options);

    // 检测结果
    if (result.statusCode == 200) {
      LogUtil.v('Get Result >>>>> ${result.data}');
      return result.data;
    } else {
      throw Exception('Request Api failed!');
    }
  }

  /// Post方法
  Future<Map<String, dynamic>> post(String pathName,
      {Map<String, dynamic>? data}) async {
    // 本地模拟数据
    if (Constants.useMock) {
      return MockApi.handle(pathName, data: data);
    }
    LogUtil.v('Post data >>>>> $data');
    var result = await dio.post(ApiUrls[pathName]!, data: data);
    LogUtil.v('Post result >>>>> $result');
    return result.data;
  }

  /// 上传附件
  Future<Map<String, dynamic>> uploadAsset(
    XFile image,
    String endpoint, {
    int? userId,
    void Function(int sent, int total)? onProgress,
  }) async {
    // 本地模拟数据
    if (Constants.useMock) {
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

    var result = await dio.post(
      ApiUrls[endpoint]!,
      data: formData,
      onSendProgress: onProgress,
    );
    LogUtil.v('上传附件result >>>>> $result');
    return result.data;
  }

  /// 上传字节数据（AI识鱼拍照直传等场景）
  Future<Map<String, dynamic>> uploadBytes(
    Uint8List bytes,
    String endpoint, {
    String filename = 'fish.jpg',
    void Function(int sent, int total)? onProgress,
  }) async {
    // 本地模拟数据
    if (Constants.useMock) {
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

    var result = await dio.post(
      ApiUrls[endpoint]!,
      data: formData,
      onSendProgress: onProgress,
    );
    LogUtil.v('上传字节result >>>>> $result');
    return result.data;
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

  /// 上传文件
  Future<dynamic> uploadFile(FormData formData, String path) async {
    LogUtil.v('上传文件path >>>>> $path');
    var result = await dio.post(path, data: formData);
    LogUtil.v('上传文件result >>>>> $result');
    return result;
  }
}
