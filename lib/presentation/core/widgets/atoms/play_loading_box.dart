import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:ut_ad_leika/domain/core/extensions/common_extensions.dart';
import 'package:ut_ad_leika/presentation/core/theme/play_theme.dart';

part 'play_loading_box_details.dart';

class PlayLoadingBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final double borderRadius;
  final BorderRadius? customBorderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final bool isLoading;

  const PlayLoadingBox({
    super.key,
    this.width,
    this.height,
    this.child,
    this.baseColor,
    this.highlightColor,
    this.customBorderRadius,
    this.borderRadius = 8,
    this.isLoading = true,
  }) : assert(!(height == null && child == null), "Supply either height or child. Both are null.");

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return _getBody(context);
    }
    return _Shimmer.fromColors(
      highlightColor: highlightColor ?? PlayTheme.onSecondaryContainer(),
      baseColor: baseColor ?? PlayTheme.secondaryContainer(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
          color: PlayTheme.onSecondaryContainer(),
        ),
        child: _getBody(context),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: child,
    );
  }
}
