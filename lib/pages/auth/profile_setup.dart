import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/pages/home.dart';
import 'package:FishMark/widgets/round_button.dart';

/// @desc 兴趣/地区初始化（首次登录引导）
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  // 多选的兴趣标签
  final List<String> _interests = [];
  List<String> _interestOptions = [];
  // 常驻地区（单选）
  List<String> _regionOptions = [];
  String? _region;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  /// 加载兴趣标签与地区列表
  Future<void> _loadOptions() async {
    try {
      var interestResult = await Api().get('interests');
      var regionResult = await Api().get('regions', queryParameters: {'level': 1});
      if (mounted) {
        setState(() {
          _interestOptions = interestResult['success']
              ? List<String>.from(
                  (interestResult['data'] as List).map((e) => e['name']))
              : [];
          _regionOptions = regionResult['success']
              ? List<String>.from(
                  (regionResult['data'] as List).map((e) => e['name']))
              : [];
          _loading = false;
        });
      }
    } catch (e) {
      LogUtil.e('初始化选项加载失败: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// 提交初始化信息
  Future<void> _handleSubmit() async {
    if (_region == null) {
      Fluttertoast.showToast(
        msg: '请选择常驻地区',
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      var result = await Api().post(
        'user_init_profile',
        data: {
          'region': _region,
          'interests': _interests,
        },
      );
      setState(() => _submitting = false);
      if (result['success']) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(
          msg: result['status']['message'],
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      LogUtil.e('初始化提交失败: $e');
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 96.w),
                    Text(
                      '完善你的钓鱼档案',
                      style: TextStyle(
                        fontSize: 44.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.w),
                    Text(
                      '告诉我们你的偏好，为你定制挑战与鱼情推荐',
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 64.w),
                    // 常驻地区
                    Text('常驻地区',
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(height: 24.w),
                    Wrap(
                      spacing: 20.w,
                      runSpacing: 20.w,
                      children: _regionOptions.map((name) {
                        final selected = _region == name;
                        return ChoiceChip(
                          label: Text(name),
                          selected: selected,
                          selectedColor:
                              const Color(0xFF0B5762).withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            fontSize: 26.sp,
                            color: selected
                                ? const Color(0xFF0B5762)
                                : Colors.black54,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.w),
                            side: BorderSide(
                              color: selected
                                  ? const Color(0xFF0B5762)
                                  : Colors.black12,
                            ),
                          ),
                          onSelected: (_) => setState(() => _region = name),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 64.w),
                    // 兴趣标签
                    Text('感兴趣的鱼种/钓法（多选）',
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(height: 24.w),
                    Wrap(
                      spacing: 20.w,
                      runSpacing: 20.w,
                      children: _interestOptions.map((name) {
                        final selected = _interests.contains(name);
                        return FilterChip(
                          label: Text(name),
                          selected: selected,
                          selectedColor:
                              const Color(0xFF0B5762).withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            fontSize: 26.sp,
                            color: selected
                                ? const Color(0xFF0B5762)
                                : Colors.black54,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.w),
                            side: BorderSide(
                              color: selected
                                  ? const Color(0xFF0B5762)
                                  : Colors.black12,
                            ),
                          ),
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _interests.add(name);
                              } else {
                                _interests.remove(name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 96.w),
                    RoundButton(
                      text: '开始路亚之旅',
                      loading: _submitting,
                      onPressed: _handleSubmit,
                    ),
                    SizedBox(height: 40.w),
                  ],
                ),
              ),
            ),
    );
  }
}
