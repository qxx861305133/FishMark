import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/global.dart';
import 'package:FishMark/mock/mine_data.dart';
import 'package:FishMark/widgets/ui_kit.dart';

/// @desc 6.1 订阅系统 - 会员中心
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  static const Color _gold = Color(0xFFE8B34B);
  static const Color _goldLight = Color(0xFFF0C060);
  static const Color _navy = Color(0xFF0F1829);
  static const Color _cardNavy = Color(0xFF131E30);

  final PageController _planController =
      PageController(viewportFraction: 0.85, initialPage: 1);
  int _planIndex = 1;
  int _billingIndex = 0;

  @override
  void dispose() {
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _navy,
        body: Stack(
          children: [
            // 顶部暖金色光晕
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: const Alignment(0.2, 0.55),
                    colors: [const Color(0xFF3D2F14), _navy],
                  ),
                ),
              ),
            ),
            // 右下角大 V 水印
            Positioned(
              right: -30.w,
              bottom: 130.w,
              child: _watermarkV(),
            ),
            // 内容
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildNavBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 24.w),
                      child: Column(
                        children: [
                          _buildPlanCarousel(),
                          SizedBox(height: 28.w),
                          _buildBillingCards(),
                          SizedBox(height: 44.w),
                          _buildSectionHeader(),
                          SizedBox(height: 26.w),
                          _buildBenefits(),
                        ],
                      ),
                    ),
                  ),
                  // 底部开通按钮
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 20.w),
                      child: _buildSubscribeButton(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== 顶部导航：左返回 / 中标题 / 右恢复购买（Row 布局，互不遮盖）=====
  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 56.w,
      child: Row(
        children: [
          SizedBox(width: 12.w),
          CircleBackButton(onTap: () => Navigator.of(context).maybePop()),
          Expanded(
            child: Center(
              child: Text(
                Global.t('会员中心', 'Membership'),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Fluttertoast.showToast(
                msg: Global.t('已发起恢复购买（演示）', 'Restore initiated (demo)')),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                Global.t('恢复购买', 'Restore'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  // ===== 套餐轮播 =====
  Widget _buildPlanCarousel() {
    return SizedBox(
      height: 116.w,
      child: PageView.builder(
        controller: _planController,
        itemCount: MineData.vipPlans.length,
        onPageChanged: (index) => setState(() => _planIndex = index),
        itemBuilder: (_, index) => _buildPlanCard(index),
      ),
    );
  }

  // 套餐卡
  Widget _buildPlanCard(int index) {
    final plan = MineData.vipPlans[index];
    final bool active = index == _planIndex;

    BoxDecoration decoration;
    Color titleColor;
    Color descColor;
    switch (index) {
      case 1: // Pro 专业版：金色
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFEE5A6), Color(0xFFFFC96B)],
          ),
          borderRadius: BorderRadius.circular(20.r),
        );
        titleColor = const Color(0xFF241A06);
        descColor = const Color(0xFF6B5A33);
        break;
      case 2: // Master 大师版：深蓝金边
        decoration = BoxDecoration(
          color: const Color(0xFF17233A),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF8A6B2C), width: 1.2.w),
        );
        titleColor = Colors.white;
        descColor = const Color(0xFF8A94A8);
        break;
      default: // 体验版：灰蓝
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9AA6B8), Color(0xFF6E7A8C)],
          ),
          borderRadius: BorderRadius.circular(20.r),
        );
        titleColor = const Color(0xFF141A26);
        descColor = const Color(0xFF3C4658);
        break;
    }

    return AnimatedScale(
      scale: active ? 1.0 : 0.92,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => _planController.animateToPage(
          index,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.w),
          padding: EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 18.w),
          decoration: decoration,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    plan.desc,
                    style: TextStyle(fontSize: 12.5.sp, color: descColor),
                  ),
                ],
              ),
              // 金色 V 徽章
              Positioned(
                right: index == 1 ? 24.w : 6.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _vBadge(size: index == 1 ? 62.w : 34.w),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 金色 V 徽章
  Widget _vBadge({required double size}) {
    return Transform.rotate(
      angle: -0.18,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6D488), Color(0xFFC9962A)],
          ),
          borderRadius: BorderRadius.circular(size * 0.24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10.w,
              offset: Offset(0, 4.w),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'V',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF7A5A14),
          ),
        ),
      ),
    );
  }

  // ===== 计费周期 =====
  Widget _buildBillingCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(MineData.vipBillings.length, (index) {
          final billing = MineData.vipBillings[index];
          final selected = index == _billingIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _billingIndex = index),
              child: Container(
                height: 92.w,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 14.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B2740), _cardNavy],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: selected ? _gold : Colors.white10,
                    width: selected ? 1.4.w : 1.w,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      billing.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.w),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFE3A0), Color(0xFFE8A94B)],
                      ).createShader(bounds),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: billing.price,
                              style: TextStyle(
                                fontSize: 23.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: billing.unit,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
        }),
      ),
    );
  }

  // ===== 权益标题（两侧金线箭头）=====
  Widget _buildSectionHeader() {
    Widget sideLine(bool left) => Expanded(
          child: Container(
            height: 1.2.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: left
                    ? [Colors.transparent, _gold.withValues(alpha: 0.7)]
                    : [_gold.withValues(alpha: 0.7), Colors.transparent],
              ),
            ),
          ),
        );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Row(
        children: [
          sideLine(true),
          SizedBox(width: 10.w),
          Icon(RemixIcons.arrow_right_fill, size: 12.w, color: _goldLight),
          SizedBox(width: 10.w),
          Text(
            'Master 大师版权益',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: _goldLight,
            ),
          ),
          SizedBox(width: 10.w),
          Icon(RemixIcons.arrow_left_fill, size: 12.w, color: _goldLight),
          SizedBox(width: 10.w),
          sideLine(false),
        ],
      ),
    );
  }

  // ===== 权益宫格 =====
  Widget _buildBenefits() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.82,
        children: MineData.vipBenefits.map((benefit) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1C2740), Color(0xFF0E1626)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF263450)),
                ),
                child: Icon(RemixIcons.map_pin_2_fill,
                    size: 24.w, color: _gold),
              ),
              SizedBox(height: 9.w),
              Text(
                benefit.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFE8ECF4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ===== 底部开通按钮 =====
  Widget _buildSubscribeButton() {
    final billing = MineData.vipBillings[_billingIndex];
    return GestureDetector(
      onTap: () => Fluttertoast.showToast(msg: '订阅成功，尽享权益（演示）'),
      child: Container(
        height: 54.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE3A0), Color(0xFFF5C563)],
          ),
          borderRadius: BorderRadius.circular(27.r),
        ),
        alignment: Alignment.center,
        child: Text(
          '¥${billing.price} 立即开通',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF241A06),
          ),
        ),
      ),
    );
  }

  // 大 V 水印
  Widget _watermarkV() {
    return Transform.rotate(
      angle: -0.42,
      child: Container(
        width: 150.w,
        height: 150.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2438), Color(0xFF0D1526)],
          ),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: const Color(0xFF223048), width: 2.w),
        ),
        alignment: Alignment.center,
        child: Text(
          'V',
          style: TextStyle(
            fontSize: 64.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF182338),
          ),
        ),
      ),
    );
  }
}
