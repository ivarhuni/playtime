import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:lottie/lottie.dart';

enum PlayEpicImageType {
  standard,
  avatar,
  animation,
}

class PlayEpicImage extends StatelessWidget {
  final String asset;
  final String? fallbackAsset;
  final String? title;
  final String? message;
  final double widthAsPercentageOfScreen;
  final double? heightAsPercentageOfScreen;
  final String semantics;
  final bool padding;
  final Widget? overrideWidget;
  final PlayEpicImageType type;
  final bool isLoading;
  final bool hideInAccessibilityMode;

  const PlayEpicImage({
    super.key,
    required this.asset,
    this.title,
    this.message,
    this.widthAsPercentageOfScreen = 0.6,
    this.heightAsPercentageOfScreen,
    this.fallbackAsset,
    this.semantics = "",
    this.padding = true,
    this.overrideWidget,
    this.type = PlayEpicImageType.standard,
    this.isLoading = false,
    this.hideInAccessibilityMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool shouldAddTopPadding = switch (type) {
      PlayEpicImageType.standard => padding,
      PlayEpicImageType.avatar => false,
      PlayEpicImageType.animation => false,
    };
    final Widget image = overrideWidget ?? (isLoading ? PlayLoadingBox(child: _getImage(context)) : _getImage(context));

    Widget core = PlayPadding(
      padding: EdgeInsets.only(top: shouldAddTopPadding ? PlayPaddings.huge : 0),
      child: image,
    );
    if (semantics.isNotEmpty) {
      core = Semantics(
        label: semantics,
        child: ExcludeSemantics(
          child: core,
        ),
      );
    }

    if (type == PlayEpicImageType.avatar) {
      const double backgroundPadding = PlayPaddings.Playrge;
      final double size = _getSize(context);
      final double backgroundSize = size + backgroundPadding;
      core = Stack(
        alignment: Alignment.center,
        children: [
          PlaySvg(
            PlayTheme.illustrations.roundPictureBackground,
            width: backgroundSize,
            height: backgroundSize,
            color: PlayTheme.secondary(),
          ),
          Align(
            child: PlayContainer(
              margin: const EdgeInsets.only(left: backgroundPadding),
              height: size,
              width: size,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: core,
              ),
            ),
          ),
        ],
      );
    }

    if (Accessibility.of(context).isInAccessibilityMode && hideInAccessibilityMode) {
      core = const PlaySizedBox.shrink();
    }

    if (title != null && message != null) {
      return PlayColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          core,
          const PlaySizedBox(height: PlayPaddings.extraHuge),
          PlayText(
            title!,
            style: PlayTheme.font.body28.bold,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const PlaySizedBox(height: PlayPaddings.medium),
            PlayText(
              message!,
              style: PlayTheme.font.body16.light,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    } else if (message != null) {
      return PlayColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          core,
          const PlaySizedBox(height: PlayPaddings.extraHuge),
          PlayText(
            message!,
            style: PlayTheme.font.body16.light,
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (title != null) {
      return PlayColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          core,
          const PlaySizedBox(height: PlayPaddings.extraHuge),
          PlayText(
            title!,
            style: PlayTheme.font.body28.bold,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return core;
  }

  Widget _getImage(BuildContext context) {
    if (type == PlayEpicImageType.animation) {
      return Lottie.asset(
        AppAssets.animations.progress,
        width: _getSize(context),
        frameRate: FrameRate.max,
        animate: true,
      );
    } else {
      return PlayImage(
        width: _getSize(context),
        height: _getSize(context),
        imageLink: asset,
        fit: switch (type) {
          PlayEpicImageType.standard => BoxFit.contain,
          PlayEpicImageType.avatar => BoxFit.cover,
          PlayEpicImageType.animation => BoxFit.contain,
        },
        fallback: fallbackAsset == null ? null : PlayImage(imageLink: fallbackAsset!),
      );
    }
  }

  double _getSize(BuildContext context) {
    final double dimension =
        heightAsPercentageOfScreen == null ? MediaQuery.sizeOf(context).width : MediaQuery.sizeOf(context).height;
    final double fraction =
        heightAsPercentageOfScreen == null ? widthAsPercentageOfScreen : heightAsPercentageOfScreen!;
    final double size = dimension * fraction;
    return size;
  }
}
