import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ut_ad_leika/infrastructure/core/initialization/initialization_service.dart';
import 'package:ut_ad_leika/presentation/core/app.dart';
import 'package:ut_ad_leika/presentation/core/localization/user_locale.dart';
import 'package:ut_ad_leika/presentation/core/theme/play_theme.dart';
import 'package:ut_ad_leika/setup.dart';

Future<void> main() async {
  await appSetup();

  final InitializationService initService = getIt<InitializationService>();
  await initService.init();
  final Brightness? userBrightness = await initService.getPreferredBrightness();
  final Locale? userLocale = await initService.getPreferredLocale();

  if (userBrightness != null) {
    PlayTheme.brightness = userBrightness;
  } else {
    final Brightness brightness = PlatformDispatcher.instance.platformBrightness;
    PlayTheme.brightness = brightness;
  }

  if (userLocale != null) {
    App.userLocale = UserLocale.fromLocale(userLocale);
  }

  runApp(const App());
}
