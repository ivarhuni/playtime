import 'package:flutter/material.dart';

class PlayCenter extends StatelessWidget {
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;

  const PlayCenter({
    super.key,
    required this.child,
    this.widthFactor,
    this.heightFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: child,
    );
  }
}
