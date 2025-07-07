import 'package:flutter/material.dart';

class LuciAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool showBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;

  const LuciAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.showBack = false,
    this.actions,
    this.backgroundColor,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      centerTitle: centerTitle,
      titleSpacing: 16.0,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            )
          : null,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: actions,
      shadowColor: theme.shadowColor,
      surfaceTintColor: backgroundColor ?? theme.colorScheme.surface,
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).appBarTheme.systemOverlayStyle?.copyWith(statusBarBrightness: Brightness.dark)
          : Theme.of(context).appBarTheme.systemOverlayStyle?.copyWith(statusBarBrightness: Brightness.light),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class LuciSectionHeader extends StatelessWidget {
  final String title;
  const LuciSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 28.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }
} 