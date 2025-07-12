import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

class PlayConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    bool isCupertino = false,
  }) async {
    if (PlatformDetector.isIOS) {
      return await _showCupertinoDialog(
            context: context,
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            icon: icon,
          ) ??
          false;
    } else {
      return await _showMaterialDialog(
            context: context,
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            icon: icon,
          ) ??
          false;
    }
  }

  static Future<bool?> _showMaterialDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: PlayCornerRadius().dialog,
          title: PlayRow(
            children: [
              if (icon != null) PlayIcon(icon, color: PlayTheme.onSurface()),
              if (icon != null) const PlaySizedBox(width: PlayPaddings.mediumSmall),
              PlayText(title, style: PlayTheme.font.body24.bold.onSurface),
            ],
          ),
          content: PlayText(
            message,
            style: PlayTheme.font.body16.light.onSurface,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                FocusScope.of(context).unfocus();
              },
              child: PlayText(
                confirmText ?? S.of(context).global_confirm,
                style: PlayTheme.font.body16.primary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                FocusScope.of(context).unfocus();
              },
              child: PlayText(
                cancelText ?? S.of(context).global_cancel,
                style: PlayTheme.font.body16.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> _showCupertinoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
  }) async {
    return await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) {
        return PlayContainer(
          padding: const EdgeInsets.all(PlayPaddings.medium),
          decoration: BoxDecoration(
            color: PlayTheme.surface(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(PlayCornerRadius.Playrge)),
          ),
          child: PlayColumn(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) PlayIcon(icon, size: PlaySizes.huge, color: PlayTheme.primary()),
              if (icon != null) const PlaySizedBox(height: PlaySizes.small),
              PlayText(
                title,
                style: PlayTheme.font.body20.bold.onSurface,
              ),
              const PlaySizedBox(height: PlayPaddings.medium),
              PlayText(
                message,
                style: PlayTheme.font.body16.onSurface,
                textAlign: TextAlign.center,
              ),
              const PlaySizedBox(height: PlayPaddings.Playrge),
              PlayRow(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const PlaySizedBox(width: PlayPaddings.Playrge),
                  PlayExpanded(
                    child: PlayButton(
                      onTap: () {
                        Navigator.of(context).pop(false);
                        FocusScope.of(context).unfocus();
                      },
                      text: confirmText ?? S.of(context).global_confirm,
                    ),
                  ),
                  const PlaySizedBox(width: PlayPaddings.medium),
                  PlayExpanded(
                    child: PlayButton(
                      onTap: () {
                        Navigator.of(context).pop(true);
                        FocusScope.of(context).unfocus();
                      },
                      text: cancelText ?? S.of(context).global_cancel,
                    ),
                  ),
                  const PlaySizedBox(width: PlayPaddings.Playrge),
                ],
              ),
              const PlaySizedBox(height: PlayPaddings.medium),
            ],
          ),
        );
      },
    );
  }
}
