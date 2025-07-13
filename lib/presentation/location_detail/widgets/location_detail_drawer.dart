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
      maxChildSize: 0.9, // Allow full screen coverage
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
              const _DrawerDragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _LocationHeader(location: location),
                    const SizedBox(height: 16),
                    _LocationDetails(location: location),
                    const SizedBox(height: 20),
                    _LocationCapabilities(location: location),
                    const SizedBox(height: 20),
                    _DistanceSection(
                      distance: distance,
                      permissionStatus: permissionStatus,
                      onRetryLocation: onRetryLocation,
                    ),
                    const SizedBox(height: 24),
                    _ActionButtons(onOpenInMaps: onOpenInMaps),
                    const SizedBox(height: 32),
                    const _AdditionalInfo(),
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
}

class _DrawerDragHandle extends StatelessWidget {
  const _DrawerDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class _LocationHeader extends StatelessWidget {
  final Location location;

  const _LocationHeader({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.star, size: 20, color: Colors.amber[600]),
            const SizedBox(width: 4),
            Text(
              location.starRating.toStringAsFixed(1),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            _LocationSizeBadge(size: location.size),
          ],
        ),
      ],
    );
  }
}

class _LocationSizeBadge extends StatelessWidget {
  final LocationSize size;

  const _LocationSizeBadge({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeColor = _getSizeColor(size);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: sizeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sizeColor.withOpacity(0.3)),
      ),
      child: Text(
        size.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: sizeColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
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

class _LocationDetails extends StatelessWidget {
  final Location location;

  const _LocationDetails({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      location.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}

class _LocationCapabilities extends StatelessWidget {
  final Location location;

  const _LocationCapabilities({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
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
}

class _DistanceSection extends StatelessWidget {
  final DistanceValueObject? distance;
  final LocationPermissionStatus permissionStatus;
  final VoidCallback? onRetryLocation;

  const _DistanceSection({
    super.key,
    this.distance,
    required this.permissionStatus,
    this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
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
        _DistanceContent(
          distance: distance,
          permissionStatus: permissionStatus,
          onRetryLocation: onRetryLocation,
        ),
      ],
    );
  }
}

class _DistanceContent extends StatelessWidget {
  final DistanceValueObject? distance;
  final LocationPermissionStatus permissionStatus;
  final VoidCallback? onRetryLocation;

  const _DistanceContent({
    super.key,
    this.distance,
    required this.permissionStatus,
    this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (permissionStatus) {
      case LocationPermissionStatus.granted:
        final currentDistance = distance;
        if (currentDistance != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance from your location',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentDistance.displayText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_searching,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Getting your location...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.deniedForever:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_off,
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Location permission needed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enable location access to see distance',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              if (onRetryLocation != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRetryLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    child: const Text('Enable Location'),
                  ),
                ),
              ],
            ],
          ),
        );

      case LocationPermissionStatus.unasked:
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_searching,
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Checking location...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback? onOpenInMaps;

  const _ActionButtons({super.key, this.onOpenInMaps});

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}

class _AdditionalInfo extends StatelessWidget {
  const _AdditionalInfo({super.key});

  @override
  Widget build(BuildContext context) {
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
        _InfoCard(
          icon: Icons.access_time,
          title: 'Opening Hours',
          content: 'Open 24/7',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.local_parking,
          title: 'Parking',
          content: 'Free parking available',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.pets,
          title: 'Pet Policy',
          content: 'Pets allowed on leash',
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
