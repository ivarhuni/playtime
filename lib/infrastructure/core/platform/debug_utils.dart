import 'dart:io';
import 'package:flutter/services.dart';

class DebugUtils {
  /// Print Google Maps API key from Android manifest (for debugging)
  static Future<void> printGoogleMapsApiKey() async {
    if (!Platform.isAndroid) {
      print('Google Maps API Key: Not available on this platform');
      return;
    }
    
    try {
      // Try to get the API key from AndroidManifest metadata
      const platform = MethodChannel('flutter/platform_views');
      final result = await platform.invokeMethod('getApplicationMetaData');
      
      if (result != null && result is Map) {
        final apiKey = result['com.google.android.maps.v2.API_KEY'];
        print('Google Maps API Key: $apiKey');
      } else {
        print('Google Maps API Key: Could not retrieve from manifest');
      }
    } catch (e) {
      print('Error getting Google Maps API key: $e');
    }
  }
} 
