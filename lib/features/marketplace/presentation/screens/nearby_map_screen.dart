import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/core/theme/app_background.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/presentation/providers/bookings_provider.dart';
import 'package:local_link/features/marketplace/presentation/widgets/virtual_grid_map.dart';
import 'package:local_link/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:local_link/features/marketplace/presentation/screens/marketplace_demo_screen.dart';
import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';
import 'package:local_link/features/marketplace/data/mock_providers_data.dart';
import 'package:local_link/features/marketplace/presentation/widgets/provider_card_widget.dart';

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

  // Seeker's default GPS coordinate (Gampaha)
  final double seekerDefaultLat = 7.0897;
  final double seekerDefaultLng = 79.9925;

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
      // Mock mode: add a mock booking via notifier
      final newBooking = BookingEntity(
        id: 'mock_book_${DateTime.now().millisecondsSinceEpoch}',
        seekerId: seekerId,
        providerId: provider.uid,
        status: 'pending',
        timestamp: DateTime.now(),
      );
      ref.read(mockBookingsProvider.notifier).addBooking(newBooking);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
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
      return AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded, size: 48, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Text(
                  tr(ref, 'bookings_signin'),
                  style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
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

    return AppBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              tr(ref, 'nav_nearby'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          Expanded(
            child: isProvider
                ? _buildProviderView(currentUser)
                : _buildSeekerView(currentUser, filteredProviders, servicesList, locale),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderView(UserEntity provider) {
    final double defaultLat = provider.locationLat ?? seekerDefaultLat;
    final double defaultLng = provider.locationLng ?? seekerDefaultLng;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Sharing Toggle Card
          Container(
            decoration: AppTheme.glassDecoration(isDark: isDark, opacity: 0.5),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _isLocationSharingActive ? Icons.wifi_tethering_rounded : Icons.portable_wifi_off_rounded,
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
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isLocationSharingActive ? 'Seekers can see you on their map.' : 'You are currently offline on maps.',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
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
          const SizedBox(height: 20),

          // Map Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Base Service Location',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontFamily: 'Outfit'),
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
                  icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                  label: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(0, 50),
                    ),
                    child: Text(tr(ref, 'btn_cancel'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _saveProviderLocation(provider.uid),
                      style: AppTheme.premiumButtonStyle(),
                      child: Text(tr(ref, 'btn_set_location'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
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

    // Filter providers reactively by category
    final visibleFigmaProviders = figmaProviders.where((p) {
      if (_selectedCategoryFilter == 'all') return true;
      return p.categoryKey == _selectedCategoryFilter;
    }).toList();

    final List<UserEntity> mappedProviders = visibleFigmaProviders.map((p) => UserEntity(
      uid: p.id,
      name: p.name,
      email: '${p.categoryKey}@gmail.com',
      role: 'provider',
      locationLat: p.lat,
      locationLng: p.lng,
    )).toList();

    final activeFigmaProvider = _selectedProviderId != null
        ? figmaProviders.firstWhere((p) => p.id == _selectedProviderId, orElse: () => figmaProviders[0])
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Location Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(ref, 'map_showing_providers'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr(ref, 'map_your_location'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      fontFamily: 'Outfit',
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  "${visibleFigmaProviders.length} ${tr(ref, 'map_nearby_count')}",
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filter chips bar
        Container(
          height: 38,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // All Chip
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: const Text("All", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  selected: _selectedCategoryFilter == 'all',
                  onSelected: (val) {
                    setState(() {
                      _selectedCategoryFilter = 'all';
                      _selectedProviderId = null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.12),
                  backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                  side: BorderSide(
                    color: _selectedCategoryFilter == 'all'
                        ? AppTheme.primaryColor
                        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                  labelStyle: TextStyle(
                    color: _selectedCategoryFilter == 'all'
                        ? AppTheme.primaryColor
                        : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                  ),
                ),
              ),
              // Category Specific Chips
              ...figmaCategories.take(6).map((cat) {
                final bool isActive = _selectedCategoryFilter == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(cat.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      ],
                    ),
                    selected: isActive,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategoryFilter = isActive ? 'all' : cat.id;
                        _selectedProviderId = null;
                      });
                    },
                    selectedColor: cat.color.withOpacity(0.12),
                    backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                    side: BorderSide(
                      color: isActive ? cat.color.withOpacity(0.5) : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                    labelStyle: TextStyle(
                      color: isActive ? cat.color : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Custom Map View Container
        Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                VirtualGridMap(
                  seekerLat: seekerLat,
                  seekerLng: seekerLng,
                  providers: mappedProviders,
                  selectedProviderId: _selectedProviderId,
                  onTapMap: (lat, lng) {
                    if (visibleFigmaProviders.isEmpty) return;
                    MockProvider? closest;
                    double minDistance = 999999.0;
                    for (var p in visibleFigmaProviders) {
                      final pLat = p.lat;
                      final pLng = p.lng;
                      final dist = (pLat - lat).abs() + (pLng - lng).abs();
                      if (dist < minDistance) {
                        minDistance = dist;
                        closest = p;
                      }
                    }
                    if (closest != null && minDistance < 0.005) {
                      setState(() {
                        _selectedProviderId = closest!.id;
                      });
                    } else {
                      setState(() {
                        _selectedProviderId = null;
                      });
                    }
                  },
                  mapHeight: double.infinity,
                ),
              ],
            ),
          ),
        ),

        // Detail / Nearby List Panel
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeFigmaProvider != null
                      ? "SELECTED PROVIDER"
                      : "${_selectedCategoryFilter == 'all' ? 'ALL NEARBY' : figmaCategories.firstWhere((c) => c.id == _selectedCategoryFilter).label.toUpperCase() + ' PROVIDERS'} — TAP PIN TO SELECT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: activeFigmaProvider != null
                      ? SingleChildScrollView(
                          child: ProviderCardWidget(provider: activeFigmaProvider),
                        )
                      : visibleFigmaProviders.isEmpty
                          ? Center(
                              child: Text(
                                "No providers nearby for this category",
                                style: TextStyle(
                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: visibleFigmaProviders.length > 3 ? 3 : visibleFigmaProviders.length,
                              itemBuilder: (context, index) {
                                return ProviderCardWidget(provider: visibleFigmaProviders[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
