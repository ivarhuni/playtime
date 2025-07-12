import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart' hide PlayPadding;
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';

class PickerEntries {
  final String title;
  final List<PickerEntry> entries;

  PickerEntries({this.title = "", required this.entries});
}

class PickerEntry {
  final String text;
  final IconData? icon;
  final String? svg;
  final void Function() onTap;

  PickerEntry({required this.text, this.icon, this.svg, required this.onTap});
}

class PlayPicker {
  static void showPicker(BuildContext context, {required PickerEntries entries}) {
    if (PlatformDetector.isIOS) {
      _showCupertinoPicker(context, entries);
    } else {
      _showMaterialPicker(context, entries);
    }
  }

  static void _showCupertinoPicker(BuildContext context, PickerEntries entries) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: PlayText(entries.title, style: PlayTheme.font.body17),
        actions: entries.entries
            .map(
              (PickerEntry e) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  e.onTap();
                },
                child: PlayText(e.text, style: PlayTheme.font.body20),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: PlayText(S.of(context).global_cancel, style: PlayTheme.font.body17),
        ),
      ),
    );
  }

  static void _showMaterialPicker(BuildContext context, PickerEntries entries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PlayTheme.background(),
      useSafeArea: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: PlayPaddings.large, bottom: PlayPaddings.small),
          child: Wrap(
            children: entries.entries
                .map(
                  (PickerEntry e) => PlayListTile(
                    leading: e.icon == null
                        ? PlaySvg(
                            e.svg ?? AppAssets.icons.icTransparent,
                            width: PlaySizes.large,
                            height: PlaySizes.large,
                          )
                        : Icon(e.icon),
                    title: PlayText(e.text, style: PlayTheme.font.body16),
                    onTap: () {
                      Navigator.pop(context);
                      e.onTap();
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
