// ignore_for_file: unused_import

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ut_ad_leika/application/core/language/language_cubit.dart';
import 'package:ut_ad_leika/infrastructure/core/initialization/initialization_service.dart';
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart';
import 'package:ut_ad_leika/presentation/core/localization/l10n.dart';
import 'package:ut_ad_leika/presentation/core/localization/user_locale.dart';
import 'package:ut_ad_leika/presentation/core/theme/play_theme.dart';
import 'package:ut_ad_leika/presentation/location_detail/location_detail_page.dart';
import 'package:ut_ad_leika/presentation/location_list/location_list_page.dart';
import 'package:ut_ad_leika/presentation/splash/splash_page.dart';
import 'package:ut_ad_leika/presentation/wizard/wizard_page.dart';
import 'package:ut_ad_leika/setup.dart';

enum PageName {
  splash("/splash"),
  locations("/locations"),
  locationDetail("/location-detail"),
  wizard("/wizard"),
  main("/main");

  final String route;

  const PageName(this.route);
}

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static UserLocale? userLocale;

  const App({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    setState(() async {
      final PlatformDispatcher dispatcher = View.of(context).platformDispatcher;

      final InitializationService service = getIt<InitializationService>();
      final bool hasSet = (await service.getPreferredBrightness()) != null;
      if (!hasSet) {
        PlayTheme.brightness = dispatcher.platformBrightness;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget core = PlatformDetector.isIOS
        ? CupertinoApp(
            onGenerateTitle: (BuildContext context) => S.of(context).app_name,
            navigatorKey: App.navigatorKey,
            routes: {
              PageName.locations.route: (BuildContext context) => const LocationListPage(),
              PageName.splash.route: (BuildContext context) => const SplashPage(),
              PageName.wizard.route: (BuildContext context) => const WizardPage(),
            },
            initialRoute: PageName.locations.route,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: App.userLocale?.locale,
            theme: PlayTheme.cupertinoTheme(PlayTheme.brightness ?? Brightness.light),
            debugShowCheckedModeBanner: false,
          )
        : MaterialApp(
            onGenerateTitle: (BuildContext context) => S.of(context).app_name,
            navigatorKey: App.navigatorKey,
            routes: {
              PageName.locations.route: (BuildContext context) => const LocationListPage(),
              PageName.splash.route: (BuildContext context) => const SplashPage(),
              PageName.wizard.route: (BuildContext context) => const WizardPage(),
            },
            initialRoute: PageName.locations.route,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: App.userLocale?.locale,
            debugShowCheckedModeBanner: false,
            theme: PlayTheme.materialTheme(Brightness.light),
            darkTheme: PlayTheme.materialTheme(Brightness.dark),
          );

    return BlocProvider<LanguageCubit>(
      create: (BuildContext context) {
        return getIt<LanguageCubit>();
      },
      child: BlocConsumer<LanguageCubit, LanguageState>(
        listener: (BuildContext context, LanguageState state) {
          setState(() {
            App.userLocale = UserLocale.fromLanguage(state.language);
          });
        },
        builder: (BuildContext context, LanguageState state) {
          return core;
        },
      ),
    );
  }
}
