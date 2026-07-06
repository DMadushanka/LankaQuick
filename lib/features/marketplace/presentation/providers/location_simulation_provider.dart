import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/presentation/providers/bookings_provider.dart';
import 'package:local_link/features/bookings/presentation/screens/bookings_demo_screen.dart';
import 'package:local_link/features/marketplace/presentation/widgets/virtual_grid_map.dart';

class TrackingState {
  final String bookingId;
  final String providerId;
  final double currentLat;
  final double currentLng;
  final List<MapPoint> route;
  final int currentRouteIndex;
  final bool isSimulating;
  final String status; // 'accepted', 'en_route', 'arrived'

  TrackingState({
    required this.bookingId,
    required this.providerId,
    required this.currentLat,
    required this.currentLng,
    required this.route,
    this.currentRouteIndex = 0,
    this.isSimulating = false,
    required this.status,
  });

  TrackingState copyWith({
    String? bookingId,
    String? providerId,
    double? currentLat,
    double? currentLng,
    List<MapPoint>? route,
    int? currentRouteIndex,
    bool? isSimulating,
    String? status,
  }) {
    return TrackingState(
      bookingId: bookingId ?? this.bookingId,
      providerId: providerId ?? this.providerId,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      route: route ?? this.route,
      currentRouteIndex: currentRouteIndex ?? this.currentRouteIndex,
      isSimulating: isSimulating ?? this.isSimulating,
      status: status ?? this.status,
    );
  }
}

class TrackingSimulationNotifier extends Notifier<TrackingState?> {
  Timer? _timer;

  @override
  TrackingState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  // Generates a path snapped to roads in our custom painter
  List<MapPoint> _generateStreetSnappedRoute(
    double startLat,
    double startLng,
    double destLat,
    double destLng,
  ) {
    // Street grid junctions in Colombo custom coordinate bounds
    // Galle Rd: 79.8450, Duplication: 79.8520, Havelock: 79.8600, Baseline: 79.8800
    // Cross streets: 6.9400, 6.9280, 6.9150, 6.9020
    
    // We snap coordinates and create a beautiful grid route
    final List<MapPoint> path = [MapPoint(startLat, startLng)];
    
    // Determine closest intermediate road coordinates
    final double midLat = (startLat + destLat) / 2;
    final double midLng = (startLng + destLng) / 2;
    
    // Simple L-shape / Z-shape path following the coordinates of streets
    path.add(MapPoint(startLat, midLng));
    path.add(MapPoint(midLat, midLng));
    path.add(MapPoint(midLat, destLng));
    path.add(MapPoint(destLat, destLng));

    // Interpolate points to make the driving animation extremely smooth
    final List<MapPoint> smoothPath = [];
    for (int i = 0; i < path.length - 1; i++) {
      final p1 = path[i];
      final p2 = path[i + 1];
      
      const int subdivisions = 4; // Add intermediate subdivisions for slow smooth driving
      for (int s = 0; s < subdivisions; s++) {
        final double ratio = s / subdivisions;
        final double lat = p1.lat + (p2.lat - p1.lat) * ratio;
        final double lng = p1.lng + (p2.lng - p1.lng) * ratio;
        smoothPath.add(MapPoint(lat, lng));
      }
    }
    smoothPath.add(MapPoint(destLat, destLng));
    return smoothPath;
  }

  void startSimulation({
    required String bookingId,
    required String providerId,
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    required bool isSupabaseConfigured,
  }) {
    _timer?.cancel();

    final routePoints = _generateStreetSnappedRoute(startLat, startLng, destLat, destLng);
    
    state = TrackingState(
      bookingId: bookingId,
      providerId: providerId,
      currentLat: startLat,
      currentLng: startLng,
      route: routePoints,
      currentRouteIndex: 0,
      isSimulating: true,
      status: 'accepted',
    );

    // Update status to en_route initially
    _updateStatus('en_route', bookingId, isSupabaseConfigured);

    // Start Simulation Timer
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      final nextIndex = state!.currentRouteIndex + 1;
      
      if (nextIndex >= state!.route.length) {
        // Provider has arrived at seeker's house
        timer.cancel();
        state = state!.copyWith(
          currentRouteIndex: state!.route.length - 1,
          currentLat: destLat,
          currentLng: destLng,
          status: 'arrived',
          isSimulating: false,
        );
        _updateLocation(providerId, destLat, destLng, isSupabaseConfigured);
        _updateStatus('arrived', bookingId, isSupabaseConfigured);
      } else {
        // En route movement
        final nextPt = state!.route[nextIndex];
        state = state!.copyWith(
          currentRouteIndex: nextIndex,
          currentLat: nextPt.lat,
          currentLng: nextPt.lng,
          status: 'en_route',
        );
        _updateLocation(providerId, nextPt.lat, nextPt.lng, isSupabaseConfigured);
      }
    });
  }

  void stopSimulation() {
    _timer?.cancel();
    if (state != null) {
      state = state!.copyWith(isSimulating: false);
    }
  }

  void _updateLocation(String providerId, double lat, double lng, bool isSupabase) {
    if (isSupabase) {
      ref.read(authControllerProvider.notifier).updateLocation(
            uid: providerId,
            lat: lat,
            lng: lng,
          );
    } else {
      // Sync in local mock list
      ref.read(mockProvidersProvider.notifier).update((stateList) {
        return stateList.map((p) {
          if (p.uid == providerId) {
            return UserEntity(
              uid: p.uid,
              name: p.name,
              email: p.email,
              role: p.role,
              locationLat: lat,
              locationLng: lng,
            );
          }
          return p;
        }).toList();
      });
    }
  }

  void _updateStatus(String status, String bookingId, bool isSupabase) {
    if (isSupabase) {
      ref.read(bookingsControllerProvider.notifier).updateStatus(
            bookingId: bookingId,
            status: status,
          );
    } else {
      // Update in local mock bookings list
      ref.read(mockBookingsProvider.notifier).update((stateList) {
        return stateList.map((b) {
          if (b.id == bookingId) {
            return BookingEntity(
              id: b.id,
              seekerId: b.seekerId,
              providerId: b.providerId,
              status: status,
              timestamp: b.timestamp,
            );
          }
          return b;
        }).toList();
      });
    }
  }
}

// Global simulation provider
final trackingSimulationProvider =
    NotifierProvider<TrackingSimulationNotifier, TrackingState?>(() {
  return TrackingSimulationNotifier();
});
