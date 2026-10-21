import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:luji_app/config/constants.dart';
import 'package:luji_app/config/log_util.dart';
import 'package:luji_app/http/api.dart';
import 'package:luji_app/models/subscription.dart';
import 'package:luji_app/widgets/round_button.dart';

/// @desc 订阅页：Free / Pro / Master 套餐对比 + 购买
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final List<SubscriptionPlan> _plans = [];
  bool _loading = true;
  bool _isSubmiting = false;
  // 当前选中套餐
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final result = await Api().get('subscription_plans');
      if (!mounted) return;
      if (result['success'] && result['data'] is List) {
        int selected = 0;
        for (final item in result['data']) {
          final plan =
              SubscriptionPlan.fromJson(Map<String, dynamic>.from(item));
          if (plan.recommended == true) selected = _plans.length;
          _plans.add(plan);
        }
        setState(() {
          _loading = false;
          _selected = selected;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      LogUtil.e('套餐加载失败: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // 购买订阅
  Future<void> _handleBuy() async {
    if (_plans.isEmpty) return;
    final plan = _plans[_selected];
    if (plan.current == true) {
      Fluttertoast.showToast(msg: '当前已是该套餐');
      return;
    }
    setState(() => _isSubmiting = true);
    try {
      final result = await Api().post('subscription_buy', data: {
        'rid': plan.rid,
      });
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      if (result['success']) {
        Fluttertoast.showToast(msg: '订阅成功，尽享权益');
        _loadPlans();
      } else {
        Fluttertoast.showToast(msg: result['status']['message']);
      }
    } catch (e) {
      LogUtil.e('订阅购买失败: $e');
      if (!mounted) return;
      setState(() => _isSubmiting = false);
      Fluttertoast.showToast(msg: '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.BG_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('订阅', style: TextStyle(fontSize: 34.sp)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(32.w),
                    children: [
                      // 头部
                      Text(
                        '解锁更完整的路亚体验',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Text(
                        'AI识鱼次数、战报模板、图鉴权益随档位升级',
                        style: TextStyle(
                          fontSize: 26.sp,
                          color: Constants.TEXT_SECONDARY_COLOR,
                        ),
                      ),
                      SizedBox(height: 32.w),
                      // 套餐卡
                      ..._plans.asMap().entries.map(
                            (entry) => _buildPlanCard(
                              entry.key,
                              entry.value,
                            ),
                          ),
                    ],
                  ),
                ),
                // 底部购买按钮
                if (_plans.isNotEmpty) _buildBottomBar(),
              ],
            ),
    );
  }

  // 套餐卡
  Widget _buildPlanCard(int index, SubscriptionPlan plan) {
    final selected = index == _selected;
    final color = _tierColor(plan.tier);
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Container(
        margin: EdgeInsets.only(bottom: 24.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 3.w,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 16.w,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  plan.name ?? '',
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(width: 16.w),
                if (plan.recommended == true)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 6.w),
                    decoration: BoxDecoration(
                      color: Constants.HIGHLIGHT_COLOR,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Text(
                      '推荐',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (plan.current == true) ...[
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 6.w),
                    decoration: BoxDecoration(
                      color: Constants.PRIMARY_COLOR.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Text(
                      '当前套餐',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Constants.PRIMARY_COLOR,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  plan.tier == 'free' ? '免费' : '¥${plan.price ?? 0}',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (plan.tier != 'free' && plan.duration_months != null)
                  Text(
                    ' /${plan.duration_months}月',
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: Constants.TEXT_LIGHT_COLOR,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24.w),
            // 权益列表
            ...(plan.privileges ?? []).map(
              (privilege) => Padding(
                padding: EdgeInsets.only(bottom: 12.w),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 28.w, color: color),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        privilege,
                        style: TextStyle(
                          fontSize: 26.sp,
                          color: Constants.TEXT_DEFAULT_COLOR,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 底部购买
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(32.w, 16.w, 32.w, 16.w),
        child: RoundButton(
          text: '立即开通',
          loading: _isSubmiting,
          onPressed: _handleBuy,
        ),
      ),
    );
  }

  // 档位颜色
  Color _tierColor(String? tier) {
    switch (tier) {
      case 'pro':
        return Constants.PRIMARY_COLOR;
      case 'master':
        return Constants.HIGHLIGHT_COLOR;
      default:
        return Constants.TEXT_SECONDARY_COLOR;
    }
  }
}
