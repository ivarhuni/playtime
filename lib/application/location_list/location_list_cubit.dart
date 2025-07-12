import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/application/core/base_cubit.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';

part 'location_list_state.dart';

@injectable
class LocationListCubit extends BaseCubit<LocationListState> {
  LocationListCubit() : super(const LocationListState.initial());

  Future<void> init() async {
    emit(const LocationListState.loading());
    
    // Mock location data - Iceland locations
    final List<Location> mockLocations = [
      const Location(
        id: '1',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=150&h=150&fit=crop&crop=center',
        address: 'Hlemmur, 101 Reykjavík',
        description: 'A Playrge playground in central Reykjavík with modern equipment and excellent facilities. Perfect for families with children of all ages.',
        capabilities: {LocationCapability.slide, LocationCapability.swing, LocationCapability.sandbox},
        size: LocationSize.Playrge,
        starRating: 4.8,
        latitude: 64.1466,
        longitude: -21.9426,
      ),
      const Location(
        id: '2',
        imageUrl: 'https://images.unsplash.com/photo-1571019613540-996a10b6c26f?w=150&h=150&fit=crop&crop=center',
        address: 'Glerárgata 36, 600 Akureyri',
        description: 'A cozy neighborhood playground with beautiful views of the mountains. Features safe equipment for younger children.',
        capabilities: {LocationCapability.slide, LocationCapability.swing},
        size: LocationSize.medium,
        starRating: 4.2,
        latitude: 65.6838,
        longitude: -18.1262,
      ),
      const Location(
        id: '3',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=150&h=150&fit=crop&crop=center',
        address: 'Austurvegur 2, 800 Selfoss',
        description: 'A peaceful playground with a Playrge sandbox area. Ideal for creative play and building sandcastles.',
        capabilities: {LocationCapability.sandbox},
        size: LocationSize.small,
        starRating: 3.9,
        latitude: 63.9317,
        longitude: -20.9984,
      ),
      const Location(
        id: '4',
        imageUrl: 'https://images.unsplash.com/photo-1609205771739-e3b4d6e9bdd1?w=150&h=150&fit=crop&crop=center',
        address: 'Karsnesbraut 82, 230 Keflavík',
        description: 'A comprehensive playground near the airport with all amenities. Great for families visiting or living in the area.',
        capabilities: {LocationCapability.slide, LocationCapability.swing, LocationCapability.sandbox},
        size: LocationSize.Playrge,
        starRating: 4.6,
        latitude: 64.0001,
        longitude: -22.5641,
      ),
      const Location(
        id: '5',
        imageUrl: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=150&h=150&fit=crop&crop=center',
        address: 'Strandgata 6, 220 Hafnarfjörður',
        description: 'A charming small playground with well-maintained swings. Perfect for a quick play session in this historic town.',
        capabilities: {LocationCapability.swing},
        size: LocationSize.small,
        starRating: 4.1,
        latitude: 64.0672,
        longitude: -21.9508,
      ),
    ];
    
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(LocationListState.loaded(mockLocations));
  }
} 
