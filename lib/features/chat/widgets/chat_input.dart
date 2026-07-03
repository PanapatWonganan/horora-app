import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isTyping;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    required this.isTyping,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty || widget.isTyping) return;
    
    widget.onSendMessage(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // Translucent night-plum bar so the ivory input pill lifts off the
        // indigo backdrop, with a faint gold hairline at the top edge.
        color: AppColors.nightPlum.withValues(alpha: 0.55),
        border: Border(
          top: BorderSide(
            color: AppColors.candleGold.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.ricePaper,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.warmCardBorder.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                enabled: !widget.isTyping,
                cursorColor: AppColors.deepGoldBrown,
                decoration: InputDecoration(
                  hintText: widget.isTyping
                      ? 'นักพยากรณ์กำลังพิมพ์...'
                      : 'พิมพ์ข้อความ...',
                  hintStyle: GoogleFonts.kanit(
                    color: AppColors.softInk.withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.kanit(color: AppColors.deepText),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                onSubmitted: (value) {
                  if (_hasText && !widget.isTyping) {
                    _handleSend();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: _hasText && !widget.isTyping ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Semantics(
              button: true,
              label: 'ส่งข้อความ',
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: _hasText && !widget.isTyping ? _handleSend : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.candleGold,
                          AppColors.deepGoldBrown,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.deepGoldBrown.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SvgIcon(
                        AppIcons.send,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }
} 