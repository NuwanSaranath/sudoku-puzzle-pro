import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundOverride;

  static const _disabledBtn = Color(0xFFBDBDBD);

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundOverride ?? theme.colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 26),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? _disabledBtn : bg,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          disabledBackgroundColor: _disabledBtn,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
