import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/mock/mine_data.dart';
import 'package:FishMark/pages/home.dart';
import 'package:FishMark/utils/location_permission_util.dart';
import 'package:FishMark/utils/media_picker_util.dart';
import 'package:FishMark/utils/tdt_api.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 0.4.1 基础信息（登录后完善昵称/头像/位置，均接真实交互）
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _avatarPath;
  bool _uploadingAvatar = false;
  bool _locating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 更换头像：相册选图 → 本地预览（头像上传端点待服务端上线后接入）
  Future<void> _changeAvatar() async {
    if (_uploadingAvatar) return;
    final file = await MediaPickerUtil.pickSingleImage(context);
    if (!mounted || file == null) return;
    setState(() {
      _avatarPath = file.path;
      _uploadingAvatar = false;
    });
    // TODO: 图片上传端点待服务端上线后接入，届时上传照片换取 avatar_asset_id 并 PUT /users/me
  }

  // 定位获取所在地：定位权限 → 当前坐标 → 天地图逆地理编码
  Future<void> _pickLocation() async {
    if (_locating) return;
    final ok = await ensureLocationPermission(context);
    if (!ok || !mounted) return;
    setState(() => _locating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;
      final text = await TdtApi.reverseGeocode(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        if (text != null && text.isNotEmpty) {
          _locationController.text = text;
        }
      });
    } catch (e) {
      LogUtil.e('获取定位失败: $e');
      if (mounted) Fluttertoast.showToast(msg: '定位失败，请检查定位权限');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // 确认：保存昵称 → PUT /users/me（所在地字段服务端暂未提供，仅本地保留）
  Future<void> _confirm() async {
    final nickname = _nameController.text.trim();
    try {
      await Api().put('user_update', data: {
        if (nickname.isNotEmpty) 'nickname': nickname,
      });
    } catch (e) {
      LogUtil.e('资料保存失败: $e');
    }
    if (!mounted) return;
    _goHome();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TopGradientBox(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 右上角跳过
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(pagePadding),
                    child: GestureDetector(
                      onTap: _goHome,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 6.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          Global.t('跳过', 'Skip'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF21582F),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 36.w),
                // 头像（点击更换）
                Center(
                  child: GestureDetector(
                    onTap: _changeAvatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.w),
                          ),
                          child: _avatarPath != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_avatarPath!),
                                    width: 96.w,
                                    height: 96.w,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : NetImage(
                                  url: MineData.user.avatar,
                                  width: 96.w,
                                  height: 96.w,
                                  borderRadius: 48.w,
                                ),
                        ),
                        Positioned(
                          right: -2.w,
                          bottom: 0,
                          child: Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: Constants.LIME,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2.w),
                            ),
                            child: _uploadingAvatar
                                ? Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 1.5),
                                  )
                                : Icon(
                                    RemixIcons.camera_fill,
                                    size: 18.w,
                                    color: Constants.INK,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 68.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Column(
                    children: [
                      FillInput(
                        controller: _nameController,
                        hint: Global.t('请输入您的昵称', 'Enter your nickname'),
                      ),
                      SizedBox(height: 16.w),
                      // 所在地（点击定位）
                      GestureDetector(
                        onTap: _pickLocation,
                        child: FillInput(
                          readOnly: true,
                          controller: _locationController,
                          hint: Global.t('请选择您的位置', 'Select your location'),
                          suffix: Padding(
                            padding: EdgeInsets.only(left: 10.w),
                            child: Icon(
                              RemixIcons.map_pin_2_fill,
                              size: 20.w,
                              color: Constants.INK,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 44.w),
                      LimeButton(
                        text: Global.t('确 定', 'Confirm'),
                        onPressed: _confirm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
