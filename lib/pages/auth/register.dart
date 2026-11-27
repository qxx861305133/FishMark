import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/models/user.dart';
import 'package:FishMark/pages/auth/profile_setup.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 0.2.3 用户注册（对接 POST /auth/register：手机号 + 密码，昵称/邮箱可选）
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;
    final phone = _mobileController.text.trim();
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (phone.length != 11) {
      Fluttertoast.showToast(msg: '请输入正确的手机号');
      return;
    }
    if (password.length < 6) {
      Fluttertoast.showToast(msg: '密码至少6位');
      return;
    }
    if (password != confirm) {
      Fluttertoast.showToast(msg: '两次输入的密码不一致');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await Api().post('auth_register', data: {
        'phone': phone,
        'password': password,
        if (nickname.isNotEmpty) 'nickname': nickname,
      });
      if (!mounted) return;
      final data = result['data'];
      if (result['success'] == true && data != null) {
        // 注册成功即视为登录（返回 token 与用户信息）
        final user = data['user'];
        Global.profile.token = data['access_token'];
        Global.profile.refreshToken = data['refresh_token'];
        Global.profile.user = User.fromApiUser(user, phone: phone);
        Global.saveProfile();
        Fluttertoast.showToast(msg: '注册成功');
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: result['message'] ?? '注册失败，请稍后重试');
      }
    } catch (e) {
      LogUtil.e('注册失败: $e');
      if (!mounted) return;
      Fluttertoast.showToast(msg: '$e'.replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TopGradientBox(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(pagePadding),
                child: const CircleBackButton(),
              ),
              SizedBox(height: 32.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Text(
                  '创建路记账号',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Constants.INK,
                  ),
                ),
              ),
              SizedBox(height: 12.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Text(
                  '注册后即可记录鱼获、分享钓点',
                  style: TextStyle(fontSize: 13.sp, color: Constants.GRAY),
                ),
              ),
              SizedBox(height: 36.w),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Column(
                    children: [
                      FillInput(
                        controller: _mobileController,
                        hint: '请输入手机号',
                        keyboardType: TextInputType.phone,
                        prefixIcon: RemixIcons.smartphone_line,
                      ),
                      SizedBox(height: 16.w),
                      FillInput(
                        controller: _nicknameController,
                        hint: '昵称（可选）',
                        prefixIcon: RemixIcons.user_3_line,
                      ),
                      SizedBox(height: 16.w),
                      FillInput(
                        controller: _passwordController,
                        hint: '设置密码（至少6位）',
                        obscureText: _obscure,
                        prefixIcon: RemixIcons.shield_check_line,
                        suffix: GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            _obscure
                                ? RemixIcons.eye_off_line
                                : RemixIcons.eye_line,
                            size: 20.w,
                            color: Constants.INK,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.w),
                      FillInput(
                        controller: _confirmController,
                        hint: '确认密码',
                        obscureText: _obscure,
                        prefixIcon: RemixIcons.shield_check_line,
                      ),
                      SizedBox(height: 44.w),
                      LimeButton(
                        text: _loading ? '注册中...' : '注  册',
                        onPressed: _register,
                      ),
                    ],
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
