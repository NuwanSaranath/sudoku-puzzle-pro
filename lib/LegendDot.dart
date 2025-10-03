import 'package:flutter/material.dart';
class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: text),
      ],
    );
  }
}