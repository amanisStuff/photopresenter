import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final MouseCursor cursor;

  const Clickable({
    super.key,
    required this.child,
    this.onTap,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? cursor : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}