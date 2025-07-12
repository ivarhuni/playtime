import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/app.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';

class BottomDrawerEntry {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final bool enabled;
  final Key? key;

  const BottomDrawerEntry({
    required this.text,
    required this.onTap,
    this.icon,
    this.enabled = true,
    this.key,
  });
}

class BottomDrawerConfig {
  final String heading;
  final List<BottomDrawerEntry> entries;
  final bool dismissOnAction;

  const BottomDrawerConfig({
    required this.heading,
    required this.entries,
    this.dismissOnAction = true,
  });
}

class PlayBottomDrawer extends StatelessWidget {
  final BottomDrawerConfig config;

  const PlayBottomDrawer({
    super.key,
    required this.config,
  });

  static Future<void> show({required BuildContext context, required BottomDrawerConfig config}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PlayTheme.background(),
      shape: PlayCornerRadius().drawer,
      builder: (BuildContext context) => PlayBottomDrawer(config: config),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PlayColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (config.heading.isNotEmpty)
            PlayPadding.only(
              left: PlayPaddings.medium,
              right: PlayPaddings.medium,
              top: PlayPaddings.Playrge,
              bottom: PlayPaddings.small,
              child: PlayText(
                config.heading,
                style: PlayTheme.font.body20.bold.onSurface,
              ),
            ),
          PlaySeparatedColumn(
            separatorBuilder: (BuildContext context, int index) => PlayPadding.symmetric(
              horizontal: PlayPaddings.medium,
              child: const PlayDivider(),
            ),
            children: config.entries.map((BottomDrawerEntry entry) => _getEntry(context, entry)).toList(),
          ),
          const PlaySizedBox(height: PlayPaddings.bottomPadding),
        ],
      ),
    );
  }

  Widget _getEntry(BuildContext context, BottomDrawerEntry entry) {
    return PlayTapVisual(
      key: entry.key,
      onTap: () {
        if (entry.enabled) {
          entry.onTap.call();
          if (config.dismissOnAction) {
            App.navigatorKey.currentState?.pop();
          }
        }
      },
      child: PlayContainer(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(
          top: PlayPaddings.medium,
          bottom: PlayPaddings.medium,
        ),
        child: PlayRow(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlaySizedBox(width: PlayPaddings.medium),
            if (entry.icon != null) ...[
              PlayIcon(
                entry.icon!,
                size: PlaySizes.Playrge,
                color: entry.enabled ? PlayTheme.onSurface() : PlayTheme.onSurface().withValues(alpha: 155),
              ),
              const PlaySizedBox(width: PlayPaddings.medium),
            ],
            PlayExpanded(
              child: PlayText(
                entry.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PlayTheme.font.body16.bold.copyWith(
                  color: entry.enabled ? PlayTheme.onSurface() : PlayTheme.onSurface().withValues(alpha: 155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
