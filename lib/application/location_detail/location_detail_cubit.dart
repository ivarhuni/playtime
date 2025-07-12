import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/application/core/base_cubit.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';
import 'package:ut_ad_leika/domain/core/value_objects/coordinates_value_object.dart';
import 'package:ut_ad_leika/domain/core/value_objects/distance_value_object.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart';

part 'location_detail_state.dart';

@injectable
class LocationDetailCubit extends BaseCubit<LocationDetailState> {
  final ILocationService _locationService;

  LocationDetailCubit(this._locationService) : super(const LocationDetailState.initial());

  Future<void> loadLocation(String locationId) async {
    print('🔍 LocationDetailCubit: Loading location with ID: $locationId');
    emit(const LocationDetailState.loading());
    
    try {
      // TODO: In a real app, this would fetch from a repository
      // For now, simulate loading with mock data
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mock location data (in real app, fetch by ID from repository)
      const Location location = Location(
        id: '1',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop&crop=center',
        address: 'Hlemmur, 101 Reykjavík',
        description: 'A Playrge playground in central Reykjavík with modern equipment and excellent facilities. Perfect for families with children of all ages.',
        capabilities: {LocationCapability.slide, LocationCapability.swing, LocationCapability.sandbox},
        size: LocationSize.Playrge,
        starRating: 4.8,
        latitude: 64.1466,
        longitude: -21.9426,
      );
      
      print('📍 LocationDetailCubit: Location loaded - ${location.address} (${location.latitude}, ${location.longitude})');
      emit(const LocationDetailState.loaded(location));
      
      // Request location permission and get user location
      print('🗺️ LocationDetailCubit: Initializing location services...');
      await _initializeLocationServices();
      
    } catch (error) {
      print('❌ LocationDetailCubit: Error loading location: $error');
      emit(const LocationDetailState.error('Failed to load location details'));
    }
  }

  Future<void> _initializeLocationServices() async {
    print('🔧 LocationDetailCubit: _initializeLocationServices called');
    if (state.status != LocationDetailStatus.loaded || state.location == null) {
      print('⚠️ LocationDetailCubit: Cannot initialize location services - state: ${state.status}, location: ${state.location}');
      return;
    }

    try {
      // Request location permission
      print('🔐 LocationDetailCubit: Requesting location permission...');
      final LocationPermissionStatus permissionStatus = await _locationService.requestLocationPermission();
      print('🔐 LocationDetailCubit: Permission status: $permissionStatus');
      
      emit(state.copyWith(
        permissionStatus: permissionStatus,
        isLoadingUserLocation: true,
      ));

      if (permissionStatus == LocationPermissionStatus.granted) {
        // Get user location
        print('📍 LocationDetailCubit: Getting user location...');
        final CoordinatesValueObject? userLocation = await _locationService.getCurrentLocation();
        print('📍 LocationDetailCubit: User location: $userLocation');
        
        if (userLocation != null && userLocation.valid) {
          // Calculate distance
          print('📏 LocationDetailCubit: Calculating distance...');
          final CoordinatesValueObject locationCoords = CoordinatesValueObject.fromLatLng(
            state.location!.latitude,
            state.location!.longitude,
          );
          
          final DistanceValueObject distance = _locationService.calculateDistance(
            userLocation,
            locationCoords,
          );
          print('📏 LocationDetailCubit: Distance calculated: $distance');

          emit(state.copyWith(
            userLocation: userLocation,
            distanceToLocation: distance,
            isLoadingUserLocation: false,
          ));
        } else {
          print('⚠️ LocationDetailCubit: User location is null or invalid');
          emit(state.copyWith(isLoadingUserLocation: false));
        }
      } else {
        print('⚠️ LocationDetailCubit: Location permission denied');
        emit(state.copyWith(isLoadingUserLocation: false));
      }
    } catch (error) {
      print('❌ LocationDetailCubit: Error in _initializeLocationServices: $error');
      emit(state.copyWith(isLoadingUserLocation: false));
    }
  }

  Future<void> openInMaps() async {
    if (state.location == null) return;

    final CoordinatesValueObject locationCoords = CoordinatesValueObject.fromLatLng(
      state.location!.latitude,
      state.location!.longitude,
    );

    await _locationService.openInMaps(
      locationCoords,
      label: state.location!.address,
    );
  }

  Future<void> retryLocationPermission() async {
    await _initializeLocationServices();
  }
} 
