import 'package:flutter/material.dart';

/// A small reusable AppBar to keep page headers consistent across the app.
class StandardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final Color accentColor;
  final double fontSize;
  final bool showBackButton;

  const StandardHeader({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor = Colors.white, // light neutral by default
    this.accentColor = const Color(0xFF6F4DBF), // mauve as accent for text/icons
    this.fontSize = 20.0,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      foregroundColor: accentColor,
      iconTheme: IconThemeData(color: accentColor),
      actionsIconTheme: IconThemeData(color: accentColor),
      title: Text(
        title,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: accentColor),
      ),
      shape: Border(bottom: BorderSide(color: accentColor.withOpacity(0.08), width: 1)),
      actions: actions,
    );
  }
}
