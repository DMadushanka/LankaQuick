import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/presentation/providers/bookings_provider.dart';
import 'package:local_link/features/bookings/presentation/screens/bookings_demo_screen.dart';
import 'package:local_link/features/marketplace/presentation/widgets/virtual_grid_map.dart';
import 'package:local_link/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:local_link/features/marketplace/presentation/screens/marketplace_demo_screen.dart';
import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';

class NearbyMapScreen extends ConsumerStatefulWidget {
  final bool isSupabaseConfigured;

  const NearbyMapScreen({
    super.key,
    required this.isSupabaseConfigured,
  });

  @override
  ConsumerState<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends ConsumerState<NearbyMapScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  String _selectedCategoryFilter = 'all';
  String? _selectedProviderId;
  
  // Provider base location selection state
  bool _isSelectingLocation = false;
  double? _tempLat;
  double? _tempLng;
  bool _isLocationSharingActive = true;

  // Seeker's default GPS coordinate (Colombo 7)
  final double seekerDefaultLat = 6.9200;
  final double seekerDefaultLng = 79.8680;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Haversine distance calculator
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Pi/180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  void _bookProvider(UserEntity provider, String seekerId) {
    if (widget.isSupabaseConfigured) {
      ref.read(bookingsControllerProvider.notifier).requestBooking(
            seekerId: seekerId,
            providerId: provider.uid,
          );
    } else {
      // Mock mode
      ref.read(mockBookingsProvider.notifier).update((state) {
        final newBooking = BookingEntity(
          id: 'mock_book_${DateTime.now().millisecondsSinceEpoch}',
          seekerId: seekerId,
          providerId: provider.uid,
          status: 'pending',
          timestamp: DateTime.now(),
        );
        return [...state, newBooking];
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('${tr(ref, 'toast_request_sent')} to ${provider.name}')),
          ],
        ),
        backgroundColor: AppTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveProviderLocation(String uid) async {
    if (_tempLat == null || _tempLng == null) return;
    
    // Save location to backend
    await ref.read(authControllerProvider.notifier).updateLocation(
          uid: uid,
          lat: _tempLat!,
          lng: _tempLng!,
        );

    // Update in local mock provider list if in Demo mode
    if (!widget.isSupabaseConfigured) {
      ref.read(mockProvidersProvider.notifier).update((state) {
        return state.map((p) {
          if (p.uid == uid) {
            return UserEntity(
              uid: p.uid,
              name: p.name,
              email: p.email,
              role: p.role,
              locationLat: _tempLat,
              locationLng: _tempLng,
            );
          }
          return p;
        }).toList();
      });
    }

    setState(() {
      _isSelectingLocation = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(ref, 'location_updated')),
          backgroundColor: AppTheme.secondaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final locale = ref.watch(localeStateProvider);
    final providersAsync = ref.watch(providersStreamProvider);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  tr(ref, 'bookings_signin'),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isProvider = currentUser.role == 'provider';
    final List<UserEntity> allProviders = providersAsync.value ?? [];

    final servicesStream = ref.watch(servicesStreamProvider);
    final mockServices = ref.watch(mockServicesProvider);
    final List<ServiceEntity> servicesList = widget.isSupabaseConfigured
        ? (servicesStream.value ?? [])
        : mockServices;

    // Filter providers by selected category filter
    final filteredProviders = allProviders.where((p) {
      if (_selectedCategoryFilter == 'all') return true;
      
      // Look up active category matching selected key
      final activeCategory = AppLocalizations.categories.firstWhere(
        (cat) => cat.key == _selectedCategoryFilter,
        orElse: () => AppLocalizations.categories[0],
      );

      final hasServiceInActiveCat = servicesList.any((service) =>
          service.providerId == p.uid &&
          activeCategory.subcategories.any((sub) => sub.key == service.category));

      if (hasServiceInActiveCat) return true;

      // Fallback matching using provider name or service descriptions for robust demo filtering
      final lowerName = p.name.toLowerCase();
      if (_selectedCategoryFilter == 'agricultural_labor') {
        return lowerName.contains('coconut') || lowerName.contains('pol') || lowerName.contains('tea') || lowerName.contains('gammiris') || lowerName.contains('pepper');
      } else if (_selectedCategoryFilter == 'home_maintenance') {
        return lowerName.contains('plumber') || lowerName.contains('silva') || lowerName.contains('electr') || lowerName.contains('ac ') || lowerName.contains('repair') || lowerName.contains('paint') || lowerName.contains('weld');
      } else if (_selectedCategoryFilter == 'gardening_outdoor') {
        return lowerName.contains('lawn') || lowerName.contains('garden') || lowerName.contains('gas') || lowerName.contains('tree') || lowerName.contains('well');
      }
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(tr(ref, 'nav_nearby')),
      ),
      body: isProvider
          ? _buildProviderView(currentUser)
          : _buildSeekerView(currentUser, filteredProviders, servicesList, locale),
    );
  }

  Widget _buildProviderView(UserEntity provider) {
    final double defaultLat = provider.locationLat ?? seekerDefaultLat;
    final double defaultLng = provider.locationLng ?? seekerDefaultLng;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Sharing Toggle Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _isLocationSharingActive ? Icons.wifi_tethering : Icons.portable_wifi_off,
                    color: _isLocationSharingActive ? AppTheme.secondaryColor : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(ref, 'share_location'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          _isLocationSharingActive ? 'Seekers can see you on their map.' : 'You are currently offline on maps.',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isLocationSharingActive,
                    activeColor: AppTheme.secondaryColor,
                    onChanged: (val) {
                      setState(() {
                        _isLocationSharingActive = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Map Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Base Service Location',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (!_isSelectingLocation)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isSelectingLocation = true;
                      _tempLat = defaultLat;
                      _tempLng = defaultLng;
                    });
                  },
                  icon: const Icon(Icons.edit_location_alt, size: 18),
                  label: const Text('Change'),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Custom Map Picker / Viewer
          Expanded(
            child: VirtualGridMap(
              seekerLat: _isSelectingLocation ? null : defaultLat,
              seekerLng: _isSelectingLocation ? null : defaultLng,
              isSelectingLocation: _isSelectingLocation,
              pendingLat: _tempLat,
              pendingLng: _tempLng,
              onTapMap: (lat, lng) {
                if (_isSelectingLocation) {
                  setState(() {
                    _tempLat = lat;
                    _tempLng = lng;
                  });
                }
              },
              mapHeight: double.infinity,
            ),
          ),
          const SizedBox(height: 16),

          if (_isSelectingLocation)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isSelectingLocation = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 50),
                    ),
                    child: Text(tr(ref, 'btn_cancel'), style: const TextStyle(color: AppTheme.primaryColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveProviderLocation(provider.uid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(tr(ref, 'btn_set_location')),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSeekerView(UserEntity seeker, List<UserEntity> providers, List<ServiceEntity> servicesList, String locale) {
    final double seekerLat = seeker.locationLat ?? seekerDefaultLat;
    final double seekerLng = seeker.locationLng ?? seekerDefaultLng;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter out providers without active location
    final List<UserEntity> mappedProviders = providers.where((p) => p.locationLat != null && p.locationLng != null).toList();

    return Column(
      children: [
        // Category Selector Chips
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppLocalizations.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final categoryKey = isAll ? 'all' : AppLocalizations.categories[index - 1].key;
              final label = isAll
                  ? (locale == 'si' ? 'සියල්ල' : (locale == 'ta' ? 'அனைத்தும்' : 'All'))
                  : AppLocalizations.categories[index - 1].getName(locale);
              return _buildCategoryChip(categoryKey, label);
            },
          ),
        ),

        // Live Custom Map
        Expanded(
          child: Stack(
            children: [
              VirtualGridMap(
                seekerLat: seekerLat,
                seekerLng: seekerLng,
                providers: mappedProviders,
                selectedProviderId: _selectedProviderId,
                onTapMap: (lat, lng) {
                  // Unselect or search coordinate
                },
                mapHeight: double.infinity,
              ),

              // Float GPS Simulator trigger for Seekers (Demonstration tool)
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      // Simulates GPS movement for seeker (updates coordinates)
                      final random = math.Random();
                      final double offsetLat = (random.nextDouble() - 0.5) * 0.02;
                      final double offsetLng = (random.nextDouble() - 0.5) * 0.02;
                      
                      await ref.read(authControllerProvider.notifier).updateLocation(
                            uid: seeker.uid,
                            lat: seekerDefaultLat + offsetLat,
                            lng: seekerDefaultLng + offsetLng,
                          );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('GPS Simulation: Seeker coordinates updated!'),
                            backgroundColor: AppTheme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.gps_fixed, color: AppTheme.primaryColor, size: 16),
                    label: Text(
                      tr(ref, 'simulate_gps'),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom PageView Carousel of Providers
        if (mappedProviders.isNotEmpty)
          Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 12, top: 12),
            child: PageView.builder(
              controller: _pageController,
              itemCount: mappedProviders.length,
              onPageChanged: (index) {
                final provider = mappedProviders[index];
                setState(() {
                  _selectedProviderId = provider.uid;
                });
              },
              itemBuilder: (context, index) {
                final provider = mappedProviders[index];
                final distance = _calculateDistance(
                  seekerLat,
                  seekerLng,
                  provider.locationLat!,
                  provider.locationLng!,
                );
                
                final isSelected = provider.uid == _selectedProviderId;

                return Card(
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.secondaryColor : Colors.white.withOpacity(0.05),
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.secondaryColor,
                              child: Text(
                                provider.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.9',
                                        style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${distance.toStringAsFixed(2)} ${tr(ref, 'distance_away')})',
                                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Divider(height: 1),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              servicesList.any((s) => s.providerId == provider.uid)
                                  ? AppLocalizations.translateSubcategory(
                                      servicesList.firstWhere((s) => s.providerId == provider.uid).category,
                                      locale,
                                    )
                                  : (provider.name.contains('Pol')
                                      ? (locale == 'si' ? 'පොල් කැඩීම' : 'Coconut Plucking')
                                      : provider.name.contains('Gas')
                                          ? (locale == 'si' ? 'ගස් කැපීම / ගෙවතු' : 'Tree Cutting / Gardening')
                                          : 'Service Provider'),
                              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
                            ),
                            ElevatedButton(
                              onPressed: () => _bookProvider(provider, seeker.uid),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                minimumSize: const Size(100, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: Text(tr(ref, 'btn_book_now'), style: const TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text(
              'No active service providers nearby.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String key, String label) {
    final selected = _selectedCategoryFilter == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: selected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: selected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          setState(() {
            _selectedCategoryFilter = key;
          });
        },
      ),
    );
  }
}
