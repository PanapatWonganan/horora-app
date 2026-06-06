import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Progress indicator แบบจุด
class ProgressIndicatorDots extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const ProgressIndicatorDots({
    Key? key,
    required this.currentIndex,
    required this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (index) {
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          width: isCurrent ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(colors: AppColors.primaryGradient)
                : null,
            color: isActive ? null : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// Progress indicator แบบ bar
class ProgressIndicatorBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorBar({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ขั้นตอนที่ ${currentStep + 1}',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
            Text(
              '${currentStep + 1}/$totalSteps',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
