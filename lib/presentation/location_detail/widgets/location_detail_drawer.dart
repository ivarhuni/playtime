import 'package:flutter/material.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';
import 'package:ut_ad_leika/domain/core/value_objects/distance_value_object.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart';
import 'package:ut_ad_leika/presentation/location_detail/widgets/location_capability_chip.dart';

class LocationDetailDrawer extends StatelessWidget {
  final Location location;
  final DistanceValueObject? distance;
  final LocationPermissionStatus permissionStatus;
  final VoidCallback onOpenInMaps;
  final VoidCallback? onRetryLocation;

  const LocationDetailDrawer({
    super.key,
    required this.location,
    this.distance,
    required this.permissionStatus,
    required this.onOpenInMaps,
    this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // 60% of screen as specified
      minChildSize: 0.6,
      maxChildSize: 1.0, // Allow full screen coverage
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildLocationHeader(context),
                    const SizedBox(height: 16),
                    _buildLocationDetails(context),
                    const SizedBox(height: 20),
                    _buildCapabilities(context),
                    const SizedBox(height: 20),
                    _buildDistanceSection(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                    // Additional content for expanded view
                    _buildAdditionalInfo(context),
                    const SizedBox(height: 40), // Extra padding at bottom
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          location.address,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.star,
              size: 20,
              color: Colors.amber[600],
            ),
            const SizedBox(width: 4),
            Text(
              location.starRating.toStringAsFixed(1),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getSizeColor(location.size).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSizeColor(location.size).withOpacity(0.3),
                ),
              ),
              child: Text(
                location.size.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getSizeColor(location.size),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationDetails(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      location.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  Widget _buildCapabilities(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facilities',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        LocationCapabilityChipList(
          capabilities: location.capabilities,
          isCompact: false,
        ),
      ],
    );
  }

  Widget _buildDistanceSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _buildDistanceContent(context, theme),
      ],
    );
  }

  Widget _buildDistanceContent(BuildContext context, ThemeData theme) {
    if (permissionStatus == LocationPermissionStatus.denied ||
        permissionStatus == LocationPermissionStatus.deniedForever) {
      return Row(
        children: [
          Icon(
            Icons.location_off,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            'Location permission required',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          if (onRetryLocation != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetryLocation,
              child: const Text('Enable'),
            ),
          ],
        ],
      );
    }
    
    if (distance == null || distance!.isInvalid) {
      return Row(
        children: [
          Icon(
            Icons.location_searching,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Calculating distance...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    
    return Row(
      children: [
        Icon(
          Icons.near_me,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          distance!.displayText,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'from your location',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onOpenInMaps,
        icon: const Icon(Icons.map),
        label: const Text('Open in Maps'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(context, 'Safety', 'All equipment regularly inspected and maintained according to safety standards.'),
        const SizedBox(height: 12),
        _buildInfoCard(context, 'Age Range', 'Suitable for children ages 2-12 years old.'),
        const SizedBox(height: 12),
        _buildInfoCard(context, 'Accessibility', 'Wheelchair accessible paths and nearby parking available.'),
        const SizedBox(height: 12),
        _buildInfoCard(context, 'Tips', 'Best visited during morning hours for cooler weather and fewer crowds.'),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSizeColor(LocationSize size) {
    switch (size) {
      case LocationSize.small:
        return Colors.blue;
      case LocationSize.medium:
        return Colors.orange;
      case LocationSize.Playrge:
        return Colors.green;
    }
  }
} 
