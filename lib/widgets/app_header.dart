import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppHeader({super.key, required this.title, this.actions, this.showBackButton = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.of(context).pop()) : null,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      actions: actions,
      centerTitle: true,
    );
  }
}