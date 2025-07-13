import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/application/core/base_cubit.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_repository.dart';
import 'package:ut_ad_leika/domain/core/value_objects/coordinates_value_object.dart';
import 'package:ut_ad_leika/domain/core/value_objects/distance_value_object.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart';

part 'location_list_state.dart';

@injectable
class LocationListCubit extends BaseCubit<LocationListState> {
  final ILocationRepository _locationRepository;
  final ILocationService _locationService;

  LocationListCubit(this._locationRepository, this._locationService)
    : super(const LocationListState.initial());

  Future<void> init() async {
    emit(const LocationListState.loading());

    try {
      // Load locations from GeoJSON via repository
      final locations = await _locationRepository.getLocations();
      emit(LocationListState.loaded(locations));

      // Request location permission and get user location for distance sorting
      await _initializeLocationServices();
    } catch (e) {
      emit(const LocationListState.error('Failed to load locations'));
    }
  }

  Future<void> _initializeLocationServices() async {
    if (state.status != LocationListStatus.loaded) {
      return;
    }

    try {
      // Request location permission
      final LocationPermissionStatus permissionStatus = await _locationService
          .requestLocationPermission();

      emit(
        state.copyWith(
          permissionStatus: permissionStatus,
          isLoadingUserLocation: true,
        ),
      );

      if (permissionStatus == LocationPermissionStatus.granted) {
        // Get user location
        final CoordinatesValueObject? userLocation = await _locationService
            .getCurrentLocation();

        if (userLocation != null && userLocation.valid) {
          // Calculate distances and sort locations
          final Map<String, DistanceValueObject> locationDistances = {};
          final List<Location> sortedLocations = List<Location>.from(
            state.locations,
          );

          for (final location in sortedLocations) {
            final CoordinatesValueObject locationCoords =
                CoordinatesValueObject.fromLatLng(
                  location.latitude,
                  location.longitude,
                );

            final DistanceValueObject distance = _locationService
                .calculateDistance(userLocation, locationCoords);
            locationDistances[location.id] = distance;
          }

          // Sort locations by distance (closest first)
          sortedLocations.sort((a, b) {
            final distanceA = locationDistances[a.id];
            final distanceB = locationDistances[b.id];

            if (distanceA == null || distanceB == null) return 0;

            return distanceA.kilometers.compareTo(distanceB.kilometers);
          });

          emit(
            state.copyWith(
              userLocation: userLocation,
              isLoadingUserLocation: false,
              locationDistances: locationDistances,
              locations: sortedLocations,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingUserLocation: false));
        }
      } else {
        emit(state.copyWith(isLoadingUserLocation: false));
      }
    } catch (error) {
      emit(state.copyWith(isLoadingUserLocation: false));
    }
  }

  Future<void> retryLocationPermission() async {
    await _initializeLocationServices();
  }

  List<Location> _sortLocationsByDistance(List<Location> locations) {
    final userLocation = state.userLocation;
    final locationDistances = state.locationDistances;

    if (userLocation == null ||
        !userLocation.valid ||
        locationDistances.isEmpty) {
      return locations;
    }

    final sortedLocations = List<Location>.from(locations);
    sortedLocations.sort((a, b) {
      final distanceA = locationDistances[a.id];
      final distanceB = locationDistances[b.id];

      if (distanceA == null || distanceB == null) return 0;

      return distanceA.kilometers.compareTo(distanceB.kilometers);
    });

    return sortedLocations;
  }

  Future<void> searchLocations(String query) async {
    if (state.status != LocationListStatus.loaded) return;

    emit(state.copyWith(status: LocationListStatus.loading));

    try {
      final locations = await _locationRepository.searchLocations(query);
      final sortedLocations = _sortLocationsByDistance(locations);
      emit(
        state.copyWith(
          status: LocationListStatus.loaded,
          locations: sortedLocations,
        ),
      );
    } catch (e) {
      emit(const LocationListState.error('Failed to search locations'));
    }
  }

  Future<void> filterByCapabilities(
    Set<LocationCapability> capabilities,
  ) async {
    if (state.status != LocationListStatus.loaded) return;

    emit(state.copyWith(status: LocationListStatus.loading));

    try {
      final locations = await _locationRepository.filterLocationsByCapabilities(
        capabilities,
      );
      final sortedLocations = _sortLocationsByDistance(locations);
      emit(
        state.copyWith(
          status: LocationListStatus.loaded,
          locations: sortedLocations,
        ),
      );
    } catch (e) {
      emit(const LocationListState.error('Failed to filter locations'));
    }
  }

  Future<void> filterBySize(LocationSize size) async {
    if (state.status != LocationListStatus.loaded) return;

    emit(state.copyWith(status: LocationListStatus.loading));

    try {
      final locations = await _locationRepository.filterLocationsBySize(size);
      final sortedLocations = _sortLocationsByDistance(locations);
      emit(
        state.copyWith(
          status: LocationListStatus.loaded,
          locations: sortedLocations,
        ),
      );
    } catch (e) {
      emit(const LocationListState.error('Failed to filter locations'));
    }
  }

  Future<void> getLocationsNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    emit(state.copyWith(status: LocationListStatus.loading));

    try {
      final locations = await _locationRepository.getLocationsNearby(
        latitude,
        longitude,
        radiusKm,
      );
      final sortedLocations = _sortLocationsByDistance(locations);
      emit(
        state.copyWith(
          status: LocationListStatus.loaded,
          locations: sortedLocations,
        ),
      );
    } catch (e) {
      emit(const LocationListState.error('Failed to load nearby locations'));
    }
  }
}
