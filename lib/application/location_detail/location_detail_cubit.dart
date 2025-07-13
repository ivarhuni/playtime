import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/application/core/base_cubit.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/core/value_objects/coordinates_value_object.dart';
import 'package:ut_ad_leika/domain/core/value_objects/distance_value_object.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_repository.dart';

part 'location_detail_state.dart';

@injectable
class LocationDetailCubit extends BaseCubit<LocationDetailState> {
  final ILocationService _locationService;
  final ILocationRepository _locationRepository;

  LocationDetailCubit(this._locationService, this._locationRepository)
    : super(const LocationDetailState.initial());

  Future<void> loadLocation(String locationId) async {
    emit(const LocationDetailState.loading());

    try {
      // Load location from repository
      final location = await _locationRepository.getLocationById(locationId);

      if (location == null) {
        emit(const LocationDetailState.error('Location not found'));
        return;
      }

      emit(LocationDetailState.loaded(location));

      // Initialize location services after loading the location
      await _initializeLocationServices();
    } catch (error) {
      emit(const LocationDetailState.error('Failed to load location details'));
    }
  }

  Future<void> _initializeLocationServices() async {
    if (state.location == null) return;

    try {
      emit(state.copyWith(isLoadingUserLocation: true));

      // Check and request location permission
      final permissionStatus = await _locationService
          .requestLocationPermission();

      if (permissionStatus == LocationPermissionStatus.granted) {
        // Get user location
        final userLocation = await _locationService.getCurrentLocation();

        if (userLocation != null) {
          // Calculate distance
          final locationCoords = CoordinatesValueObject.fromLatLng(
            state.location!.latitude,
            state.location!.longitude,
          );

          final distance = await _locationService.calculateDistance(
            userLocation,
            locationCoords,
          );

          emit(
            state.copyWith(
              userLocation: userLocation,
              permissionStatus: permissionStatus,
              distance: distance,
              isLoadingUserLocation: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              permissionStatus: permissionStatus,
              isLoadingUserLocation: false,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            permissionStatus: permissionStatus,
            isLoadingUserLocation: false,
          ),
        );
      }
    } catch (error) {
      print(
        '❌ LocationDetailCubit: Error initializing location services: $error',
      );
      emit(
        state.copyWith(
          permissionStatus: LocationPermissionStatus.denied,
          isLoadingUserLocation: false,
        ),
      );
    }
  }

  Future<void> retryLocationPermission() async {
    await _initializeLocationServices();
  }

  Future<void> openInMaps() async {
    if (state.location == null) return;

    final CoordinatesValueObject locationCoords =
        CoordinatesValueObject.fromLatLng(
          state.location!.latitude,
          state.location!.longitude,
        );

    await _locationService.openInMaps(
      locationCoords,
      label: state.location!.address,
    );
  }
}
