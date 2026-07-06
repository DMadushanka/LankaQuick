import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';

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

class MapPoint {
  final double lat;
  final double lng;
  const MapPoint(this.lat, this.lng);

  Offset toOffset(double width, double height) {
    // Colombo bounds: Lat 6.9000 to 6.9500, Lng 79.8400 to 79.8900
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

class _VirtualGridMapState extends State<VirtualGridMap> with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _pulseController;
  late AnimationController _routeDashController;
  double _zoomScale = 1.0;
  final double _canvasWidth = 1200.0;
  final double _canvasHeight = 1200.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onMapTransformed);

    // Initialize center zoom
    final double initialX = (_canvasWidth - 350) / 2;
    final double initialY = (_canvasHeight - 350) / 2;
    _transformationController.value = Matrix4.identity()
      ..translate(-initialX, -initialY)
      ..scale(1.2);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _routeDashController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onMapTransformed);
    _transformationController.dispose();
    _pulseController.dispose();
    _routeDashController.dispose();
    super.dispose();
  }

  void _onMapTransformed() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _zoomScale).abs() > 0.01) {
      setState(() {
        _zoomScale = scale;
      });
    }
  }

  void _zoom(double factor) {
    final Matrix4 current = _transformationController.value;
    final double scale = current.getMaxScaleOnAxis();
    final double newScale = (scale * factor).clamp(0.5, 3.0);
    
    // Smooth zoom center mapping
    final double dx = current.entry(0, 3);
    final double dy = current.entry(1, 3);
    
    setState(() {
      _transformationController.value = Matrix4.identity()
        ..translate(dx * factor, dy * factor)
        ..scale(newScale);
      _zoomScale = newScale;
    });
  }

  void _centerOn(double lat, double lng) {
    final point = MapPoint(lat, lng);
    final offset = point.toOffset(_canvasWidth, _canvasHeight);
    
    // Calculate centered translation
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = widget.mapHeight;
    
    final double targetX = -offset.dx * _zoomScale + screenWidth / 2;
    final double targetY = -offset.dy * _zoomScale + screenHeight / 2;
    
    setState(() {
      _transformationController.value = Matrix4.identity()
        ..translate(targetX, targetY)
        ..scale(_zoomScale);
    });
  }

  @override
  void didUpdateWidget(VirtualGridMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-center on selected provider
    if (widget.selectedProviderId != null && widget.selectedProviderId != oldWidget.selectedProviderId) {
      final p = widget.providers.firstWhere((element) => element.uid == widget.selectedProviderId);
      if (p.locationLat != null && p.locationLng != null) {
        _centerOn(p.locationLat!, p.locationLng!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.mapHeight,
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // The Interactive Map Canvas
          GestureDetector(
            onDoubleTap: () => _zoom(1.5),
            onTapUp: (details) {
              if (widget.onTapMap != null) {
                // Map screen touch coordinates to lat/lng
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localOffset = renderBox.globalToLocal(details.globalPosition);
                
                // Reverse transformations
                final Matrix4 matrix = _transformationController.value;
                final double scale = matrix.getMaxScaleOnAxis();
                final double tx = matrix.entry(0, 3);
                final double ty = matrix.entry(1, 3);
                
                final double canvasX = (localOffset.dx - tx) / scale;
                final double canvasY = (localOffset.dy - ty) / scale;
                
                if (canvasX >= 0 && canvasX <= _canvasWidth && canvasY >= 0 && canvasY <= _canvasHeight) {
                  final mapPt = MapPoint.fromOffset(Offset(canvasX, canvasY), _canvasWidth, _canvasHeight);
                  widget.onTapMap!(mapPt.lat, mapPt.lng);
                }
              }
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 3.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(200),
              child: SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: Stack(
                  children: [
                    // Canvas drawing roads and landscapes
                    AnimatedBuilder(
                      animation: _routeDashController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(_canvasWidth, _canvasHeight),
                          painter: MapPainter(
                            routePoints: widget.routePoints,
                            dashOffsetPhase: _routeDashController.value,
                          ),
                        );
                      },
                    ),

                    // Seeker Pin
                    if (widget.seekerLat != null && widget.seekerLng != null)
                      _buildMarker(
                        lat: widget.seekerLat!,
                        lng: widget.seekerLng!,
                        isSeeker: true,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse ring
                                Container(
                                  width: 32 * _pulseController.value,
                                  height: 32 * _pulseController.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryColor.withOpacity(1.0 - _pulseController.value),
                                  ),
                                ),
                                // Inner dot
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
                        ),
                      ),

                    // Draggable/Pending Pin when setting location
                    if (widget.isSelectingLocation && widget.pendingLat != null && widget.pendingLng != null)
                      _buildMarker(
                        lat: widget.pendingLat!,
                        lng: widget.pendingLng!,
                        isSeeker: false,
                        child: const Icon(
                          Icons.location_on,
                          color: AppTheme.accentColor,
                          size: 38,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3))],
                        ),
                      ),

                    // Service Provider Pins
                    ...widget.providers.map((p) {
                      if (p.locationLat == null || p.locationLng == null) return const SizedBox();
                      final isSelected = p.uid == widget.selectedProviderId;
                      final isCoconutPlucker = p.name.contains('Coconut') || p.name.contains('Pol');
                      final isGrassCutter = p.name.contains('Lawn') || p.name.contains('Gas');

                      IconData iconData = Icons.engineering;
                      if (isCoconutPlucker) iconData = Icons.park_outlined;
                      if (isGrassCutter) iconData = Icons.grass;

                      return _buildMarker(
                        lat: p.locationLat!,
                        lng: p.locationLng!,
                        isSeeker: false,
                        child: GestureDetector(
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
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Map HUD Controls
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _buildHudButton(
                  icon: Icons.add,
                  onPressed: () => _zoom(1.2),
                ),
                const SizedBox(height: 8),
                _buildHudButton(
                  icon: Icons.remove,
                  onPressed: () => _zoom(0.8),
                ),
                const SizedBox(height: 8),
                _buildHudButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    // Center on seeker or default
                    if (widget.seekerLat != null && widget.seekerLng != null) {
                      _centerOn(widget.seekerLat!, widget.seekerLng!);
                    } else {
                      _centerOn(6.9200, 79.8680); // Seeker default
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

  Widget _buildMarker({
    required double lat,
    required double lng,
    required bool isSeeker,
    required Widget child,
  }) {
    final pt = MapPoint(lat, lng);
    final offset = pt.toOffset(_canvasWidth, _canvasHeight);

    // Dynamic scale-independent mapping
    return Positioned(
      left: offset.dx - 25,
      top: offset.dy - 25,
      width: 50,
      height: 50,
      child: Transform.scale(
        scale: 1.0 / _zoomScale, // Counteracts map zoom to keep marker size constant
        child: Center(child: child),
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

class MapPainter extends CustomPainter {
  final List<MapPoint>? routePoints;
  final double dashOffsetPhase;

  MapPainter({this.routePoints, required this.dashOffsetPhase});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 1. Draw Oceans/Rivers (Water Body)
    final Paint waterPaint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.12)
      ..style = PaintingStyle.fill;
    
    // Procedural Ocean on the West
    final Path oceanPath = Path()
      ..moveTo(0, 0)
      ..lineTo(140, 0)
      ..quadraticBezierTo(120, size.height * 0.3, 150, size.height * 0.6)
      ..quadraticBezierTo(170, size.height * 0.8, 130, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(oceanPath, waterPaint);

    // Procedural Lake (Beira Lake style) in Center-North
    final Path lakePath = Path()
      ..moveTo(420, 280)
      ..cubicTo(450, 220, 560, 240, 580, 310)
      ..cubicTo(600, 380, 480, 420, 440, 360)
      ..close();
    canvas.drawPath(lakePath, waterPaint);

    // 2. Draw Parks
    final Paint parkPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    // Viharamahadevi Park (Center)
    final Rect centerPark = Rect.fromLTWH(620, 580, 160, 100);
    canvas.drawRRect(RRect.fromRectAndRadius(centerPark, const Radius.circular(20)), parkPaint);

    // Galle Face Green (West Beach side)
    final Rect beachfrontGreen = Rect.fromLTWH(135, 340, 40, 180);
    canvas.drawRRect(RRect.fromRectAndRadius(beachfrontGreen, const Radius.circular(8)), parkPaint);

    // 3. Draw Grid Lines
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1.0;
    
    const double gridSize = 80.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 4. Draw Streets / Road Networks
    final Paint roadBasePaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint roadLinePaint = Paint()
      ..color = const Color(0xFF475569).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Define Colombo Main Roads
    final List<Path> roads = [
      // Galle Road (West coastal road)
      Path()..moveTo(180, 0)..lineTo(180, size.height),
      // R. A. De Mel Mawatha (Duplication Road)
      Path()..moveTo(280, 100)..lineTo(280, size.height),
      // Havelock/T.B. Jayah Road
      Path()..moveTo(420, 0)..lineTo(420, size.height - 100),
      // Baseline Road (East side bypass)
      Path()..moveTo(900, 0)..lineTo(900, size.height),
      
      // Horizontal Crossings
      // Galle Face Center Road
      Path()..moveTo(180, 300)..lineTo(900, 300),
      // Dharmapala Mawatha (Town Hall)
      Path()..moveTo(180, 520)..lineTo(900, 520),
      // Bauddhaloka Mawatha (Colombo 7)
      Path()..moveTo(100, 840)..lineTo(1100, 840),
      // Albert Crescent round-about park connector
      Path()..moveTo(550, 520)..quadraticBezierTo(620, 720, 900, 720),
    ];

    for (var road in roads) {
      roadBasePaint.strokeWidth = 10.0;
      canvas.drawPath(road, roadBasePaint);
      canvas.drawPath(road, roadLinePaint);
    }

    // 5. Draw Active Route Line (When Tracking)
    if (routePoints != null && routePoints!.length > 1) {
      final Paint routeBasePaint = Paint()
        ..color = AppTheme.primaryColor.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round;

      final Paint routeGlowPaint = Paint()
        ..color = AppTheme.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final Path routePath = Path();
      final Offset first = routePoints!.first.toOffset(size.width, size.height);
      routePath.moveTo(first.dx, first.dy);
      
      for (int i = 1; i < routePoints!.length; i++) {
        final Offset pt = routePoints![i].toOffset(size.width, size.height);
        routePath.lineTo(pt.dx, pt.dy);
      }

      // Draw base route path
      canvas.drawPath(routePath, routeBasePaint);

      // Draw animated dashed route path (glow flow effect)
      
      // Custom dash rendering along polyline segments
      final Paint dashPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(routePath, routeGlowPaint);

      // Draw particle flow animation
      for (int i = 0; i < routePoints!.length - 1; i++) {
        final start = routePoints![i].toOffset(size.width, size.height);
        final end = routePoints![i+1].toOffset(size.width, size.height);
        
        final dx = end.dx - start.dx;
        final dy = end.dy - start.dy;
        final distance = math.sqrt(dx * dx + dy * dy);
        
        final double step = 20.0;
        final double phase = (dashOffsetPhase * step) % step;
        
        for (double d = phase; d < distance; d += step) {
          final double ratio = d / distance;
          final double px = start.dx + dx * ratio;
          final double py = start.dy + dy * ratio;
          canvas.drawCircle(Offset(px, py), 2.5, dashPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.dashOffsetPhase != dashOffsetPhase || oldDelegate.routePoints != routePoints;
  }
}
