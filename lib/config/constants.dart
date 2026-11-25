// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

/// @desc 全局常量
class Constants {
  // 调试模式
  static const bool isDebug = true;

  // 本地模拟数据开关（无后端时全流程走通，接入真实后端时置为 false）
  static const bool useMock = true;

  // APP名称
  static const String APP_NAME = '路记';

  // Slogan
  static const String APP_SLOGAN = '每一尾皆是勋章';

  // 版本号
  static const String APP_VERSION = '1.0.0';

  // 客服电话
  static const String SERVICE_PHONE = '+8610000000000';

  // 选择图片最大数量
  static const int SELECTED_MAX_COUNT = 9;

  // 分页大小
  static const int MAX_PAGE_SIZE = 20;

  // ===== 1104 设计稿色彩体系 =====
  // 主色（荧光柠檬绿）
  static const Color LIME = Color(0xFFC7FF3F);
  // 墨色主文字
  static const Color INK = Color(0xFF101010);
  // 次级文字
  static const Color GRAY = Color(0xFF666666);
  // 占位/提示文字
  static const Color GRAY_LIGHT = Color(0xFF999999);
  // 输入框底色
  static const Color INPUT_BG = Color(0xFFF5F7FB);
  // 描边
  static const Color BORDER = Color(0xFFE5E7EB);
  // 顶部渐变起点（柠檬浅绿 → 白）
  static const Color GRAD_TOP = Color(0xFFEEFFC5);
  // 卡片底色
  static const Color CARD_BG = Color(0xFFFFFFFF);

  // 主调色（深水蓝）
  static const Color PRIMARY_COLOR = Color.fromRGBO(11, 87, 98, 1.0);
  // 辅助色
  static const Color SECONDARY_COLOR = Color.fromRGBO(11, 87, 98, 0.8);
  // 高亮强调色（鱼获金）
  static const Color HIGHLIGHT_COLOR = Color.fromRGBO(230, 168, 24, 1.0);
  // 文字颜色
  static const Color TEXT_DEFAULT_COLOR = Color.fromRGBO(0, 0, 0, 0.9);
  // 文字辅助颜色
  static const Color TEXT_SECONDARY_COLOR = Color.fromRGBO(0, 0, 0, 0.6);
  // 文字提示颜色
  static const Color TEXT_LIGHT_COLOR = Color.fromRGBO(0, 0, 0, 0.4);
  // 背景色
  static const Color BG_COLOR = Color.fromRGBO(245, 246, 248, 1.0);
  // 辅助线颜色
  static const Color LINE_COLOR = Color.fromRGBO(242, 243, 245, 1);
  // 成功颜色
  static const Color SUCCESS_COLOR = Color.fromRGBO(22, 119, 255, 0.0);
  // 错误颜色
  static const Color ERROR_COLOR = Color.fromRGBO(192, 38, 30, 1.0);
  // 警告颜色
  static const Color WARNING_COLOR = Color.fromRGBO(190, 120, 20, 1.0);
  // 禁用或为空颜色
  static const Color DISABLED_COLOR = Color.fromRGBO(0, 0, 0, 0.2);

  // 勋章稀有度颜色：普通/稀有/史诗/传说
  static const Map<String, Color> MEDAL_RARITY_COLORS = {
    'common': Color.fromRGBO(144, 147, 153, 1.0),
    'rare': Color.fromRGBO(36, 129, 219, 1.0),
    'epic': Color.fromRGBO(124, 58, 237, 1.0),
    'legend': Color.fromRGBO(230, 168, 24, 1.0),
  };

  // 阿里云百炼（AI识鱼）
  static const String DASHSCOPE_API_URL =
      'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation';

  // 微信开放平台（fluwx 分享用，占位 AppID，接入正式环境时替换）
  static const String WX_APP_ID = 'wxd930ea5d5a228f5f';
  // iOS 通用链接（微信回跳，占位）
  static const String WX_UNIVERSAL_LINK = 'https://www.luji.cn/app/';

  // 默认占位图
  static const String DEFAULT_PLACEHOLDER =
      'https://s3.luji.cn/static/img/placeholder-small.png';

  // 个人信息保护政策
  static const String PrivacyPolicyText = '''
  为了保障您的个人权益，在您使用路记App产品或服务前，请您仔细阅读并同意我们的《用户协议》《隐私政策》《第三方信息共享清单》。当您点击“同意并继续”并开始使用本产品服务时，即表示您已理解并同意该条款内容。
  ''';
}
