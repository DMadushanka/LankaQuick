import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/presentation/providers/bookings_provider.dart';
import 'package:local_link/features/bookings/presentation/screens/bookings_demo_screen.dart';
import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';
import 'package:local_link/features/marketplace/presentation/providers/marketplace_provider.dart';

// Mock listings using structured subcategory keys
final mockServicesProvider = StateProvider<List<ServiceEntity>>((ref) => [
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
    ]);

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

    ref.read(mockServicesProvider.notifier).update((state) => [...state, newService]);
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
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: tr(ref, 'input_title'),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Category Dropdown Selector
                    DropdownButtonFormField<String>(
                      value: _sheetSelectedCategoryKey,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
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
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'select_subcategory'),
                        prefixIcon: const Icon(Icons.subdirectory_arrow_right_outlined),
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
                        prefixIcon: const Icon(Icons.attach_money),
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
                    ElevatedButton(
                      onPressed: (_sheetSelectedSubcategoryKey == null)
                          ? null
                          : () {
                              if (widget.isSupabaseConfigured) {
                                _addRealService(providerId);
                              } else {
                                _addMockService(providerId);
                              }
                            },
                      child: Text(tr(ref, 'btn_publish')),
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
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tr(ref, 'confirm_booking_title'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
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
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Price: \$${service.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(ref, 'confirm_booking_prompt'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
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
                          onPressed: () {
                            Navigator.of(context).pop();
                            _bookService(service, seekerId);
                          },
                          child: Text(tr(ref, 'btn_confirm')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(ref, 'toast_request_sent')),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    } else {
      // Mock mode: add a mock booking
      ref.read(mockBookingsProvider.notifier).update((state) {
        final newBooking = BookingEntity(
          id: 'mock_book_${DateTime.now().millisecondsSinceEpoch}',
          seekerId: seekerId,
          providerId: service.providerId,
          status: 'pending',
          timestamp: DateTime.now(),
        );
        return [...state, newBooking];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(ref, 'toast_request_sent')),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final locale = ref.watch(localeStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final servicesStream = ref.watch(servicesStreamProvider);
    final mockServices = ref.watch(mockServicesProvider);

    final List<ServiceEntity> servicesList = widget.isSupabaseConfigured
        ? (servicesStream.value ?? [])
        : mockServices;

    // Filter services list reactively by selected filter tab and search bar query
    final filteredServices = servicesList.where((service) {
      // 1. Filter by category filter bar selection
      if (_selectedCategoryFilter != 'all') {
        final belongsToActiveCategory = AppLocalizations.categories.any(
          (cat) => cat.key == _selectedCategoryFilter &&
              cat.subcategories.any((sub) => sub.key == service.category),
        );
        if (!belongsToActiveCategory) return false;
      }

      // 2. Filter by search query (match title, subcategory, or main category name)
      if (_searchQuery.isEmpty) return true;
      final localizedSub = AppLocalizations.translateSubcategory(service.category, locale).toLowerCase();
      
      // Locate main category for this service
      final parentCategory = AppLocalizations.categories.firstWhere(
        (cat) => cat.subcategories.any((sub) => sub.key == service.category),
        orElse: () => AppLocalizations.categories[0],
      );
      final localizedCat = parentCategory.getName(locale).toLowerCase();
      final titleMatch = service.title.toLowerCase().contains(_searchQuery.toLowerCase());

      return localizedSub.contains(_searchQuery.toLowerCase()) ||
          localizedCat.contains(_searchQuery.toLowerCase()) ||
          titleMatch;
    }).toList();

    final isProvider = currentUser?.role == 'provider';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(tr(ref, 'nav_marketplace')),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ChoiceChip(
                label: Text(
                  currentUser.role == 'provider'
                      ? tr(ref, 'role_provider').toUpperCase()
                      : tr(ref, 'role_seeker').toUpperCase(),
                ),
                selected: true,
                selectedColor: currentUser.role == 'provider'
                    ? AppTheme.secondaryColor.withOpacity(0.15)
                    : AppTheme.primaryColor.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: currentUser.role == 'provider'
                      ? AppTheme.secondaryColor
                      : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Category Selector Bar
          Container(
            height: 52,
            margin: const EdgeInsets.symmetric(vertical: 8),
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
                final selected = _selectedCategoryFilter == categoryKey;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(label),
                    selected: selected,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategoryFilter = categoryKey;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: tr(ref, 'search_hint'),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // 3. Listed Services List View
          Expanded(
            child: filteredServices.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty ? tr(ref, 'no_services_yet') : tr(ref, 'no_services_found'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      AppLocalizations.translateSubcategory(service.category, locale),
                                      style: const TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '\$${service.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                service.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                service.description,
                                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Provider ID: ${service.providerId.substring(0, service.providerId.length > 8 ? 8 : service.providerId.length)}...',
                                    style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, fontSize: 11),
                                  ),
                                  if (currentUser != null && !isProvider)
                                    ElevatedButton(
                                      onPressed: () => _showBookingConfirmationSheet(service, currentUser.uid),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(120, 36),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(tr(ref, 'btn_book_now'), style: const TextStyle(fontSize: 12)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: currentUser != null && isProvider
          ? FloatingActionButton.extended(
              onPressed: () => _showAddServiceSheet(currentUser.uid),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(tr(ref, 'btn_add_service'), style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
