import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

class PlayIconCircle extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? circleColor;
  final bool loading;
  final double? size;
  final double? iconSize;
  final String? semanticsLabel;
  final Function()? onTap;

  const PlayIconCircle({
    super.key,
    required this.icon,
    this.iconColor,
    this.circleColor,
    this.loading = false,
    this.size,
    this.iconSize,
    this.semanticsLabel,
    this.onTap,
  });

  const PlayIconCircle.loading({super.key})
      : iconColor = null,
        circleColor = null,
        semanticsLabel = null,
        size = null,
        iconSize = null,
        onTap = null,
        icon = Icons.downloading,
        loading = true;

  @override
  Widget build(BuildContext context) {
    final Color defaultCircleColor = PlayTheme.surface();

    final double scale = min(2, max(1, Accessibility.of(context).uiScale));

    final Widget widget = Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: ClipOval(
          child: PlayTapVisual(
            enabled: onTap != null,
            onTap: onTap ?? () {},
            child: ColoredBox(
              color: circleColor ?? defaultCircleColor,
              child: SizedBox(
                width: size ?? PlaySizes.huge * scale,
                height: size ?? PlaySizes.huge * scale,
                child: Icon(
                  icon,
                  color: iconColor ?? PlayTheme.onSurface(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (loading) {
      return PlayLoadingBox(
        customBorderRadius: const BorderRadius.all(Radius.circular(PlayCornerRadius.Playrge)),
        child: widget,
      );
    } else {
      return widget;
    }
  }
}
