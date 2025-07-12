import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

class PlayListTile extends StatelessWidget {
  final Widget? leading;
  final PlayText title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PlayListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformDetector.isAndroid) {
      return ListTile(
        leading: leading,
        trailing: trailing,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PlayPadding.symmetric(
        vertical: PlayPaddings.mediumSmall,
        horizontal: PlayPaddings.medium,
        child: PlayRow(
          children: [
            if (leading != null) ...[
              leading!,
              const PlaySizedBox(width: PlayPaddings.medium),
            ],
            // Title and Subtitle (expanded to fill space)
            PlayExpanded(
              child: PlayColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) subtitle!,
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
