import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ut_ad_leika/domain/core/value_objects/coordinates_value_object.dart';
import 'package:ut_ad_leika/domain/core/value_objects/distance_value_object.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart';

@LazySingleton(as: ILocationService)
class LocationService implements ILocationService {
  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.denied;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return _convertPermission(permission);
    } catch (e) {
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.denied;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      return _convertPermission(permission);
    } catch (e) {
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<CoordinatesValueObject?> getCurrentLocation() async {
    try {
      LocationPermissionStatus permissionStatus = await getLocationPermissionStatus();
      if (permissionStatus != LocationPermissionStatus.granted) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return CoordinatesValueObject.fromLatLng(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  DistanceValueObject calculateDistance(
    CoordinatesValueObject from,
    CoordinatesValueObject to,
  ) {
    if (from.isInvalid || to.isInvalid) {
      return const DistanceValueObject.invalid();
    }

    try {
      double distanceInMeters = Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );

      return DistanceValueObject.fromMeters(distanceInMeters);
    } catch (e) {
      return const DistanceValueObject.invalid();
    }
  }

  @override
  Future<bool> openInMaps(CoordinatesValueObject coordinates, {String? label}) async {
    if (coordinates.isInvalid) return false;

    try {
      // Android: Use geo URI scheme
      final String query = label != null ? '($label)' : '';
      final String androidUrl = 'geo:${coordinates.latitude},${coordinates.longitude}?q=${coordinates.latitude},${coordinates.longitude}$query';
      
      // TODO: Add iOS support
      // TODO: 1. Add platform detection (import 'dart:io' and use Platform.isIOS)
      // TODO: 2. Use iOS Apple Maps URL: 'maps://maps.apple.com/?ll=${coordinates.latitude},${coordinates.longitude}&q=${Uri.encodeComponent(label ?? '')}'
      // TODO: 3. Add iOS configuration in ios/Runner/AppDelegate.swift with Google Maps API key
      // TODO: 4. Add location permissions to ios/Runner/Info.plist:
      // TODO:    <key>NSLocationWhenInUseUsageDescription</key>
      // TODO:    <string>This app needs location access to show distance to playgrounds.</string>
      // TODO: 5. Enable Maps SDK for iOS in Google Cloud Console
      // TODO: 6. Test on iOS device/simulator

      final Uri uri = Uri.parse(androidUrl);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web Google Maps
        final String webUrl = 'https://www.google.com/maps/search/?api=1&query=${coordinates.latitude},${coordinates.longitude}';
        final Uri webUri = Uri.parse(webUrl);
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      return false;
    }
  }

  LocationPermissionStatus _convertPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unasked;
    }
  }
} 
