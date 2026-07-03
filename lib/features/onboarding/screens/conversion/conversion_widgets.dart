import 'package:flutter/material.dart';

import 'conversion_style.dart';

/// A single selectable list row (radio-style) used on "how did you hear",
/// and "frequency" screens. Selected = gold border + filled gold dot.
class CvSelectRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const CvSelectRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? CvColors.goldA(0.16) : CvColors.whiteA(0.05),
            border: Border.all(
              color: selected ? CvColors.gold : CvColors.whiteA(0.08),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: CvType.body(14,
                            weight: FontWeight.w600,
                            color: selected
                                ? CvColors.cream
                                : CvColors.creamA(0.88))),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: CvType.body(12, color: CvColors.creamA(0.5))),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _Radio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;
  const _Radio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? CvColors.gold : CvColors.creamA(0.3),
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CvColors.goldMid,
              ),
            )
          : null,
    );
  }
}

/// A small square brand chip (used for social sources on the attribution screen).
class CvBrandChip extends StatelessWidget {
  final String glyph;
  final Color background;
  final Color foreground;
  final TextStyle? textStyle;
  const CvBrandChip({
    super.key,
    required this.glyph,
    required this.background,
    this.foreground = Colors.white,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(glyph,
          style: textStyle ??
              TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
    );
  }
}

/// Selectable goal tile (2-col grid) — multi-select with gold border + glyph.
class CvGoalTile extends StatelessWidget {
  final String glyph;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CvGoalTile({
    super.key,
    required this.glyph,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            color: selected ? CvColors.goldA(0.16) : CvColors.whiteA(0.05),
            border: Border.all(
              color: selected ? CvColors.gold : CvColors.whiteA(0.08),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [CvColors.goldLight, CvColors.goldMid],
                        )
                      : null,
                  color: selected ? null : CvColors.whiteA(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(glyph,
                    style: TextStyle(
                      fontSize: 20,
                      color: selected ? CvColors.goldInk : CvColors.gold,
                    )),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: CvType.body(15,
                      weight: FontWeight.w600,
                      color: selected
                          ? CvColors.cream
                          : CvColors.creamA(0.85))),
            ],
          ),
        ),
      ),
    );
  }
}

/// A verified-fact row with a sage check chip (used on the Trust screen and the
/// analyzing checklist).
class CvCheckRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool done; // sage filled vs. pending ring
  final bool pulsing;
  const CvCheckRow({
    super.key,
    required this.title,
    this.subtitle,
    this.done = true,
    this.pulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: subtitle != null ? 34 : 22,
          height: subtitle != null ? 34 : 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? CvColors.sage.withValues(alpha: 0.18) : null,
            border: done
                ? null
                : Border.all(color: CvColors.goldA(0.5), width: 2),
            borderRadius: BorderRadius.circular(subtitle != null ? 11 : 50),
          ),
          child: done
              ? Text('✓',
                  style: TextStyle(
                      color: CvColors.sage,
                      fontSize: subtitle != null ? 16 : 13))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: CvType.body(subtitle != null ? 15 : 13,
                      weight: subtitle != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: done
                          ? CvColors.creamA(subtitle != null ? 1 : 0.85)
                          : CvColors.creamA(0.55))),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!,
                    style: CvType.body(12, color: CvColors.creamA(0.55))),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
