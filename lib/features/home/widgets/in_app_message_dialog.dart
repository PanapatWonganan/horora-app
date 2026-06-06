import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';

class InAppMessage {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final String? buttonUrl;
  final VoidCallback? onButtonPressed;
  final bool showCloseButton;

  const InAppMessage({
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.buttonUrl,
    this.onButtonPressed,
    this.showCloseButton = true,
  });
}

class InAppMessageDialog extends StatelessWidget {
  final InAppMessage message;
  final VoidCallback? onDismiss;

  const InAppMessageDialog({
    Key? key,
    required this.message,
    this.onDismiss,
  }) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.lightSurface,
              AppColors.cream,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background decorations
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  if (message.showCloseButton)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          onPressed: () {
                            onDismiss?.call();
                            Navigator.of(context).pop();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.mutedText,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Image
                  if (message.imageUrl != null) ...[
                    Container(
                      margin: EdgeInsets.only(
                        top: message.showCloseButton ? 0 : 24,
                        left: 24,
                        right: 24,
                      ),
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: message.imageUrl!.startsWith('http')
                            ? Image.network(
                                message.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              )
                            : Image.asset(
                                message.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Title
                  Padding(
                    padding: EdgeInsets.only(
                      top: message.imageUrl == null
                          ? (message.showCloseButton ? 0 : 32)
                          : 0,
                      left: 24,
                      right: 24,
                    ),
                    child: Text(
                      message.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        color: AppColors.deepText,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),

                  // Subtitle
                  if (message.subtitle != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        message.subtitle!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          color: AppColors.deepText.withValues(alpha: 0.72),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Button
                  if (message.buttonText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildGradientButton(context),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.5),
            AppColors.secondary.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 48,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildGradientButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (message.onButtonPressed != null) {
          message.onButtonPressed!();
        } else if (message.buttonUrl != null) {
          _launchUrl(message.buttonUrl!);
        }
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          message.buttonText!,
          textAlign: TextAlign.center,
          style: GoogleFonts.kanit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// แสดง In-App Message Dialog
  static Future<void> show(
    BuildContext context, {
    required InAppMessage message,
    VoidCallback? onDismiss,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: const Color(0xFF2F2A40).withValues(alpha: 0.45),
      builder: (context) => InAppMessageDialog(
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }
}
