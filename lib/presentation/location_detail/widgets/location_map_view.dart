import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
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
    required this.permissionStatus,
    this.isLoadingUserLocation = false,
  });

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  Completer<GoogleMapController> _controller = Completer();
  bool _isMapLoading = true;
  bool _hasMapError = false;

  @override
  void initState() {
    super.initState();
    print('🏁 LocationMapView: Initializing map view');
    print('🏁 LocationMapView: Location to show: ${widget.location.address}');
    print('🏁 LocationMapView: Initial user location: ${widget.userLocation}');
    
    // Add timeout to detect if Google Maps never loads
    Timer(const Duration(seconds: 10), () {
      if (_isMapLoading) {
        print('⏰ LocationMapView: Map loading timeout - Google Maps may not be properly configured');
        print('⏰ LocationMapView: Check your API key and ensure Maps SDK for Android is enabled');
        setState(() {
          _isMapLoading = false;
          _hasMapError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🗺️ LocationMapView: Building map view - Loading: $_isMapLoading, Error: $_hasMapError');
    print('🗺️ LocationMapView: Location: ${widget.location.address} (${widget.location.latitude}, ${widget.location.longitude})');
    print('🗺️ LocationMapView: User Location: ${widget.userLocation}');
    print('🗺️ LocationMapView: Permission Status: ${widget.permissionStatus}');
    
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
      child: Stack(
                  children: [
            if (_hasMapError) ...[
              () {
                print('❌ LocationMapView: Showing error state');
                return _buildErrorState();
              }(),
            ] else if (_isMapLoading) ...[
              () {
                print('⏳ LocationMapView: Showing loading state');
                return _buildLoadingState();
              }(),
            ] else ...[
              () {
                print('✅ LocationMapView: Showing map view');
                return _buildMapView();
              }(),
            ],
            if (widget.isLoadingUserLocation) ...[
              () {
                print('📍 LocationMapView: Showing location loading overlay');
                return _buildLocationLoadingOverlay();
              }(),
            ],
          ],
      ),
    );
  }

  Widget _buildMapView() {
    print('🗺️ LocationMapView: Building GoogleMap widget');
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.location.latitude, widget.location.longitude),
        zoom: _getInitialZoom(),
      ),
      markers: _buildMarkers(),
      myLocationEnabled: false, // We'll show custom markers instead
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapType: MapType.normal,
      // Add error handling
      onCameraMove: (position) {
        print('📹 LocationMapView: Camera moved to ${position.target}');
      },
      onTap: (position) {
        print('👆 LocationMapView: Map tapped at ${position.latitude}, ${position.longitude}');
      },
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.map,
            size: 48,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading map',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationLoadingOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    // Location marker (always visible)
    markers.add(
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

    // User location marker (if available)
    if (widget.userLocation != null && widget.userLocation!.valid) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude),
          infoWindow: const InfoWindow(title: 'Your location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    return markers;
  }

  double _getInitialZoom() {
    // If user location is available, we'll fit both points
    // If not, show the location at high zoom minus one level as specified
    if (widget.userLocation != null && widget.userLocation!.valid) {
      return 12.0; // Will be adjusted by _fitMarkers
    } else {
      return 14.0; // High zoom minus one level for location only
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    print('🗺️ LocationMapView: Google Map created successfully! Controller: $controller');
    _controller.complete(controller);
    
    try {
      print('🗺️ LocationMapView: Setting map loading to false');
      setState(() {
        _isMapLoading = false;
      });

      // Fit markers if user location is available
      if (widget.userLocation != null && widget.userLocation!.valid) {
        print('🗺️ LocationMapView: Fitting markers for user location');
        await _fitMarkers(controller);
      } else {
        print('🗺️ LocationMapView: No user location available, showing location only');
      }
    } catch (e) {
      print('❌ LocationMapView: Error in _onMapCreated: $e');
      setState(() {
        _isMapLoading = false;
        _hasMapError = true;
      });
    }
  }

  Future<void> _fitMarkers(GoogleMapController controller) async {
    if (widget.userLocation == null || !widget.userLocation!.valid) return;

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        [widget.location.latitude, widget.userLocation!.latitude].reduce((a, b) => a < b ? a : b),
        [widget.location.longitude, widget.userLocation!.longitude].reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        [widget.location.latitude, widget.userLocation!.latitude].reduce((a, b) => a > b ? a : b),
        [widget.location.longitude, widget.userLocation!.longitude].reduce((a, b) => a > b ? a : b),
      ),
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0), // 100px padding
    );
  }

  @override
  void didUpdateWidget(LocationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update map view when user location becomes available
    if (oldWidget.userLocation != widget.userLocation && 
        widget.userLocation != null && 
        widget.userLocation!.valid &&
        _controller.isCompleted) {
      _controller.future.then((controller) => _fitMarkers(controller));
    }
  }
} 
