import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/setup.config.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

Future<void> appSetup() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureInjection();
}

final GetIt getIt = GetIt.instance;
@injectableInit
Future<void> _configureInjection() async {
  getIt.init();
}
