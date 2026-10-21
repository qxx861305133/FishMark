import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/http/api.dart';
import 'package:luji_app/pages/auth/login.dart';
import 'package:luji_app/widgets/round_button.dart';

/// @desc 验证码输入页
class SmsCodePage extends StatefulWidget {
  final String mobile;
  const SmsCodePage({super.key, required this.mobile});

  @override
  State<SmsCodePage> createState() => _SmsCodePageState();
}

class _SmsCodePageState extends State<SmsCodePage> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  // 倒计时
  Timer? _timer;
  int _countdown = 60;
  // 提交中
  bool isSubmiting = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // 自动聚焦弹出键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 0) {
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  /// 重新发送
  Future<void> _handleResend() async {
    if (_countdown > 0) return;
    try {
      var result = await Api().post(
        'send_sms',
        data: {'mobile': widget.mobile, 'scene': 'login'},
      );
      if (result['success']) {
        Fluttertoast.showToast(
          msg: '验证码已重新发送',
          gravity: ToastGravity.CENTER,
        );
        _startCountdown();
      } else {
        Fluttertoast.showToast(
          msg: result['status']['message'],
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      LogUtil.e('重发验证码失败: $e');
    }
  }

  /// 验证码登录
  Future<void> _handleLogin(String code) async {
    if (code.length != 6 || isSubmiting) return;
    setState(() => isSubmiting = true);
    try {
      var result = await Api().post(
        'sms_login',
        data: {'mobile': widget.mobile, 'code': code},
      );
      setState(() => isSubmiting = false);
      if (result['success']) {
        Fluttertoast.showToast(
          msg: '登录成功',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        if (!mounted) return;
        await handleLoginSuccess(context, result['data']);
      } else {
        Fluttertoast.showToast(
          msg: result['status']['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      setState(() => isSubmiting = false);
      LogUtil.e('验证码登录失败: $e');
      Fluttertoast.showToast(
        msg: '网络异常，请稍后重试',
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.w),
              Text(
                '输入验证码',
                style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 24.w),
              Text.rich(
                TextSpan(
                  text: '验证码已发送至 ',
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Constants.TEXT_SECONDARY_COLOR,
                  ),
                  children: [
                    TextSpan(
                      text: widget.mobile,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 64.w),
              // 验证码输入框
              TextField(
                controller: _codeController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                style: TextStyle(
                    fontSize: 48.sp, letterSpacing: 16.w),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '6位数字验证码',
                  hintStyle: TextStyle(fontSize: 30.sp, letterSpacing: 0),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _handleLogin(value);
                  }
                },
              ),
              SizedBox(height: 32.w),
              GestureDetector(
                onTap: _handleResend,
                child: Text(
                  _countdown > 0 ? '${_countdown}s后可重发' : '重新发送',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: _countdown > 0
                        ? Colors.black38
                        : Constants.PRIMARY_COLOR,
                  ),
                ),
              ),
              SizedBox(height: 64.w),
              RoundButton(
                text: '登录',
                loading: isSubmiting,
                onPressed: () => _handleLogin(_codeController.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
