import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final bool? automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.bottom,
    this.automaticallyImplyLeading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: textColor ?? theme.appBarTheme.titleTextStyle?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ??
          theme.appBarTheme.backgroundColor ??
          AppColors.primaryColor,
      elevation: elevation,
      actions: actions,
      leading: leading,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      iconTheme: IconThemeData(
        color: textColor ?? theme.appBarTheme.titleTextStyle?.color,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
