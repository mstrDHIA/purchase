import 'package:flutter/material.dart';

/// A small reusable AppBar to keep page headers consistent across the app.
class StandardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // either a literal title or null when using titleKey
  final String? titleKey; // optional localization key (e.g. 'statistics')
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final Color accentColor;
  final double fontSize;
  final bool showBackButton;

  const StandardHeader({
    super.key,
    this.title,
    this.titleKey,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor = Colors.white, // light neutral by default
    this.accentColor = const Color(0xFF6F4DBF), // mauve as accent for text/icons
    this.fontSize = 20.0,
    this.showBackButton = true,
  }) : assert(title != null || titleKey != null, 'Either title or titleKey must be provided');

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    // Resolve display title: prefer literal `title`, else map `titleKey` to AppLocalizations when possible.
    String displayTitle = title ?? '';
    if ((displayTitle.isEmpty) && titleKey != null) {
      // We don't rely on specific generated getters here; fallback to a humanized key.
      displayTitle = titleKey!.replaceAll('_', ' ').splitMapJoin(RegExp(r'(^.|\s.)'), onMatch: (m) => m[0]!.toUpperCase(), onNonMatch: (n) => n);
    }

    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      foregroundColor: accentColor,
      iconTheme: IconThemeData(color: accentColor),
      actionsIconTheme: IconThemeData(color: accentColor),
      title: Text(
        displayTitle,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: accentColor),
      ),
      shape: Border(bottom: BorderSide(color: accentColor.withOpacity(0.08), width: 1)),
      actions: actions,
    );
  }
}
