import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';

class PlayBanner extends StatelessWidget {
  final String asset;

  const PlayBanner({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height * 0.15;
    final double width = MediaQuery.sizeOf(context).width;
    return PlayImage(
      imageLink: asset,
      fit: BoxFit.scaleDown,
      width: width,
      height: height,
    );
  }
}
