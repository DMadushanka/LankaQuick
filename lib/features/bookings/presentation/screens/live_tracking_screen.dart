import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_link/features/auth/data/models/user_model.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/presentation/providers/bookings_provider.dart';
import 'package:local_link/features/bookings/presentation/screens/bookings_demo_screen.dart';
import 'package:local_link/features/marketplace/presentation/providers/location_simulation_provider.dart';
import 'package:local_link/features/marketplace/presentation/widgets/virtual_grid_map.dart';

// StreamProvider to watch a single provider's profile (including coordinates)
final providerProfileStreamProvider = StreamProvider.family<UserEntity?, String>((ref, uid) {
  final isSupabase = ref.watch(supabaseConfiguredProvider);
  if (isSupabase) {
    final supabase = Supabase.instance.client;
    return supabase.from('users').stream(primaryKey: ['id']).eq('id', uid).map((event) {
      if (event.isNotEmpty) {
        return UserModel.fromMap(event.first);
      }
      return null;
    });
  } else {
    // Listen to local mock list updates
    final list = ref.watch(mockProvidersProvider);
    final match = list.firstWhere((p) => p.uid == uid, orElse: () => list.first);
    return Stream.value(match);
  }
});

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final BookingEntity booking;
  final bool isSupabaseConfigured;

  const LiveTrackingScreen({
    super.key,
    required this.booking,
    required this.isSupabaseConfigured,
  });

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  // Coordinates helper
  final double seekerDefaultLat = 6.9200;
  final double seekerDefaultLng = 79.8680;

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void _triggerArrivalModal(UserEntity provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.secondaryColor, size: 28),
            SizedBox(width: 12),
            Text('Provider Arrived!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '${provider.name} has arrived at your location. Please proceed to meet them.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isProvider = currentUser.role == 'provider';
    
    // Seeker coordinates
    final double seekerLat = seekerDefaultLat;
    final double seekerLng = seekerDefaultLng;

    // Get provider updates
    final providerAsync = ref.watch(providerProfileStreamProvider(widget.booking.providerId));
    final provider = providerAsync.value ??
        UserEntity(
          uid: widget.booking.providerId,
          name: isProvider ? currentUser.name : 'Service Provider',
          email: '',
          role: 'provider',
          locationLat: 6.9380, // Default start base
          locationLng: 79.8480,
        );

    final double provLat = provider.locationLat ?? 6.9380;
    final double provLng = provider.locationLng ?? 79.8480;

    // Listen to simulation state
    final simState = ref.watch(trackingSimulationProvider);
    final bool activeSim = simState?.bookingId == widget.booking.id && simState?.isSimulating == true;

    // Determine path points to draw
    List<MapPoint>? routePoints;
    if (simState != null && simState.bookingId == widget.booking.id) {
      routePoints = simState.route;
    } else {
      // Draw straight line path if not active
      routePoints = [
        MapPoint(provLat, provLng),
        MapPoint(provLat, (provLng + seekerLng) / 2),
        MapPoint(seekerLat, seekerLng),
      ];
    }

    final distance = _calculateDistance(seekerLat, seekerLng, provLat, provLng);
    final int eta = (distance * 2.2).ceil(); // Simple ETA speed projection: ~2 mins per km

    // Watch for arrival to trigger alert dialog automatically for Seekers
    ref.listen(providerProfileStreamProvider(widget.booking.providerId), (prev, next) {
      if (!isProvider && next.value?.locationLat != null) {
        final dist = _calculateDistance(seekerLat, seekerLng, next.value!.locationLat!, next.value!.locationLng!);
        if (dist < 0.05 && prev?.value != null) {
          final prevDist = _calculateDistance(seekerLat, seekerLng, prev!.value!.locationLat!, prev.value!.locationLng!);
          if (prevDist >= 0.05) {
            _triggerArrivalModal(next.value!);
          }
        }
      }
    });

    // Check status logic
    String journeyStatus = widget.booking.status;
    if (activeSim) journeyStatus = 'en_route';
    if (distance < 0.05) journeyStatus = 'arrived';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(tr(ref, 'tracking_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(trackingSimulationProvider.notifier).stopSimulation();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Journey Progress Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: journeyStatus == 'arrived'
                                  ? AppTheme.secondaryColor
                                  : journeyStatus == 'en_route'
                                      ? AppTheme.primaryColor
                                      : AppTheme.accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            journeyStatus == 'arrived'
                                ? tr(ref, 'status_arrived')
                                : journeyStatus == 'en_route'
                                    ? tr(ref, 'status_en_route')
                                    : 'PENDING START',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      if (journeyStatus != 'arrived')
                        Text(
                          '$eta ${tr(ref, 'eta_mins')}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Horizontal stepper progress bar
                  Row(
                    children: [
                      _buildStep(label: 'Hired', active: true),
                      _buildStepDivider(active: journeyStatus == 'en_route' || journeyStatus == 'arrived'),
                      _buildStep(label: 'En Route', active: journeyStatus == 'en_route' || journeyStatus == 'arrived'),
                      _buildStepDivider(active: journeyStatus == 'arrived'),
                      _buildStep(label: 'Arrived', active: journeyStatus == 'arrived'),
                    ],
                  ),
                ],
              ),
            ),

            // Visual Tracking Map
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VirtualGridMap(
                  seekerLat: seekerLat,
                  seekerLng: seekerLng,
                  providers: [provider],
                  selectedProviderId: provider.uid,
                  routePoints: routePoints,
                  mapHeight: double.infinity,
                ),
              ),
            ),

            // Simulator Control Panel for Providers
            if (isProvider)
              _buildSimulatorDashboard(provider, seekerLat, seekerLng, activeSim)
            else
              // Seeker Static Card
              _buildSeekerInfoDashboard(provider, distance),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required String label, required bool active}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppTheme.primaryColor : Colors.grey.shade700,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Icon(
                active ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider({required bool active}) {
    return Container(
      width: 32,
      height: 3,
      color: active ? AppTheme.primaryColor : Colors.grey.shade700,
      margin: const EdgeInsets.only(bottom: 14),
    );
  }

  Widget _buildSimulatorDashboard(
    UserEntity provider,
    double seekerLat,
    double seekerLng,
    bool activeSim,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_suggest, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Text(
                tr(ref, 'sim_dashboard'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: activeSim
                      ? null
                      : () {
                          ref.read(trackingSimulationProvider.notifier).startSimulation(
                                bookingId: widget.booking.id,
                                providerId: provider.uid,
                                startLat: provider.locationLat ?? 6.9380,
                                startLng: provider.locationLng ?? 79.8480,
                                destLat: seekerLat,
                                destLng: seekerLng,
                                isSupabaseConfigured: widget.isSupabaseConfigured,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: Text(tr(ref, 'btn_start_journey'), style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !activeSim
                      ? null
                      : () {
                          ref.read(trackingSimulationProvider.notifier).stopSimulation();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.pause, color: Colors.white),
                  label: const Text('Pause', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // End instantly
              ref.read(trackingSimulationProvider.notifier).stopSimulation();
              if (widget.isSupabaseConfigured) {
                ref.read(authControllerProvider.notifier).updateLocation(
                      uid: provider.uid,
                      lat: seekerLat,
                      lng: seekerLng,
                    );
                ref.read(bookingsControllerProvider.notifier).updateStatus(
                      bookingId: widget.booking.id,
                      status: 'arrived',
                    );
              } else {
                ref.read(mockProvidersProvider.notifier).update((stateList) {
                  return stateList.map((p) {
                    if (p.uid == provider.uid) {
                      return UserEntity(
                        uid: p.uid,
                        name: p.name,
                        email: p.email,
                        role: p.role,
                        locationLat: seekerLat,
                        locationLng: seekerLng,
                      );
                    }
                    return p;
                  }).toList();
                });
                ref.read(mockBookingsProvider.notifier).update((stateList) {
                  return stateList.map((b) {
                    if (b.id == widget.booking.id) {
                      return BookingEntity(
                        id: b.id,
                        seekerId: b.seekerId,
                        providerId: b.providerId,
                        status: 'arrived',
                        timestamp: b.timestamp,
                      );
                    }
                    return b;
                  }).toList();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(tr(ref, 'btn_arrived')),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekerInfoDashboard(UserEntity provider, double distance) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.secondaryColor,
                child: Text(
                  provider.name[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${distance.toStringAsFixed(2)} ${tr(ref, 'distance_away')}',
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Call trigger
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.secondaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.phone, color: AppTheme.secondaryColor, size: 16),
                  label: const Text('Call Provider', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Chat trigger
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor, size: 16),
                  label: const Text('Message', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
