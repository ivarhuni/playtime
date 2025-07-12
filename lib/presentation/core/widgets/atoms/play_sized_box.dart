import 'package:flutter/material.dart';

class PlaySizedBox extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;

  const PlaySizedBox({
    super.key,
    this.child,
    this.width,
    this.height,
  });

  const PlaySizedBox.shrink({
    super.key,
  }) : child = null, width = null, height = null;

  const PlaySizedBox.expand({
    super.key,
    this.child,
  }) : width = double.infinity, height = double.infinity;

  const PlaySizedBox.fromSize({
    super.key,
    this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
