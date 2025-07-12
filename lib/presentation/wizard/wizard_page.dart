import 'package:flutter/material.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/templates/import.dart';

class WizardPage extends StatelessWidget {
  const WizardPage({super.key});

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
            const SizedBox(height: 16),
            PlayText(
              'Welcome to the wizard!',
              style: PlayTheme.font.body16.primary,
            ),
            const SizedBox(height: 32),
            PlayButton(
              text: 'Get Started',
              onTap: () {
                // Navigate to main app
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
      ),
    );
  }
} 