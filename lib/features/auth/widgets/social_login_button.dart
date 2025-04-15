import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final double size;
  final Color backgroundColor;
  final Color borderColor;

  const SocialLoginButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 50,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Center(
          child: icon,
        ),
      ),
    );
  }
}
