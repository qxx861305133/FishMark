import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';

import 'package:FishMark/config/constants.dart';
import 'package:FishMark/mock/design_data.dart';

/// @desc 1104 设计稿通用 UI 组件

/// 页面水平边距 24
double get pagePadding => 24.w;

/// 查看全部小胶囊按钮
class ViewAllPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const ViewAllPill({super.key, this.text = '查看全部', this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Constants.INPUT_BG,
          borderRadius: BorderRadius.circular(13.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: Constants.GRAY),
          ),
        ),
      ),
    );
  }
}

/// 区块标题行：左侧标题 + 右侧查看全部
class SectionRow extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const SectionRow({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Constants.INK,
            ),
          ),
          ViewAllPill(onTap: onViewAll),
        ],
      ),
    );
  }
}

/// 六边形勋章占位图
class HexMedal extends StatelessWidget {
  final MedalStyle style;
  final double size;

  const HexMedal({super.key, required this.style, this.size = 56});

  static const Map<MedalStyle, List<Color>> _gradients = {
    MedalStyle.bronze: [Color(0xFFE29A5B), Color(0xFF9C5B2B)],
    MedalStyle.silver: [Color(0xFFE8EAEE), Color(0xFFB4BAC4)],
    MedalStyle.gold: [Color(0xFFF7D774), Color(0xFFC9962A)],
    MedalStyle.blue: [Color(0xFF7FB5F5), Color(0xFF2E6BC0)],
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _HexPainter(_gradients[style]!),
        child: Center(
          child: Icon(
            RemixIcons.anchor_fill,
            size: size * 0.42,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  final List<Color> colors;

  _HexPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(0, size.height * 0.75)
      ..lineTo(0, size.height * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexPainter oldDelegate) => oldDelegate.colors != colors;
}


/// 主按钮：荧光柠檬绿胶囊
class LimeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final Color? background;
  final Color? textColor;

  const LimeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 44,
    this.fontSize = 16,
    this.background,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? Constants.LIME,
      borderRadius: BorderRadius.circular(height / 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(height / 2),
        child: Container(
          height: height.w,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize.sp,
              fontWeight: FontWeight.w600,
              color: textColor ?? Constants.INK,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// 次按钮：白底描边胶囊
class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;

  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 44,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: const Color(0xFFD9D9D9), width: 1.w)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Container(
          height: height.w,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize.sp,
              fontWeight: FontWeight.w500,
              color: Constants.INK,
            ),
          ),
        ),
      ),
    );
  }
}

/// 黑色胶囊按钮（协议页「我已知晓」）
class InkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;

  const InkButton({super.key, required this.text, this.onPressed, this.height = 48});

  @override
  Widget build(BuildContext context) {
    return LimeButton(
      text: text,
      onPressed: onPressed,
      height: height,
      background: Constants.INK,
      textColor: Colors.white,
    );
  }
}

/// APP Logo：荧光绿圆角方块 + 黑色小熊钓鱼插画占位
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: Constants.LIME,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Icon(
        RemixIcons.bear_smile_fill,
        size: size * 0.5,
        color: Constants.INK,
      ),
    );
  }
}

/// 顶部柠檬渐变背景（#EEFFC5 → 白）
class TopGradientBox extends StatelessWidget {
  final Widget child;

  const TopGradientBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.45],
          colors: [Constants.GRAD_TOP, Colors.white],
        ),
      ),
      child: child,
    );
  }
}

/// 圆形返回按钮（荧光绿底、黑色箭头）
class CircleBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color background;

  const CircleBackButton({super.key, this.onTap, this.background = Constants.LIME});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(RemixIcons.arrow_left_s_line, size: 24.w, color: Constants.INK),
      ),
    );
  }
}

/// 底部协议文案：登录即代表您已阅读并同意《用户协议》和《隐私政策》
class AgreementFooter extends StatelessWidget {
  final VoidCallback? onUserAgreement;
  final VoidCallback? onPrivacyAgreement;

  const AgreementFooter({super.key, this.onUserAgreement, this.onPrivacyAgreement});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 12.sp, color: Constants.GRAY),
        children: [
          const TextSpan(text: '登录即代表您已阅读并同意'),
          _linkSpan(context, '《用户协议》', onUserAgreement),
          const TextSpan(text: '和'),
          _linkSpan(context, '《隐私政策》', onPrivacyAgreement),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  TextSpan _linkSpan(BuildContext context, String text, VoidCallback? onTap) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: Constants.INK,
        fontWeight: FontWeight.w600,
      ),
      recognizer: onTap == null
          ? null
          : (TapGestureRecognizer()..onTap = onTap),
    );
  }
}

/// 浅灰输入框（#F5F7FB，圆角 12）
class FillInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const FillInput({
    super.key,
    this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Constants.INPUT_BG,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 20.w, color: Constants.INK),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              obscureText: obscureText,
              onChanged: onChanged,
              style: TextStyle(fontSize: 15.sp, color: Constants.INK),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  color: Constants.GRAY_LIGHT,
                ),
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}
