import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) _buildAvatar(),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  // USER = saturated soft plum + light text; BOT = ivory + ink.
                  color: isUser
                      ? AppColors.chatBubble
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: AppColors.warmCardBorder.withValues(alpha: 0.7),
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.templeIndigo.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: GoogleFonts.kanit(
                    color: isUser ? AppColors.onBackdrop : AppColors.deepText,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp),
                style: GoogleFonts.kanit(
                  color: AppColors.onBackdropMuted.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (isUser) _buildAvatar(),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser
          ? AppColors.softPlum.withValues(alpha: 0.22)
          : AppColors.candleGold.withValues(alpha: 0.18),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        color: isUser ? AppColors.onBackdrop : AppColors.deepGoldBrown,
        size: 16,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
} 