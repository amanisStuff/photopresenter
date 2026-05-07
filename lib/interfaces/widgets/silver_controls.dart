import 'package:flutter/material.dart';
import '../../shared/theme.dart';

class SilverIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final String tooltip;
  final VoidCallback onPressed;

  const SilverIconButton({
    super.key,
    required this.icon,
    this.color,
    this.size = 16,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.silverButton(),
      padding: const EdgeInsets.all(1),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: color ?? AppTheme.textOnSilver, size: size),
        onPressed: onPressed,
        style: IconButton.styleFrom(backgroundColor: Colors.transparent),
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class MenuButton<T> extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final void Function(T)? onSelected;
  final List<(IconData, String)> items;

  const MenuButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      icon: Icon(icon, color: AppTheme.textOnSilver, size: 16),
      itemBuilder: (context) {
        return items.map((entry) {
          return PopupMenuItem<T>(
            value: (entry.$2 as dynamic) as T,
            child: Row(
              children: [
                Icon(entry.$1, size: 18),
                const SizedBox(width: 8),
                Text(entry.$2),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class SilverPopupButton<T> extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final String tooltip;
  final void Function(T)? onSelected;
  final PopupMenuItemBuilder<T>? itemBuilder;
  final List<(IconData, String)>? items;

  const SilverPopupButton({
    super.key,
    required this.icon,
    this.isActive = false,
    this.activeColor = AppTheme.textOnSilver,
    required this.tooltip,
    this.onSelected,
    this.itemBuilder,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.silverButton(),
      padding: const EdgeInsets.all(1),
      child: PopupMenuButton<T>(
        tooltip: tooltip,
        onSelected: onSelected,
        icon: Icon(icon, color: isActive ? activeColor : AppTheme.textOnSilver, size: 16),
        itemBuilder: itemBuilder ?? (context) {
          if (items == null) return [];
          return items!.map((entry) {
            return PopupMenuItem<T>(
              value: (entry.$2 as dynamic) as T,
              child: Row(
                children: [
                  Icon(entry.$1, size: 18),
                  const SizedBox(width: 8),
                  Text(entry.$2),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
