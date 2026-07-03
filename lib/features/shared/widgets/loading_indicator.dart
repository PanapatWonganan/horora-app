import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/sacred_ui.dart';

/// A loading indicator with an optional message.
///
/// Thin wrapper around [SacredLoader] so every existing call site (tarot
/// history/details, horoscope detail/home card) picks up the app's single
/// on-brand candle-gold loading language for free. [color] is honored for
/// callers that pass a specific tint; otherwise it defaults to the shared
/// candle-gold.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SacredLoader(
      label: message,
      color: color ?? AppColors.candleGold,
    );
  }
}
