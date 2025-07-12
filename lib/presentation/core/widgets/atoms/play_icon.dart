import 'package:flutter/material.dart';

class PlayIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const PlayIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
