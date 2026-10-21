import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/config/log_util.dart';
import 'package:FishMark/http/api.dart';
import 'package:FishMark/widgets/round_button.dart';

/// @desc 装备上传页
class GearUploadPage extends StatefulWidget {
  const GearUploadPage({super.key});

  @override
  State<GearUploadPage> createState() => _GearUploadPageState();
}

class _GearUploadPageState extends State<GearUploadPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _buyAtController = TextEditingController();

  // 装备分类
  String _category = 'rod';
  // 提交中
  bool _isSubmiting = false;

  static const Map<String, String> _categoryMap = {
    'rod': '路亚竿',
    'reel': '渔轮',
    'line': '鱼线',
    'lure': '拟饵',
    'accessory': '配件',
  };

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _buyAtController.dispose();
    super.dispose();
  }

  // 提交
  Future<void> _handleSubmit() async {
    if (_brandController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '请填写品牌');
      return;
    }
    if (_modelController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '请填写型号');
      return;
    }

    setState(() => _isSubmiting = true);
    try {
      final result = await Api().post('gear_submit', data: {
        'category': _category,
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()),
        'buy_at': _buyAtController.text.trim(),
      });
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      if (result['success']) {
        Fluttertoast.showToast(msg: '装备已入库');
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('装备提交失败: $e');
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('上传装备', style: TextStyle(fontSize: 34.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32.w, 16.w, 32.w, 80.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('装备分类', style: _labelStyle()),
            SizedBox(height: 16.w),
            Wrap(
              spacing: 16.w,
              runSpacing: 16.w,
              children: _categoryMap.entries.map((entry) {
                final selected = _category == entry.key;
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
                  onSelected: (_) => setState(() => _category = entry.key),
                );
              }).toList(),
            ),
            SizedBox(height: 32.w),
            Text('品牌 *', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_brandController, '如：达瓦、禧玛诺、Megabass'),
            SizedBox(height: 32.w),
            Text('型号 *', style: _labelStyle()),
            SizedBox(height: 16.w),
            _buildField(_modelController, '如：Steez 632ML'),
            SizedBox(height: 32.w),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('价格（元）', style: _labelStyle()),
                      SizedBox(height: 16.w),
                      _buildField(_priceController, '选填', isNumber: true),
                    ],
                  ),
                ),
                SizedBox(width: 32.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('购入时间', style: _labelStyle()),
                      SizedBox(height: 16.w),
                      GestureDetector(
                        onTap: _pickBuyAt,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 96.w,
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          alignment: Alignment.centerLeft,
                          decoration: _fieldDecoration(),
                          child: Text(
                            _buyAtController.text.isEmpty
                                ? '选填'
                                : _buyAtController.text,
                            style: TextStyle(
                              fontSize: 28.sp,
                              color: _buyAtController.text.isEmpty
                                  ? Constants.TEXT_LIGHT_COLOR
                                  : Constants.TEXT_DEFAULT_COLOR,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 64.w),
            RoundButton(
              text: '入库',
              loading: _isSubmiting,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  // 选择购入时间
  Future<void> _pickBuyAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    setState(() {
      _buyAtController.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });
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

  // 字段装饰
  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Constants.BG_COLOR,
      borderRadius: BorderRadius.circular(16.w),
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
