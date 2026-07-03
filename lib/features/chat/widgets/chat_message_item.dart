import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/simple_markdown.dart';
import '../../../core/widgets/typewriter_rich_text.dart';
import '../../report/report_dialog.dart';

class ChatMessageItem extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isTyping;
  final bool isSystemMessage;
  final String? messageId;
  // Whether the AI reply text should play the typewriter reveal. The caller
  // (ChatScreen) decides this once per message id — history renders with
  // this false so it never re-animates on rebuild/scroll.
  final bool animateReveal;
  // Fired on every revealed-character tick while animating, so the caller
  // can keep the growing bubble scrolled into view.
  final VoidCallback? onRevealTick;

  const ChatMessageItem({
    Key? key,
    required this.message,
    required this.isUser,
    required this.isTyping,
    this.isSystemMessage = false,
    this.messageId,
    this.animateReveal = false,
    this.onRevealTick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ถ้าเป็นข้อความระบบ ให้แสดงแบบพิเศษ
    if (isSystemMessage) {
      return _buildSystemMessage(context);
    }

    final bubbleTextColor = isUser ? AppColors.onBackdrop : AppColors.deepText;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // USER bubble = saturated soft plum with light text; BOT/assistant
          // bubble = warm ivory with dark ink (keeps the Sacred card language).
          color: isUser ? AppColors.chatBubble : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? AppColors.softPlum.withValues(alpha: 0.5)
                : AppColors.warmCardBorder.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.templeIndigo.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor:
                              AppColors.candleGold.withValues(alpha: 0.18),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.deepGoldBrown,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'นักพยากรณ์',
                          style: GoogleFonts.kanit(
                            color: AppColors.deepGoldBrown,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (!isTyping)
                      GestureDetector(
                        onTap: () => _showReportDialog(context),
                        child: Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: AppColors.mutedText.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              isTyping
                  ? _buildTypingIndicator()
                  // AI replies may carry light Markdown (**bold**, headings);
                  // user messages are shown verbatim.
                  : isUser
                      ? Text(
                          message,
                          style: GoogleFonts.kanit(
                            color: bubbleTextColor,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        )
                      : TypewriterRichText(
                          // Keyed by message id so a message that already
                          // finished revealing keeps its own State (and thus
                          // its "done" flag) across ChatScreen rebuilds, and
                          // a genuinely different message never inherits a
                          // finished/partial reveal state from another key.
                          key: ValueKey(
                              'typewriter_${messageId ?? message.hashCode}'),
                          span: SimpleMarkdown.parse(
                            message,
                            base: GoogleFonts.kanit(
                              color: bubbleTextColor,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                          animate: animateReveal,
                          onTick: onRevealTick,
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget สำหรับแสดงข้อความระบบ
  Widget _buildSystemMessage(BuildContext context) {
    // ตรวจสอบว่าข้อความเกี่ยวกับราศีหรือไม่
    final bool isZodiacMessage = message.contains('ราศี');

    // หาว่าเป็นราศีอะไร
    String? zodiacSign;
    if (isZodiacMessage) {
      for (final sign in [
        'เมษ',
        'พฤษภ',
        'เมถุน',
        'กรกฎ',
        'สิงห์',
        'กันย์',
        'ตุลย์',
        'พิจิก',
        'ธนู',
        'มังกร',
        'กุมภ์',
        'มีน'
      ]) {
        if (message.contains('ราศี$sign')) {
          zodiacSign = sign;
          break;
        }
      }
    }

    // หาไอคอนที่เหมาะสมกับราศี
    IconData zodiacIcon = Icons.auto_awesome;

    // หาธาตุของราศี
    String? element;
    Color elementColor = AppColors.primary;

    if (zodiacSign != null) {
      // กำหนดธาตุตามราศี — temple-toned element colors
      if (['เมษ', 'สิงห์', 'ธนู'].contains(zodiacSign)) {
        element = 'ไฟ';
        elementColor = AppColors.fireElement;
        zodiacIcon = Icons.local_fire_department;
      } else if (['พฤษภ', 'กันย์', 'มังกร'].contains(zodiacSign)) {
        element = 'ดิน';
        elementColor = AppColors.earthElement;
        zodiacIcon = Icons.landscape;
      } else if (['เมถุน', 'ตุลย์', 'กุมภ์'].contains(zodiacSign)) {
        element = 'ลม';
        elementColor = AppColors.airElement;
        zodiacIcon = Icons.air;
      } else if (['กรกฎ', 'พิจิก', 'มีน'].contains(zodiacSign)) {
        element = 'น้ำ';
        elementColor = AppColors.waterElement;
        zodiacIcon = Icons.water_drop;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isZodiacMessage
            ? (element != null
                ? elementColor.withValues(alpha: 0.12)
                : AppColors.candleGold.withValues(alpha: 0.12))
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isZodiacMessage
              ? (element != null
                  ? elementColor.withValues(alpha: 0.4)
                  : AppColors.candleGold.withValues(alpha: 0.5))
              : AppColors.warmCardBorder.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.templeIndigo.withValues(alpha: 0.12),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isZodiacMessage ? zodiacIcon : Icons.info_outline,
                size: 18,
                color: isZodiacMessage
                    ? (element != null ? elementColor : AppColors.deepGoldBrown)
                    : AppColors.deepGoldBrown,
              ),
              const SizedBox(width: 8),
              Text(
                isZodiacMessage ? 'ข้อมูลดวงดาวของคุณ' : 'ข้อความจากระบบ',
                style: GoogleFonts.kanit(
                  color: isZodiacMessage
                      ? (element != null
                          ? elementColor
                          : AppColors.deepGoldBrown)
                      : AppColors.deepText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (element != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: elementColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ธาตุ$element',
                    style: GoogleFonts.kanit(
                      color: elementColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const _TypingDots();
  }

  void _showReportDialog(BuildContext context) async {
    await showReportDialog(
      context,
      contentId: messageId ?? 'chat_${DateTime.now().millisecondsSinceEpoch}',
      contentType: 'chat_message',
      contentSnapshot:
          message.length > 200 ? message.substring(0, 200) : message,
    );
  }
}

/// Three dots that pulse in a staggered sequence while the astrologer "types".
/// Each dot fades + scales up on its own offset within a shared ~1s loop.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0.0),
        _buildDot(0.2),
        _buildDot(0.4),
      ],
    );
  }

  Widget _buildDot(double delay) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Staggered pulse: each dot runs the same 0->1->0 curve but offset
          // by `delay` within the shared 1s loop.
          final t = (_controller.value + delay) % 1.0;
          final pulse = (math.sin(t * 2 * math.pi) + 1) / 2; // 0..1
          final opacity = 0.35 + (pulse * 0.65);
          final scale = 0.7 + (pulse * 0.3);
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
