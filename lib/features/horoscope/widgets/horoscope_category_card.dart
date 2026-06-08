import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';

class HoroscopeCategoryCard extends StatefulWidget {
  final String title;
  final IconData? icon;
  final String? svgIconPath;
  final Color color;
  final String description;
  final int rating;
  final VoidCallback onTap;

  const HoroscopeCategoryCard({
    Key? key,
    required this.title,
    this.icon,
    this.svgIconPath,
    required this.color,
    required this.description,
    required this.rating,
    required this.onTap,
  }) : super(key: key);

  @override
  State<HoroscopeCategoryCard> createState() => _HoroscopeCategoryCardState();
}

class _HoroscopeCategoryCardState extends State<HoroscopeCategoryCard>
    with SingleTickerProviderStateMixin {
  // Drives the "reading revealing itself" star fill-in animation.
  late final AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Let the card's own entrance settle first, then fill the stars in.
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) _starController.forward();
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SacredCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.svgIconPath != null
                      ? SvgIcon(
                          widget.svgIconPath!,
                          size: 22,
                          color: widget.color,
                        )
                      : Icon(
                          widget.icon,
                          color: widget.color,
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: SacredText.kanit(
                    color: AppColors.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
            style: SacredText.kanit(
              color: AppColors.mutedText,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(5, (index) {
                final filled = index < widget.rating;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: AnimatedBuilder(
                    animation: _starController,
                    builder: (context, child) {
                      // Each star pops in sequence as the reading "reveals".
                      final start = (index / 5) * 0.55;
                      final t = Interval(
                        start,
                        (start + 0.45).clamp(0.0, 1.0),
                        curve: Curves.easeOutBack,
                      ).transform(_starController.value);
                      // Outline stars settle in too, just without the gold pop.
                      final scale = filled ? (0.4 + 0.6 * t) : 1.0;
                      final opacity = filled ? t.clamp(0.0, 1.0) : 1.0;
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: SvgIcon(
                      filled ? AppIcons.starFilled : AppIcons.starOutline,
                      size: 14,
                      color: filled
                          ? AppColors.candleGold
                          : AppColors.warmCardBorder,
                    ),
                  ),
                );
              }),
              const Spacer(),
              SvgIcon(
                AppIcons.arrowForward,
                size: 12,
                color: AppColors.mutedText.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
