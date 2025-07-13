import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/molecules/import.dart';

enum BulletPointListSize { normal, small }

extension _BulletPointListSizeExtension on BulletPointListSize {
  TextStyle get titleSize {
    switch (this) {
      case BulletPointListSize.normal:
        return PlayTheme.font.body24;
      case BulletPointListSize.small:
        return PlayTheme.font.body20;
    }
  }

  TextStyle get entrySize {
    switch (this) {
      case BulletPointListSize.normal:
        return PlayTheme.font.body16;
      case BulletPointListSize.small:
        return PlayTheme.font.body14;
    }
  }

  TextStyle get bulletSize {
    switch (this) {
      case BulletPointListSize.normal:
        return PlayTheme.font.body28;
      case BulletPointListSize.small:
        return PlayTheme.font.body24;
    }
  }

  double get titlePadding {
    switch (this) {
      case BulletPointListSize.normal:
        return PlayPaddings.medium;
      case BulletPointListSize.small:
        return PlayPaddings.small;
    }
  }
}

class _BulletPointEntry {
  final String text;
  final IconData? icon;
  final String? emoji;

  _BulletPointEntry({required this.text, this.icon, this.emoji});
}

class PlayBulletPointList extends StatelessWidget {
  final String title;
  final List<_BulletPointEntry> entries;
  final BulletPointListSize size;

  const PlayBulletPointList({
    super.key,
    required this.title,
    required this.entries,
    this.size = BulletPointListSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    return PlayCard(
      child: PlayPadding.all(
        value: PlayPaddings.medium,
        child: PlayColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlayText(title, style: size.titleSize),
            PlaySizedBox(height: size.titlePadding),
            ...entries.map(
              (_BulletPointEntry e) => PlayListTile(
                leading: _getLeading(e),
                title: PlayText(e.text, style: size.entrySize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLeading(_BulletPointEntry e) {
    if (e.icon != null) {
      return PlayIcon(e.icon!, size: PlaySizes.large);
    } else if (e.emoji != null) {
      return PlayText(e.emoji ?? "•", style: PlayTheme.font.body20);
    }
    return PlayText("•", style: size.bulletSize);
  }
}
