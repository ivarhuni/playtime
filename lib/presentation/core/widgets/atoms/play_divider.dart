import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';

class PlayDivider extends StatelessWidget {
  const PlayDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: PlayTheme.onSurface().withValues(alpha: 50),
    );
  }
}
