import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final double size;
  final Color backgroundColor;
  final Color? borderColor;

  /// Thai, action-phrased label for screen readers (e.g. "เข้าสู่ระบบด้วย
  /// Google") — required since this button is icon-only with no visible
  /// text.
  final String semanticLabel;

  const SocialLoginButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 50,
    this.backgroundColor = Colors.transparent,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(
              color: borderColor ?? AppColors.warmCardBorder,
              width: 1,
            ),
          ),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}
