import 'package:flutter/material.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';
import 'package:ut_ad_leika/presentation/core/navigation/navigation_service.dart';
import 'package:ut_ad_leika/presentation/core/theme/play_theme.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/location_detail/location_detail_page.dart';

class LocationCard extends StatelessWidget {
  final Location location;

  const LocationCard({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigationService().navigateTo(
          context,
          LocationDetailPage(locationId: location.id),
        );
      },
      borderRadius: BorderRadius.circular(PlayCornerRadius.large),
      child: PlayCard(
        child: Padding(
          padding: const EdgeInsets.all(PlayPaddings.small),
          child: Row(
            children: [
              // Circular image
              ClipRRect(
                borderRadius: BorderRadius.circular(PlayCornerRadius.small),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(PlayCornerRadius.small),
                  ),
                  child: location.imageUrl.isNotEmpty
                      ? Image.network(
                          location.imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(PlayCornerRadius.small),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.grey,
                                size: 24,
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 24,
                        ),
                ),
              ),
              
              const SizedBox(width: PlayPaddings.small),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Text(
                      location.address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Capabilities and Size
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            location.capabilitiesDisplayText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: PlayPaddings.extraSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSizeColor(location.size),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            location.size.displayName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Star rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final isFilled = index < location.starRating.floor();
                          final isHalf = index == location.starRating.floor() && 
                                        location.starRating % 1 >= 0.5;
                          
                          return Icon(
                            isHalf ? Icons.star_half : Icons.star,
                            size: 14,
                            color: isFilled || isHalf 
                                ? Colors.amber[600] 
                                : Colors.grey[300],
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          location.starRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSizeColor(LocationSize size) {
    switch (size) {
      case LocationSize.small:
        return Colors.blue[400]!;
      case LocationSize.medium:
        return Colors.orange[400]!;
      case LocationSize.Playrge:
        return Colors.green[400]!;
    }
  }
} 
