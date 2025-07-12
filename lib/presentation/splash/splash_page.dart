import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/templates/import.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlaySvg(
              AppAssets.icons.loveAssistantLogo,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            PlayText(
              S.current.app_name,
              style: PlayTheme.font.body32.primary,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 80,
              height: 80,
              child: Lottie.asset(
                AppAssets.animations.progress,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 