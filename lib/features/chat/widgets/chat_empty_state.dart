import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/app_icons.dart';

/// Empty-state shown before the first message in a chat session — a warm
/// welcome plus a few tappable suggested questions so the user isn't staring
/// at a blank screen wondering what to ask.
///
/// Extracted out of `ChatScreen` (as a public widget in its own file,
/// behavior-preserving) so it can be pumped and asserted on directly in
/// widget tests without needing to stand up the full `ChatViewModel` /
/// backend session boundary that the real screen requires.
class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onQuestionTap;

  const ChatEmptyState({super.key, required this.onQuestionTap});

  static const List<String> suggestedQuestions = [
    'ดวงความรักช่วงนี้เป็นอย่างไร',
    'งานที่ทำอยู่จะราบรื่นไหม',
    'เดือนนี้มีอะไรที่ควรระวัง',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.candleGold.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.candleGold.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: const Center(
                child: SvgIcon(
                  AppIcons.sparkle,
                  size: 32,
                  color: AppColors.candleGold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ทักทายนักพยากรณ์ได้เลยนะ',
              style: GoogleFonts.kanit(
                color: AppColors.onBackdrop,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ถามอะไรก็ได้เกี่ยวกับดวงของคุณ นักพยากรณ์พร้อมฟังอยู่ค่ะ',
              style: GoogleFonts.kanit(
                color: AppColors.onBackdropMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: suggestedQuestions
                  .map((q) => _SuggestedQuestionChip(
                        question: q,
                        onTap: () => onQuestionTap(q),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ivory pill with a gold hairline border — a tappable suggested question
/// that sends via the same `sendMessage` path as manual typing.
class _SuggestedQuestionChip extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _SuggestedQuestionChip({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.ivorySilk,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: AppColors.candleGold.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Text(
            question,
            style: GoogleFonts.kanit(
              color: AppColors.deepGoldBrown,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
