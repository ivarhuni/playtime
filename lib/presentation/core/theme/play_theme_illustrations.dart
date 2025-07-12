import 'package:ut_ad_leika/presentation/core/assets/assets.gen.dart';

class PlayThemeIllustrations implements $AssetsIllustrationsDarkGen, $AssetsIllustrationsLightGen {
  final bool isDarkMode;

  const PlayThemeIllustrations({required this.isDarkMode});

  $AssetsIllustrationsDarkGen get dark => const $AssetsIllustrationsDarkGen();

  $AssetsIllustrationsLightGen get light => const $AssetsIllustrationsLightGen();

  @override
  List<String> get values => [];

  @override
  String get womanReading => isDarkMode ? dark.womanReading : light.womanReading;

  @override
  String get manLove => isDarkMode ? dark.manLove : light.manLove;

  @override
  String get roundPictureBackground => isDarkMode ? dark.roundPictureBackground : light.roundPictureBackground;

  @override
  String get manGreetings => isDarkMode ? dark.manGreetings : light.manGreetings;

  @override
  String get womanRunningBanner => isDarkMode ? dark.womanRunningBanner : light.womanRunningBanner;

  @override
  String get womanFloatingBanner => isDarkMode ? dark.womanFloatingBanner : light.womanFloatingBanner;

  @override
  String get manLoveBanner => isDarkMode ? dark.manLoveBanner : light.manLoveBanner;
}
