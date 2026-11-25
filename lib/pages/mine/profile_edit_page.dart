import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/global.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/mock/mine_data.dart';
import 'package:FishMark/utils/location_permission_util.dart';
import 'package:FishMark/utils/media_picker_util.dart';
import 'package:FishMark/utils/tdt_api.dart';
import 'package:FishMark/widgets/net_image.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 5.3.1 个人资料（头像上传 / 定位获取 / 保存均走接口）
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController =
      TextEditingController(text: MineData.user.name);
  String _gender = '男';
  String _birthday = '1995-08-12';
  String _location = '浙江 · 杭州';
  // 本地选中的头像（优先展示，上传成功后同步 user_update）
  String? _avatarPath;
  bool _uploadingAvatar = false;
  bool _locating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 更换头像：相册选图 → 上传 → user_update
  Future<void> _changeAvatar() async {
    if (_uploadingAvatar) return;
    final file = await MediaPickerUtil.pickSingleImage(context);
    if (!mounted || file == null) return;
    setState(() {
      _avatarPath = file.path;
      _uploadingAvatar = true;
    });
    try {
      final uploadResult = await Api().uploadAsset(file, 'upload_asset');
      if (!mounted) return;
      if (uploadResult['success'] && uploadResult['data'] != null) {
        final url = uploadResult['data']['url'] ?? '';
        await Api().post('user_update', data: {'avatar': url});
        if (!mounted) return;
        Fluttertoast.showToast(
            msg: Global.t('头像已更新', 'Avatar updated'));
      } else {
        Fluttertoast.showToast(msg: uploadResult['status']?['message'] ?? '上传失败');
      }
    } catch (e) {
      LogUtil.e('头像上传失败: $e');
      if (!mounted) return;
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
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
        if (text != null && text.isNotEmpty) _location = text;
      });
    } catch (e) {
      LogUtil.e('获取定位失败: $e');
      if (mounted) {
        Fluttertoast.showToast(msg: '定位失败，请检查定位权限');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // 保存资料：user_update
  Future<void> _save() async {
    try {
      final result = await Api().post('user_update', data: {
        'nickname': _nameController.text.trim(),
        'gender': _gender,
        'birthday': _birthday,
        'location': _location,
      });
      if (!mounted) return;
      if (result['success']) {
        Fluttertoast.showToast(
            msg: Global.t('已保存', 'Saved'));
      } else {
        Fluttertoast.showToast(msg: result['status']?['message'] ?? '保存失败');
      }
    } catch (e) {
      LogUtil.e('资料保存失败: $e');
      if (mounted) Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Constants.INPUT_BG,
        appBar: _buildAppBar(context),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 17.w, 16.w, 40.w),
          children: [
            // 头像（点击可更换）
            Center(
              child: GestureDetector(
                onTap: _changeAvatar,
                child: Stack(
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
                                width: 76.w,
                                height: 76.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : NetImage(
                              url: MineData.user.avatar,
                              width: 76.w,
                              height: 76.w,
                              borderRadius: 38.w,
                            ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                          color: Constants.LIME,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                        child: _uploadingAvatar
                            ? Padding(
                                padding: EdgeInsets.all(6.w),
                                child: const CircularProgressIndicator(
                                    strokeWidth: 1.5),
                              )
                            : Icon(RemixIcons.camera_fill,
                                size: 14.w, color: Constants.INK),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.w),
            Center(
              child: GestureDetector(
                onTap: _changeAvatar,
                child: Text(
                  Global.t('更换头像', 'Change Avatar'),
                  style: TextStyle(
                      fontSize: 12.5.sp, color: Constants.GRAY_LIGHT),
                ),
              ),
            ),
            SizedBox(height: 18.w),
            // 表单
            _buildGroup([
              _buildInputRow(
                Global.t('昵称', 'Nickname'),
                TextField(
                  controller: _nameController,
                  style: TextStyle(
                      fontSize: 14.5.sp,
                      color: Constants.INK,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: Global.t('输入昵称', 'Enter nickname'),
                    hintStyle:
                        TextStyle(fontSize: 14.5.sp, color: Constants.GRAY_LIGHT),
                  ),
                ),
              ),
              _divider(),
              _buildRow(Global.t('性别', 'Gender'), _gender, onTap: _pickGender),
              _divider(),
              _buildRow(Global.t('生日', 'Birthday'), _birthday,
                  onTap: _pickBirthday),
              _divider(),
              _buildRow(
                Global.t('所在地', 'Location'),
                _locating ? '定位中…' : _location,
                onTap: _pickLocation,
              ),
            ]),
            SizedBox(height: 28.w),
            LimeButton(
              text: Global.t('保存', 'Save'),
              height: 46,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  // 顶部导航
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    return PreferredSize(
      preferredSize: Size.fromHeight(statusBar + 44.w),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 44.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  Global.t('个人资料', 'Profile'),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Constants.INK,
                  ),
                ),
                Positioned(
                  left: 10.w,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(RemixIcons.arrow_left_s_line,
                        size: 26.w, color: Constants.INK),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(children: rows),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.only(left: 14.w),
      height: 0.5.w,
      color: const Color(0xFFEFEFEF),
    );
  }

  // 普通行：label + 值 + 箭头
  Widget _buildRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Constants.INK,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Constants.GRAY),
            ),
            SizedBox(width: 4.w),
            Icon(RemixIcons.arrow_right_s_line,
                size: 20.w, color: const Color(0xFFB8BCC4)),
          ],
        ),
      ),
    );
  }

  // 输入行：label + 输入框
  Widget _buildInputRow(String label, Widget field) {
    return Container(
      height: 52.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Constants.INK,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(child: field),
        ],
      ),
    );
  }

  // 性别选择
  void _pickGender() {
    final options = ['男', '女', Global.t('保密', 'Secret')];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((option) => InkWell(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        setState(() => _gender = option);
                      },
                      child: Container(
                        height: 52.w,
                        alignment: Alignment.center,
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: option == _gender
                                ? Constants.INK
                                : Constants.GRAY,
                            fontWeight: option == _gender
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  // 生日选择
  Future<void> _pickBirthday() async {
    final initial = DateTime.tryParse(_birthday) ??
        DateTime(1995, 8, 12);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthday =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }
}
