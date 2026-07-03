import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';

/// [OutlinedGradientButton] is the last survivor of the pre-"Sacred UI" gold
/// gradient button family. Every filled/solid gradient CTA has converged onto
/// `SacredPrimaryButton` (see `core/theme/sacred_ui.dart`) — the plain
/// `GradientButton` class was deleted once its last call site migrated.
/// `OutlinedGradientButton` remains because it still backs the destructive
/// "logout" action in profile + settings, which intentionally uses an
/// outlined red gradient rather than the gold Sacred primary style.
class OutlinedGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;
  final double width;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final bool isLoading;

  const OutlinedGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    this.width = double.infinity,
    this.height = 56.0,
    this.borderRadius = 16.0,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(borderRadius - 2),
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius - 2),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts.kanit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
