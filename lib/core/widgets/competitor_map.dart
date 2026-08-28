import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';
import 'bear_marker.dart';
import 'ite_avatar.dart';
import 'glass_card.dart';

/// Interactive competitor map with bear face markers.
///
/// Shows user location (mascot) and competitor locations (bear faces
/// with expressions based on rating). Supports tap-to-info and clustering.
/// Used in both Jalur A (idea check) and Jalur B (market gap) result screens.
class CompetitorMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final List<Map<String, dynamic>> competitors;
  final double height;

  const CompetitorMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.radiusKm = 2.0,
    required this.competitors,
    this.height = 260,
  });

  @override
  State<CompetitorMap> createState() => _CompetitorMapState();
}

class _CompetitorMapState extends State<CompetitorMap> {
  Map<String, dynamic>? _selectedCompetitor;

  double get _zoom {
    if (widget.radiusKm <= 1.0) return 15.0;
    if (widget.radiusKm >= 4.0) return 13.0;
    return 14.0;
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.latitude, widget.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(Icons.map_rounded, color: AppColors.secondaryLight, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Peta Kompetitor',
                style: AppTheme.displayFont(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Legend
            _legendItem(BearExpression.happy, 'Kuat'),
            const SizedBox(width: 6),
            _legendItem(BearExpression.neutral, 'Sedang'),
            const SizedBox(width: 6),
            _legendItem(BearExpression.sad, 'Lemah'),
          ],
        ),
        const SizedBox(height: 10),

        // Map container
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceLightElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: _zoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, __) {
                      setState(() => _selectedCompetitor = null);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.umkm.validasi_ide',
                    ),
                    MarkerLayer(
                      markers: [
                        // User Location — Mascot (Ite)
                        Marker(
                          point: center,
                          width: 48,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const IteAvatar(
                              pose: ItePose.greet,
                              size: 48,
                              showEntrance: false,
                            ),
                          ),
                        ),
                        // Competitors — Bear face markers
                        ..._buildCompetitorMarkers(),
                      ],
                    ),
                  ],
                ),

                // Info card overlay when a competitor marker is tapped
                if (_selectedCompetitor != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: _buildInfoCard(_selectedCompetitor!),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildCompetitorMarkers() {
    final markers = widget.competitors
        .where((c) => c['latitude'] != null && c['longitude'] != null)
        .map((c) {
      final lat = (c['latitude'] as num).toDouble();
      final lng = (c['longitude'] as num).toDouble();
      final rating = (c['rating'] as num?)?.toDouble() ?? 0;
      
      print('Competitor ${c['name']}: lat=$lat, lng=$lng');

      return Marker(
        point: LatLng(lat, lng),
        width: 36,
        height: 36,
        child: BearMarker.fromRating(
          rating,
          size: 36,
          onTap: () {
            setState(() => _selectedCompetitor = c);
          },
        ),
      );
    }).toList();

    return markers;
  }

  Widget _buildInfoCard(Map<String, dynamic> competitor) {
    final rating = (competitor['rating'] as num?)?.toDouble() ?? 0;
    final name = competitor['name'] as String? ?? 'Kompetitor';
    final address = competitor['address'] as String? ?? '';

    // Calculate distance from user location
    final compLat = (competitor['latitude'] as num?)?.toDouble();
    final compLng = (competitor['longitude'] as num?)?.toDouble();
    String distanceStr = '';
    if (compLat != null && compLng != null) {
      final distance = const Distance();
      final meters = distance.as(
        LengthUnit.Meter,
        LatLng(widget.latitude, widget.longitude),
        LatLng(compLat, compLng),
      );
      if (meters < 1000) {
        distanceStr = '${meters.round()} m';
      } else {
        distanceStr = '${(meters / 1000).toStringAsFixed(1)} km';
      }
    }

    final ratingColor = rating >= 4
        ? AppColors.scoreHigh
        : rating >= 3
            ? AppColors.scoreMedium
            : AppColors.scoreLow;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          BearMarker.fromRating(rating, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (address.isNotEmpty)
                  Text(
                    address,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: ratingColor),
                    const SizedBox(width: 2),
                    Text(
                      rating > 0 ? rating.toStringAsFixed(1) : '—',
                      style: AppTheme.displayFont(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (distanceStr.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  distanceStr,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _legendItem(BearExpression expression, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BearMarker(expression: expression, size: 14),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
      ],
    );
  }
}
