import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class PlatformDetector {
  // Keep the old static API for backward compatibility
  static bool get isIOS {
    return Platform.isIOS;
  }

  static bool get isAndroid {
    return Platform.isAndroid;
  }

  static bool get isWeb {
    return kIsWeb;
  }

  static bool get isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static Brightness platformBrightness(BuildContext context) {
    return View.of(context).platformDispatcher.platformBrightness;
  }

  /// Get Google Maps API key from Android manifest metadata (for debugging)
  Future<String?> getGoogleMapsApiKey() async {
    if (!isAndroid) return null;

    try {
      const platform = MethodChannel('flutter/platform');
      final result = await platform.invokeMethod(
        'getMetaData',
        'com.google.android.maps.v2.API_KEY',
      );
      return result?.toString();
    } catch (e) {
      print('Error getting Google Maps API key: $e');
      return null;
    }
  }
}
