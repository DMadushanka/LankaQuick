import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/presentation/providers/bookings_provider.dart';
import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';
import 'package:local_link/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:local_link/features/marketplace/data/mock_providers_data.dart';
import 'package:local_link/features/marketplace/presentation/widgets/provider_card_widget.dart';
import 'package:local_link/features/marketplace/presentation/screens/farmer_hub_screen.dart';

// Mock listings using structured subcategory keys
final mockServicesProvider = NotifierProvider<MockServicesNotifier, List<ServiceEntity>>(() {
  return MockServicesNotifier();
});

class MockServicesNotifier extends Notifier<List<ServiceEntity>> {
  @override
  List<ServiceEntity> build() {
    return [
      const ServiceEntity(
        id: 'service_1',
        providerId: 'mock_provider_2', // Silva Plumbers
        category: 'plumbing',
        title: 'Emergency Pipe Repair & Leak Fix',
        description: 'Professional plumbing services with fast response times. Available for emergencies.',
        price: 85.00,
      ),
      const ServiceEntity(
        id: 'service_2',
        providerId: 'mock_provider_1', // Perera Gardeners
        category: 'gardening',
        title: 'Lawn Care & Landscape Maintenance',
        description: 'Complete lawn mowing, hedge trimming, and weeding services. Keep your garden fresh.',
        price: 45.00,
      ),
      const ServiceEntity(
        id: 'service_3',
        providerId: 'mock_provider_3', // Fernando Coconut Plucker
        category: 'coconut_plucking',
        title: 'Professional Coconut Plucking',
        description: 'Experienced climber for safety-first coconut harvesting and palm tree grooming.',
        price: 25.00,
      ),
      const ServiceEntity(
        id: 'service_4',
        providerId: 'mock_provider_4', // Kumara Electrics
        category: 'electrical',
        title: 'House Wiring & Fan Installations',
        description: 'Complete home electrical repairs, socket replacements, and lighting installations.',
        price: 50.00,
      ),
      const ServiceEntity(
        id: 'service_5',
        providerId: 'mock_provider_5', // Suresh CCTV
        category: 'cctv_networking',
        title: 'CCTV Camera Setup & Home Networking',
        description: 'Install HD security cameras, network router configuration, WiFi extension setups.',
        price: 75.00,
      ),
    ];
  }

  void addService(ServiceEntity service) {
    state = [...state, service];
  }
}

class MarketplaceDemoScreen extends ConsumerStatefulWidget {
  final bool isSupabaseConfigured;

  const MarketplaceDemoScreen({
    super.key,
    required this.isSupabaseConfigured,
  });

  @override
  ConsumerState<MarketplaceDemoScreen> createState() => _MarketplaceDemoScreenState();
}

class _MarketplaceDemoScreenState extends ConsumerState<MarketplaceDemoScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategoryFilter = 'all'; // Gated category filter

  // Active inputs during service creation
  String? _sheetSelectedCategoryKey;
  String? _sheetSelectedSubcategoryKey;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addMockService(String providerId) {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (title.isEmpty || _sheetSelectedSubcategoryKey == null) return;

    final newService = ServiceEntity(
      id: 'mock_service_${DateTime.now().millisecondsSinceEpoch}',
      providerId: providerId,
      category: _sheetSelectedSubcategoryKey!,
      title: title,
      description: desc,
      price: price,
    );

    ref.read(mockServicesProvider.notifier).addService(newService);
    _clearInputs();
    Navigator.of(context).pop();
  }

  void _addRealService(String providerId) async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (title.isEmpty || _sheetSelectedSubcategoryKey == null) return;

    await ref.read(marketplaceControllerProvider.notifier).addService(
          providerId: providerId,
          category: _sheetSelectedSubcategoryKey!,
          title: title,
          description: desc,
          price: price,
        );
    _clearInputs();
    Navigator.of(context).pop();
  }

  void _clearInputs() {
    _titleController.clear();
    _descController.clear();
    _priceController.clear();
    setState(() {
      _sheetSelectedCategoryKey = null;
      _sheetSelectedSubcategoryKey = null;
    });
  }

  void _showAddServiceSheet(String providerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final locale = ref.read(localeStateProvider);
            final isDark = Theme.of(context).brightness == Brightness.dark;

            // Filter subcategories list dynamically based on chosen category
            final activeCategory = AppLocalizations.categories.firstWhere(
              (cat) => cat.key == _sheetSelectedCategoryKey,
              orElse: () => AppLocalizations.categories[0],
            );

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr(ref, 'sheet_add_title'),
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, fontFamily: 'Outfit'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: tr(ref, 'input_title'),
                        prefixIcon: const Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Category Dropdown Selector
                    DropdownButtonFormField<String>(
                      value: _sheetSelectedCategoryKey,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'select_category'),
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: AppLocalizations.categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.key,
                          child: Text(
                            cat.getName(locale),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() {
                          _sheetSelectedCategoryKey = val;
                          _sheetSelectedSubcategoryKey = null; // Reset subcategory selection
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subcategory Dropdown Selector
                    DropdownButtonFormField<String>(
                      value: _sheetSelectedSubcategoryKey,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'select_subcategory'),
                        prefixIcon: const Icon(Icons.subdirectory_arrow_right_rounded),
                      ),
                      disabledHint: Text(tr(ref, 'select_category')),
                      items: _sheetSelectedCategoryKey == null
                          ? null
                          : activeCategory.subcategories.map((sub) {
                              return DropdownMenuItem<String>(
                                value: sub.key,
                                child: Text(
                                  sub.getName(locale),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                      onChanged: _sheetSelectedCategoryKey == null
                          ? null
                          : (val) {
                              setSheetState(() {
                                _sheetSelectedSubcategoryKey = val;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: tr(ref, 'input_price'),
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'input_desc'),
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        gradient: _sheetSelectedSubcategoryKey == null ? null : AppTheme.primaryGradient,
                        color: _sheetSelectedSubcategoryKey == null ? Colors.grey.withOpacity(0.12) : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: (_sheetSelectedSubcategoryKey == null)
                            ? null
                            : () {
                                if (widget.isSupabaseConfigured) {
                                  _addRealService(providerId);
                                } else {
                                  _addMockService(providerId);
                                }
                              },
                        style: AppTheme.premiumButtonStyle(),
                        child: Text(
                          tr(ref, 'btn_publish'),
                          style: TextStyle(
                            color: _sheetSelectedSubcategoryKey == null ? Colors.grey : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingConfirmationSheet(ServiceEntity service, String seekerId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final locale = ref.read(localeStateProvider);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 28.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tr(ref, 'confirm_booking_title'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Outfit'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: AppTheme.glassDecoration(isDark: isDark, opacity: 0.35, borderRadius: 16),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${tr(ref, 'select_subcategory')}: ${AppLocalizations.translateSubcategory(service.category, locale)}',
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Price: \$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(ref, 'confirm_booking_prompt'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size(0, 52),
                          ),
                          child: Text(
                            tr(ref, 'btn_cancel'),
                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              _bookService(service, seekerId);
                            },
                            style: AppTheme.premiumButtonStyle(),
                            child: Text(
                              tr(ref, 'btn_confirm'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _bookService(ServiceEntity service, String seekerId) {
    if (widget.isSupabaseConfigured) {
      ref.read(bookingsControllerProvider.notifier).requestBooking(
            seekerId: seekerId,
            providerId: service.providerId,
          );
    } else {
      // Mock mode: add a mock booking via notifier
      final newBooking = BookingEntity(
        id: 'mock_book_${DateTime.now().millisecondsSinceEpoch}',
        seekerId: seekerId,
        providerId: service.providerId,
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
            const SizedBox(width: 10),
            Expanded(child: Text(tr(ref, 'toast_request_sent'))),
          ],
        ),
        backgroundColor: AppTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final locale = ref.watch(localeStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isProvider = currentUser?.role == 'provider';

    // Filter providers reactively by selected category and search query
    final filteredProviders = figmaProviders.where((p) {
      // 1. Filter by category
      if (_selectedCategoryFilter != 'all' && p.categoryKey != _selectedCategoryFilter) {
        return false;
      }
      // 2. Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = p.name.toLowerCase().contains(query);
        final catMatch = p.category.toLowerCase().contains(query);
        if (!nameMatch && !catMatch) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Gradient Block
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [AppTheme.darkHeaderStart, AppTheme.darkHeaderEnd]
                      : [AppTheme.lightHeaderStart, AppTheme.lightHeaderEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location and Profile Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppTheme.primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Gampaha, Western Province",
                                style: TextStyle(
                                  color: isDark ? AppTheme.darkTextSecondary.withOpacity(0.6) : AppTheme.lightTextSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                                letterSpacing: -0.8,
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              ),
                              children: const [
                                TextSpan(text: "Find Local "),
                                TextSpan(
                                  text: "Experts",
                                  style: TextStyle(color: AppTheme.primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Profile Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4DF97316),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "A",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Search Bar and Filter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search services or providers...",
                              hintStyle: TextStyle(
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            "Filter",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats Row (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    isDark: isDark,
                    value: "148",
                    label: "Providers Nearby",
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    isDark: isDark,
                    value: "12 min",
                    label: "Avg Response",
                    color: const Color(0xFFA78BFA),
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    isDark: isDark,
                    value: "4.8 ★",
                    label: "Avg Rating",
                    color: const Color(0xFF34D399),
                  ),
                ],
              ),
            ),
            
            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryFilter = 'all';
                      });
                    },
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Category Chips List (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: figmaCategories.map((cat) {
                  final bool isActive = _selectedCategoryFilter == cat.id;
                  final Color catColor = cat.color;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        if (cat.id == 'farmers_market') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FarmerHubScreen(),
                            ),
                          );
                        } else {
                          setState(() {
                            _selectedCategoryFilter = isActive ? 'all' : cat.id;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? catColor.withOpacity(0.09) 
                              : (isDark ? AppTheme.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive 
                                ? catColor.withOpacity(0.4) 
                                : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                          ),
                          boxShadow: !isActive && !isDark 
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cat.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isActive ? catColor : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cat.sinhala,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Nearby Providers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Nearby Providers",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryFilter = 'all';
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Providers List (Vertical Cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: filteredProviders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 40,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No providers found in this category",
                              style: TextStyle(
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: filteredProviders.map((p) {
                        return ProviderCardWidget(provider: p);
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: currentUser != null && isProvider
          ? FloatingActionButton.extended(
              onPressed: () => _showAddServiceSheet(currentUser.uid),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(tr(ref, 'btn_add_service'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: !isDark 
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'Outfit',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
