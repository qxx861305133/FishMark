import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/widgets/round_button.dart';

/// @desc 钓点上传页
class SpotUploadPage extends StatefulWidget {
  const SpotUploadPage({super.key});

  @override
  State<SpotUploadPage> createState() => _SpotUploadPageState();
}

class _SpotUploadPageState extends State<SpotUploadPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();

  // 钓点类型
  String _type = 'river';
  // 提交中
  bool _isSubmiting = false;

  static const Map<String, String> _typeMap = {
    'river': '江河',
    'lake': '湖泊',
    'reservoir': '水库',
    'sea': '海钓',
    'pond': '黑坑',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _feeController.dispose();
    _openTimeController.dispose();
    super.dispose();
  }

  // 提交
  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '请填写钓点名称');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '请填写钓点地址');
      return;
    }

    setState(() => _isSubmiting = true);
    try {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      if (lat == null || lng == null) {
        if (!mounted) return;
        setState(() => _isSubmiting = false);
        Fluttertoast.showToast(msg: '请填写有效的经纬度坐标');
        return;
      }
      final result = await Api().post('spots', data: {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'water_type': _type,
        'latitude': lat,
        'longitude': lng,
      });
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      if (result['success'] == true) {
        Fluttertoast.showToast(msg: '钓点提交成功，感谢分享');
        Navigator.of(context).pop();
      } else {
        final error = result['error'];
        Fluttertoast.showToast(
            msg: error is Map ? error['message'] ?? '提交失败' : '提交失败');
      }
    } catch (e) {
      LogUtil.e('钓点提交失败: $e');
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      Fluttertoast.showToast(msg: '$e'.replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('上传钓点', style: TextStyle(fontSize: 34.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32.w, 16.w, 32.w, 80.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('钓点名称 *', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_nameController, '如：青山湖大坝夜钓位'),
            SizedBox(height: 32.w),
            Text('钓点类型', style: _labelStyle()),
            SizedBox(height: 16.w),
            Wrap(
              spacing: 16.w,
              runSpacing: 16.w,
              children: _typeMap.entries.map((entry) {
                final selected = _type == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selected,
                  selectedColor:
                      Constants.PRIMARY_COLOR.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 26.sp,
                    color: selected
                        ? Constants.PRIMARY_COLOR
                        : Constants.TEXT_SECONDARY_COLOR,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: selected
                        ? Constants.PRIMARY_COLOR
                        : Constants.LINE_COLOR,
                  ),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _type = entry.key),
                );
              }).toList(),
            ),
            SizedBox(height: 32.w),
            Text('详细地址 *', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_addressController, '省市区 + 具体位置描述'),
            SizedBox(height: 32.w),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('纬度 Lat', style: _labelStyle()),
                      SizedBox(height: 16.w),
                      _buildField(_latController, '选填', isNumber: true),
                    ],
                  ),
                ),
                SizedBox(width: 32.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('经度 Lng', style: _labelStyle()),
                      SizedBox(height: 16.w),
                      _buildField(_lngController, '选填', isNumber: true),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.w),
            Text('收费说明', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_feeController, '如：免费 / 100元/天'),
            SizedBox(height: 32.w),
            Text('开放时间', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_openTimeController, '如：全天开放 / 6:00-22:00'),
            SizedBox(height: 64.w),
            RoundButton(
              text: '提交钓点',
              loading: _isSubmiting,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  // 输入框
  Widget _buildField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: TextStyle(fontSize: 28.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 26.sp,
          color: Constants.TEXT_LIGHT_COLOR,
        ),
        filled: true,
        fillColor: Constants.BG_COLOR,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 标签样式
  TextStyle _labelStyle() {
    return TextStyle(
      fontSize: 28.sp,
      fontWeight: FontWeight.w600,
      color: Constants.TEXT_DEFAULT_COLOR,
    );
  }
}
