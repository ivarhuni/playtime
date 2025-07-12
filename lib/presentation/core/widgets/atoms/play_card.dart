import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

enum CardType {
  main,
  secondary,
}

extension _CardTypeExtension on CardType {
  Color get backgroundColor {
    return switch (this) {
      CardType.main => PlayTheme.surface(),
      CardType.secondary => PlayTheme.secondaryContainer(),
    };
  }

  double get elevation {
    return switch (this) {
      CardType.main => PlayElevation.medium,
      CardType.secondary => PlayElevation.minimal,
    };
  }
}

class PlayCard extends StatelessWidget {
  final Widget child;
  final CardType type;

  const PlayCard({
    super.key,
    required this.child,
    this.type = CardType.main,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(PlayCornerRadius.large);
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(color: Colors.transparent),
      ),
      elevation: type.elevation,
      shadowColor: PlayTheme.shadow(),
      color: PlayTheme.surface(),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
