import 'package:flutter/material.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';

class LocationCapabilityChip extends StatelessWidget {
  final LocationCapability capability;
  final bool isCompact;

  const LocationCapabilityChip({
    super.key,
    required this.capability,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 6.0 : 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(isCompact ? 6.0 : 8.0),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCapabilityIcon(capability),
            size: isCompact ? 14.0 : 16.0,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          if (!isCompact) ...[
            const SizedBox(width: 6),
            Text(
              capability.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCapabilityIcon(LocationCapability capability) {
    switch (capability) {
      case LocationCapability.slide:
        return Icons.landscape; // Represents slide/playground equipment
      case LocationCapability.swing:
        return Icons.sensors; // Represents swinging motion
      case LocationCapability.sandbox:
        return Icons.category; // Represents sandbox/container
    }
  }
}

class LocationCapabilityChipList extends StatelessWidget {
  final Set<LocationCapability> capabilities;
  final bool isCompact;
  final MainAxisAlignment alignment;

  const LocationCapabilityChipList({
    super.key,
    required this.capabilities,
    this.isCompact = false,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (capabilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      alignment: _wrapAlignmentFromMainAxis(alignment),
      children: capabilities
          .map((capability) => LocationCapabilityChip(
                capability: capability,
                isCompact: isCompact,
              ))
          .toList(),
    );
  }

  WrapAlignment _wrapAlignmentFromMainAxis(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }
} 
