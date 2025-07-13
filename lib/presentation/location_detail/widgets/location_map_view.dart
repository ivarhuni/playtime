import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/core/value_objects/coordinates_value_object.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart';

class LocationMapView extends StatefulWidget {
  final Location location;
  final CoordinatesValueObject? userLocation;
  final LocationPermissionStatus permissionStatus;
  final bool isLoadingUserLocation;

  const LocationMapView({
    super.key,
    required this.location,
    this.userLocation,
    this.permissionStatus = LocationPermissionStatus.unasked,
    this.isLoadingUserLocation = false,
  });

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  bool _hasMapError = false;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(LocationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLocation != widget.userLocation) {
      _createMarkers();
      _fitMarkersIfNeeded();
    }
  }

  void _createMarkers() {
    try {
      _markers.clear();

      // Location marker (always visible)
      _markers.add(
        Marker(
          markerId: const MarkerId('location'),
          position: LatLng(widget.location.latitude, widget.location.longitude),
          infoWindow: InfoWindow(
            title: widget.location.address,
            snippet: widget.location.capabilitiesDisplayText,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    } catch (e) {
      print('❌ LocationMapView: Error creating markers: $e');
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    try {
      _controller = controller;
      await _fitMarkersIfNeeded();
    } catch (e) {
      print('❌ LocationMapView: Error in _onMapCreated: $e');
      setState(() {
        _hasMapError = true;
      });
    }
  }

  Future<void> _fitMarkersIfNeeded() async {
    final controller = _controller;
    final userLocation = widget.userLocation;

    if (controller == null || userLocation == null || !userLocation.valid) {
      return;
    }

    try {
      // Validate coordinates before creating bounds
      final locationLat = widget.location.latitude;
      final locationLng = widget.location.longitude;
      final userLat = userLocation.latitude;
      final userLng = userLocation.longitude;

      // Check if coordinates are valid
      if (locationLat.isNaN ||
          locationLng.isNaN ||
          userLat.isNaN ||
          userLng.isNaN) {
        print('❌ LocationMapView: Invalid coordinates detected');
        return;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(
          [locationLat, userLat].reduce((a, b) => a < b ? a : b),
          [locationLng, userLng].reduce((a, b) => a < b ? a : b),
        ),
        northeast: LatLng(
          [locationLat, userLat].reduce((a, b) => a > b ? a : b),
          [locationLng, userLng].reduce((a, b) => a > b ? a : b),
        ),
      );

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    } catch (e) {
      print('❌ LocationMapView: Error fitting markers: $e');
      // Fallback to simple zoom on location
      try {
        await controller.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(widget.location.latitude, widget.location.longitude),
          ),
        );
      } catch (e2) {
        print('❌ LocationMapView: Error with fallback camera movement: $e2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: [
          if (_hasMapError)
            const _MapErrorStateWidget()
          else
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.location.latitude,
                  widget.location.longitude,
                ),
                zoom: _getInitialZoom(),
              ),
              markers: _markers,
              myLocationEnabled:
                  widget.permissionStatus == LocationPermissionStatus.granted,
              myLocationButtonEnabled:
                  widget.permissionStatus == LocationPermissionStatus.granted,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapType: MapType.normal,
            ),
          if (widget.isLoadingUserLocation)
            const Positioned(
              top: 16,
              right: 16,
              child: _LocationLoadingOverlay(),
            ),
        ],
      ),
    );
  }

  double _getInitialZoom() {
    final userLocation = widget.userLocation;
    return (userLocation != null && userLocation.valid) ? 12.0 : 14.0;
  }
}

class _MapErrorStateWidget extends StatelessWidget {
  const _MapErrorStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Error loading map',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check your internet connection\nand Google Maps API key',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationLoadingOverlay extends StatelessWidget {
  const _LocationLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Getting location...',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
