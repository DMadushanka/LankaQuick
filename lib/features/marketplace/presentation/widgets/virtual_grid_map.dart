import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';

class MapPoint {
  final double lat;
  final double lng;
  const MapPoint(this.lat, this.lng);

  Offset toOffset(double width, double height) {
    const double minLat = 6.9000;
    const double maxLat = 6.9500;
    const double minLng = 79.8400;
    const double maxLng = 79.8900;

    final double x = (lng - minLng) / (maxLng - minLng) * width;
    final double y = (maxLat - lat) / (maxLat - minLat) * height;
    return Offset(x, y);
  }

  static MapPoint fromOffset(Offset offset, double width, double height) {
    const double minLat = 6.9000;
    const double maxLat = 6.9500;
    const double minLng = 79.8400;
    const double maxLng = 79.8900;

    final double lng = minLng + (offset.dx / width) * (maxLng - minLng);
    final double lat = maxLat - (offset.dy / height) * (maxLat - minLat);
    return MapPoint(lat, lng);
  }
}

class VirtualGridMap extends StatefulWidget {
  final double? seekerLat;
  final double? seekerLng;
  final List<UserEntity> providers;
  final String? selectedProviderId;
  final List<MapPoint>? routePoints;
  final bool isSelectingLocation;
  final double? pendingLat;
  final double? pendingLng;
  final Function(double lat, double lng)? onTapMap;
  final double mapHeight;

  const VirtualGridMap({
    super.key,
    this.seekerLat,
    this.seekerLng,
    this.providers = const [],
    this.selectedProviderId,
    this.routePoints,
    this.isSelectingLocation = false,
    this.pendingLat,
    this.pendingLng,
    this.onTapMap,
    this.mapHeight = 350.0,
  });

  @override
  State<VirtualGridMap> createState() => _VirtualGridMapState();
}

class _VirtualGridMapState extends State<VirtualGridMap> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VirtualGridMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProviderId != null && widget.selectedProviderId != oldWidget.selectedProviderId) {
      final p = widget.providers.firstWhere(
        (element) => element.uid == widget.selectedProviderId,
        orElse: () => widget.providers.first,
      );
      if (p.locationLat != null && p.locationLng != null) {
        _mapController.move(LatLng(p.locationLat!, p.locationLng!), 15.0);
      }
    }
  }

  void _zoom(double factor) {
    final currentZoom = _mapController.camera.zoom;
    final targetZoom = (currentZoom + factor).clamp(10.0, 18.0);
    _mapController.move(_mapController.camera.center, targetZoom);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final LatLng initialCenter = LatLng(
      widget.seekerLat ?? 7.0897,
      widget.seekerLng ?? 79.9925,
    );

    return Container(
      height: widget.mapHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2332) : const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                if (widget.onTapMap != null) {
                  widget.onTapMap!(point.latitude, point.longitude);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.locallink.app',
              ),
              if (widget.routePoints != null && widget.routePoints!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.routePoints!.map((pt) => LatLng(pt.lat, pt.lng)).toList(),
                      color: AppTheme.primaryColor,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (widget.seekerLat != null && widget.seekerLng != null)
                    Marker(
                      point: LatLng(widget.seekerLat!, widget.seekerLng!),
                      width: 40,
                      height: 40,
                      child: _buildSeekerMarker(),
                    ),
                  if (widget.isSelectingLocation && widget.pendingLat != null && widget.pendingLng != null)
                    Marker(
                      point: LatLng(widget.pendingLat!, widget.pendingLng!),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.accentColor,
                        size: 38,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3))],
                      ),
                    ),
                  ...widget.providers.map((p) {
                    if (p.locationLat == null || p.locationLng == null) return null;
                    final isSelected = p.uid == widget.selectedProviderId;
                    return Marker(
                      point: LatLng(p.locationLat!, p.locationLng!),
                      width: 40,
                      height: 40,
                      child: _buildProviderMarker(p, isSelected),
                    );
                  }).whereType<Marker>(),
                ],
              ),
            ],
          ),

          // Map HUD Controls
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _buildHudButton(
                  icon: Icons.add,
                  onPressed: () => _zoom(1.0),
                ),
                const SizedBox(height: 8),
                _buildHudButton(
                  icon: Icons.remove,
                  onPressed: () => _zoom(-1.0),
                ),
                const SizedBox(height: 8),
                _buildHudButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    if (widget.seekerLat != null && widget.seekerLng != null) {
                      _mapController.move(LatLng(widget.seekerLat!, widget.seekerLng!), 14.5);
                    } else {
                      _mapController.move(LatLng(7.0897, 79.9925), 14.5);
                    }
                  },
                ),
              ],
            ),
          ),

          // Prompt label when setting location
          if (widget.isSelectingLocation)
            Positioned(
              left: 16,
              right: 64,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.accentColor, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap map to set location coordinates.',
                        style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeekerMarker() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32 * _pulseController.value,
              height: 32 * _pulseController.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(1.0 - _pulseController.value),
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(color: Colors.white, blurRadius: 4),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProviderMarker(UserEntity p, bool isSelected) {
    final isCoconutPlucker = p.name.contains('Coconut') || p.name.contains('Pol');
    final isGrassCutter = p.name.contains('Lawn') || p.name.contains('Gas');

    IconData iconData = Icons.engineering;
    if (isCoconutPlucker) iconData = Icons.park_outlined;
    if (isGrassCutter) iconData = Icons.grass;

    return GestureDetector(
      onTap: () {
        if (widget.onTapMap != null) {
          widget.onTapMap!(p.locationLat!, p.locationLng!);
        }
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  width: 44 * _pulseController.value,
                  height: 44 * _pulseController.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.secondaryColor.withOpacity(0.8 - _pulseController.value * 0.8),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.secondaryColor : const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : AppTheme.secondaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHudButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.85),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
