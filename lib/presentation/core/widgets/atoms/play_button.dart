import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart' hide PlayPadding;
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

enum PlayButtonSize {
  normal,
  mini,
}

enum PlayButtonStyle {
  primary,
  secondary,
}

class PlayButton extends StatelessWidget {
  static const double buttonHeight = 53;
  static const double miniButtonHeight = 34;

  final VoidCallback onTap;
  final String? text;
  final IconData? icon;
  final bool enabled;
  final bool busy;
  final VoidCallback? onDisabledTap;
  final PlayButtonStyle buttonStyle;
  final PlayButtonSize size;
  final int? maxLines;
  final String? semanticLabel;

  const PlayButton({
    Key? key,
    required VoidCallback onTap,
    String? text,
    IconData? icon,
    bool enabled = true,
    bool busy = false,
    VoidCallback? onDisabledTap,
    PlayButtonStyle buttonStyle = PlayButtonStyle.primary,
    int? maxLines,
    String? semanticLabel,
  }) : this._(
          key: key,
          onTap: onTap,
          text: text,
          icon: icon,
          enabled: enabled,
          busy: busy,
          onDisabledTap: onDisabledTap,
          buttonStyle: buttonStyle,
          size: PlayButtonSize.normal,
          maxLines: maxLines,
          semanticLabel: semanticLabel,
        );

  const PlayButton._({
    super.key,
    required this.onTap,
    this.text,
    this.icon,
    this.enabled = true,
    this.busy = false,
    this.onDisabledTap,
    required this.buttonStyle,
    required this.size,
    this.maxLines,
    this.semanticLabel,
  });

  const PlayButton.mini({
    Key? key,
    required VoidCallback onTap,
    String? text,
    IconData? icon,
    bool enabled = true,
    bool busy = false,
    VoidCallback? onDisabledTap,
    PlayButtonStyle buttonStyle = PlayButtonStyle.primary,
    int? maxLines,
    String? semanticLabel,
  }) : this._(
          key: key,
          onTap: onTap,
          text: text,
          icon: icon,
          enabled: enabled,
          busy: busy,
          onDisabledTap: onDisabledTap,
          buttonStyle: buttonStyle,
          size: PlayButtonSize.mini,
          maxLines: maxLines,
          semanticLabel: semanticLabel,
        );

  bool get isIOS => PlatformDetector.isIOS;

  @override
  Widget build(BuildContext context) {
    final _IsbButtonColorPalette colors = _IsbButtonColorPalette.fromButtonStyle(buttonStyle);

    Widget child;
    if (busy) {
      child = Center(
        child: PlayDotLoader(
          color: colors.busyColor,
          size: PlaySizes.large,
        ),
      );
    } else {
      final Color textColor = colors.getTextColor(enabled);
      final bool hasText = text?.isNotEmpty ?? false;
      final bool hasIcon = icon != null;

      if (hasIcon && !hasText) {
        child = Center(
          child: Icon(
            icon,
            size: size.iconSize,
            color: textColor,
          ),
        );
      } else {
        child = Padding(
          padding: const EdgeInsets.all(PlayPaddings.small),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: size.iconSize,
                  color: textColor,
                ),
              if (icon != null && hasText) const SizedBox(width: PlayPaddings.small),
              if (hasText)
                Flexible(
                  child: PlayText(
                    text ?? "",
                    maxLines: maxLines,
                    overflow: maxLines != null ? TextOverflow.ellipsis : null,
                    textAlign: TextAlign.center,
                    style: size.getTextStyle().copyWith(color: textColor),
                  ),
                ),
            ],
          ),
        );
      }
    }

    final VoidCallback onTap = busy ? () {} : ((enabled ? this.onTap : onDisabledTap) ?? () {});

    return PlatformDetector.isIOS
        ? SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: onTap,
              color: colors.enabledBackgroundColor,
              sizeStyle: CupertinoButtonSize.medium,
              child: child,
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                elevation: PlayElevation.minimal,
                padding: EdgeInsets.zero,
                side: BorderSide(color: colors.enabledBorderColor),
                backgroundColor: colors.enabledBackgroundColor,
                foregroundColor: colors.enabledTextColor,
                disabledBackgroundColor: colors.disabledBackgroundColor,
                disabledForegroundColor: colors.disabledTextColor,
              ),
              child: child,
            ),
          );
  }
}

class _IsbButtonColorPalette {
  final Color enabledTextColor;
  final Color enabledBackgroundColor;
  final Color enabledBorderColor;
  final Color enabledSplashColor;
  final Color disabledTextColor;
  final Color disabledBackgroundColor;
  final Color disabledBorderColor;
  final Color disabledSplashColor;
  final Color busyColor;

  const _IsbButtonColorPalette._({
    required this.enabledTextColor,
    required this.enabledBackgroundColor,
    required this.enabledBorderColor,
    required this.enabledSplashColor,
    required this.disabledTextColor,
    required this.disabledBackgroundColor,
    required this.disabledBorderColor,
    required this.disabledSplashColor,
    required this.busyColor,
  });

  factory _IsbButtonColorPalette.fromButtonStyle(PlayButtonStyle style) => switch (style) {
        PlayButtonStyle.primary => _IsbButtonColorPalette.primary(),
        PlayButtonStyle.secondary => _IsbButtonColorPalette.secondary(),
      };

  factory _IsbButtonColorPalette.primary() => _IsbButtonColorPalette._(
        enabledTextColor: PlayTheme.onSecondary(),
        enabledBackgroundColor: PlayTheme.secondary(),
        enabledBorderColor: Colors.transparent,
        enabledSplashColor: PlayTheme.onSecondary(),
        disabledTextColor: PlayTheme.hintText(),
        disabledBackgroundColor: PlayTheme.secondary().withValues(alpha: 155),
        disabledBorderColor: Colors.transparent,
        disabledSplashColor: PlayTheme.onSecondary().withValues(alpha: 155),
        busyColor: PlayTheme.onSecondary(),
      );

  factory _IsbButtonColorPalette.secondary() => _IsbButtonColorPalette._(
        enabledTextColor: PlayTheme.onTertiaryContainer(),
        enabledBackgroundColor: PlayTheme.tertiaryContainer(),
        enabledBorderColor:  Colors.transparent,
        enabledSplashColor: PlayTheme.onSecondaryContainer(),
        disabledTextColor: PlayTheme.hintText(),
        disabledBackgroundColor: PlayTheme.tertiaryContainer(),
        disabledBorderColor: Colors.transparent,
        disabledSplashColor: PlayTheme.onTertiaryContainer(),
        busyColor: PlayTheme.onTertiaryContainer(),
      );

  Color getTextColor(bool enabled) => enabled ? enabledTextColor : disabledTextColor;

  Color getBackgroundColor(bool enabled) => enabled ? enabledBackgroundColor : disabledBackgroundColor;

  Color getBorderColor(bool enabled) => enabled ? enabledBorderColor : disabledBorderColor;

  Color getSplashColor(bool enabled, bool iOS) => iOS
      ? Colors.transparent
      : enabled
          ? enabledSplashColor
          : disabledSplashColor;
}

extension _IsbButtonSizeX on PlayButtonSize {
  double get width => switch (this) {
        PlayButtonSize.normal => double.infinity,
        PlayButtonSize.mini => 0,
      };

  double get height => switch (this) {
        PlayButtonSize.normal => PlayButton.buttonHeight,
        PlayButtonSize.mini => PlayButton.miniButtonHeight,
      };

  double get borderRadius => switch (this) {
        PlayButtonSize.normal => PlayCornerRadius.large,
        PlayButtonSize.mini => PlayCornerRadius.extraSmall,
      };

  double get iconSize => switch (this) {
        PlayButtonSize.normal => PlaySizes.large,
        PlayButtonSize.mini => PlaySizes.medium,
      };

  TextStyle getTextStyle() => switch (this) {
        PlayButtonSize.normal => PlayTheme.font.body16,
        PlayButtonSize.mini => PlayTheme.font.body14,
      };
}
