import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/index.dart';
import 'package:FishMark/pages/auth/profile_setup.dart';
import 'package:FishMark/pages/auth/sms_code.dart';
import 'package:FishMark/pages/home.dart';
import 'package:FishMark/provider/profile.dart';
import 'package:FishMark/widgets/round_button.dart';

/// @desc 登录页（手机号 + 验证码）
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  // 勾选是否同意
  bool isAgree = false;
  // 提交中
  bool isSubmiting = false;

  @override
  void initState() {
    super.initState();
    // 如已登录，则直接进首页
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      if (Global.profile.user != null &&
          Global.profile.user!.is_login == true) {
        _goHome();
      }
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  /// 发送验证码
  Future<void> _handleSendSms() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 11) {
      Fluttertoast.showToast(
        msg: '请输入正确的手机号',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    if (!isAgree) {
      Fluttertoast.showToast(
        msg: '请先勾选同意《用户协议》和《隐私政策》',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() => isSubmiting = true);
    try {
      var result = await Api().post(
        'send_sms',
        data: {'mobile': mobile, 'scene': 'login'},
      );
      setState(() => isSubmiting = false);
      if (result['success']) {
        LogUtil.v('验证码发送成功 >>>>> ${result['data']}');
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SmsCodePage(mobile: mobile),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: result['status']['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      setState(() => isSubmiting = false);
      LogUtil.e('发送验证码失败: $e');
      Fluttertoast.showToast(
        msg: '网络异常，请稍后重试',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120.w),
              Icon(Icons.phishing, size: 120.w, color: Constants.PRIMARY_COLOR),
              SizedBox(height: 24.w),
              Text(
                '欢迎来到${Constants.APP_NAME}',
                style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.TEXT_DEFAULT_COLOR,
                ),
              ),
              Text(
                Constants.APP_SLOGAN,
                style: TextStyle(
                  fontSize: 26.sp,
                  color: Constants.TEXT_SECONDARY_COLOR,
                ),
              ),
              SizedBox(height: 96.w),
              Text('手机号',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(height: 16.w),
              Row(
                children: [
                  Text('+86',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      style: TextStyle(fontSize: 32.sp),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '请输入手机号',
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.LINE_COLOR),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 64.w),
              RoundButton(
                text: '获取验证码',
                loading: isSubmiting,
                onPressed: _handleSendSms,
              ),
              SizedBox(height: 40.w),
              GestureDetector(
                onTap: () => setState(() => isAgree = !isAgree),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAgree
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 32.w,
                      color: isAgree
                          ? Constants.PRIMARY_COLOR
                          : Constants.TEXT_LIGHT_COLOR,
                    ),
                    SizedBox(width: 8.w),
                    Text('登录即代表同意',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Constants.TEXT_SECONDARY_COLOR,
                        )),
                    Text('《用户协议》',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Constants.PRIMARY_COLOR,
                        )),
                    Text('和',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Constants.TEXT_SECONDARY_COLOR,
                        )),
                    Text('《隐私政策》',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Constants.PRIMARY_COLOR,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 60.w),
              // 游客入口
              Center(
                child: TextButton(
                  onPressed: _goHome,
                  child: Text(
                    '先逛逛 >',
                    style: TextStyle(
                      fontSize: 28.sp,
                      color: Constants.TEXT_LIGHT_COLOR,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// @desc 登录成功后的用户状态处理（供验证码页复用）
Future<void> handleLoginSuccess(BuildContext context, dynamic data) async {
  // 更新profile中的token信息
  Global.profile.token = data['token'];
  Global.saveProfile();

  // 更新用户信息
  data['user']['is_login'] = true;
  final user = User.fromJson(data['user']);
  if (!context.mounted) return;
  Provider.of<UserNotifier>(context, listen: false).user = user;

  // 未完成兴趣/地区初始化 -> 引导页
  if (user.region == null || user.region!.isEmpty) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
      (route) => false,
    );
    return;
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomePage()),
    (route) => false,
  );
}
