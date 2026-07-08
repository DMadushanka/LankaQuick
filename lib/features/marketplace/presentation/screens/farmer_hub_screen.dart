import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/marketplace/presentation/providers/farmer_marketplace_provider.dart';
import 'package:local_link/features/marketplace/presentation/screens/create_post_screen.dart';
import 'package:local_link/features/marketplace/presentation/screens/product_detail_screen.dart';
import 'package:local_link/core/localization/app_localizations.dart';


class FarmerHubScreen extends ConsumerStatefulWidget {
  const FarmerHubScreen({super.key});

  @override
  ConsumerState<FarmerHubScreen> createState() => _FarmerHubScreenState();
}

class _FarmerHubScreenState extends ConsumerState<FarmerHubScreen> {
  String _hubTab = "prices"; // "prices" | "submit" | "requests"
  String _chartType = "trend"; // "trend" | "district"
  String _pepperFilter = "black"; // "all" | "black" | "white" | "green"
  GammirisDistrictPrice? _selectedDistrict;

  // Form Fields Key & Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _formDistrict = "";
  String _formPepperType = "";
  bool _formSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getTamilDistrictName(String englishName) {
    const tamilNames = {
      "Matale": "மாத்தளை",
      "Kandy": "கண்டி",
      "Kurunegala": "குருணாகல்",
      "Kegalle": "கேகாலை",
      "Ratnapura": "இரத்தினபுரி",
      "Gampaha": "கம்பஹா",
      "Colombo": "கொழும்பு",
      "Galle": "காலி",
      "Hambantota": "அம்பாந்தோட்டை",
      "Badulla": "பதுளை",
    };
    return tamilNames[englishName] ?? englishName;
  }

  String _getLocalizedDistrictName(String englishName, String locale) {
    if (locale == 'si') {
      for (var p in figmaDistrictPrices) {
        if (p.district.toLowerCase() == englishName.toLowerCase()) {
          return p.districtSinhala;
        }
      }
      return englishName;
    }
    if (locale == 'ta') {
      return _getTamilDistrictName(englishName);
    }
    return englishName;
  }

  String _getRecommendedRateText(String district, String locale) {
    final dist = _getLocalizedDistrictName(district, locale);
    if (locale == 'si') {
      return "තෝරාගත් $dist දිස්ත්‍රික්කය සඳහා නිර්දේශිත වෙළෙඳපොළ මිල: ";
    }
    if (locale == 'ta') {
      return "தேர்ந்தெடுக்கப்பட்ட $dist மாவட்டத்தில் பரிந்துரைக்கப்பட்ட சந்தை விலை: ";
    }
    return "Recommended market rate in $dist: ";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeStateProvider);

    final districtPricesAsync = ref.watch(gammirisDistrictPricesProvider);
    final weeklyTrendsAsync = ref.watch(gammirisWeeklyTrendsProvider);

    final districtPrices = districtPricesAsync.value ?? figmaDistrictPrices;
    final weeklyTrends = weeklyTrendsAsync.value ?? figmaWeeklyTrends;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: _buildGammirisHubContent(isDark, locale, districtPrices, weeklyTrends),
      ),
    );
  }

  Widget _buildGammirisHubContent(
    bool isDark,
    String locale,
    List<GammirisDistrictPrice> districtPrices,
    List<GammirisWeeklyPrice> weeklyTrends,
  ) {
    final double avgBlack = districtPrices.map((p) => p.black).reduce((a, b) => a + b) / districtPrices.length;
    final double avgWhite = districtPrices.map((p) => p.white).reduce((a, b) => a + b) / districtPrices.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Live Market Data · Updated today",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "ගම්මිරිස් ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const TextSpan(
                          text: "මිල",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Color(0xFFF59E0B),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Jul 2026",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                tr(ref, 'gammiris_pepper_price_tracker'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // KPI Strip (horizontal scrollable list)
        SizedBox(
          height: 72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildKpiCard(
                icon: "⬛",
                value: "Rs. ${avgBlack.toStringAsFixed(0)}",
                label: tr(ref, 'gammiris_avg_black'),
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                icon: "⬜",
                value: "Rs. ${avgWhite.toStringAsFixed(0)}",
                label: tr(ref, 'gammiris_avg_white'),
                color: const Color(0xFFC9B89A),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                icon: "📈",
                value: "+2.7%",
                label: tr(ref, 'gammiris_week_change'),
                color: const Color(0xFF22C55E),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                icon: "📍",
                value: "${districtPrices.length}",
                label: tr(ref, 'gammiris_districts_tracked'),
                color: const Color(0xFFA78BFA),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Main Tab Bar Switcher
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildTabButton("prices", "📊 ${tr(ref, 'gammiris_tab_prices')}", isDark),
                _buildTabButton("submit", "🌿 ${tr(ref, 'gammiris_tab_sell')}", isDark),
                _buildTabButton("requests", "📋 ${tr(ref, 'gammiris_tab_listings')}", isDark),
              ],
            ),
          ),
        ),

        // Tab Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _buildActiveTabContent(isDark, locale, districtPrices, weeklyTrends),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontFamily: 'Outfit',
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, bool isDark) {
    final active = _hubTab == tabId;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _hubTab = tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? const Color(0xFFF59E0B) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: active ? const Color(0xFFF59E0B) : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(
    bool isDark,
    String locale,
    List<GammirisDistrictPrice> districtPrices,
    List<GammirisWeeklyPrice> weeklyTrends,
  ) {
    if (_hubTab == "prices") {
      return _buildPricesTab(isDark, locale, districtPrices, weeklyTrends);
    } else if (_hubTab == "submit") {
      return _buildHarvestRequestForm(isDark, locale);
    } else {
      return _buildHarvestRequestList(isDark, locale);
    }
  }

  Widget _buildPricesTab(
    bool isDark,
    String locale,
    List<GammirisDistrictPrice> districtPrices,
    List<GammirisWeeklyPrice> weeklyTrends,
  ) {
    final chartTypes = [
      {"id": "trend", "label": "📈 ${tr(ref, 'gammiris_chart_trend')}"},
      {"id": "district", "label": "🗺️ ${tr(ref, 'gammiris_chart_district')}"},
    ];

    final pepperFilters = [
      {"id": "all", "label": tr(ref, 'gammiris_filter_all'), "color": const Color(0xFFF59E0B)},
      {"id": "black", "label": tr(ref, 'gammiris_filter_black'), "color": const Color(0xFFF59E0B)},
      {"id": "white", "label": tr(ref, 'gammiris_filter_white'), "color": const Color(0xFFC9B89A)},
      {"id": "green", "label": tr(ref, 'gammiris_filter_green'), "color": const Color(0xFF22C55E)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart Type Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkInput : const Color(0xFFE8E8F0).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: chartTypes.map((ct) {
                  final active = _chartType == ct["id"];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _chartType = ct["id"]!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFF59E0B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ct["label"]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: active ? Colors.white : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Pepper Type Horizontal Pills
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: pepperFilters.length,
              itemBuilder: (context, idx) {
                final filter = pepperFilters[idx];
                final active = _pepperFilter == filter["id"];
                final color = filter["color"] as Color;

                return GestureDetector(
                  onTap: () => setState(() => _pepperFilter = filter["id"] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: active ? color.withOpacity(0.15) : (isDark ? AppTheme.darkCard : Colors.white),
                      border: Border.all(
                        color: active ? color : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        if (filter["id"] != "all") ...[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          filter["label"] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: active ? color : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Chart Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chartType == "trend" ? tr(ref, 'gammiris_weekly_price_trend') : tr(ref, 'gammiris_table_title'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _chartType == "trend" ? tr(ref, 'gammiris_weekly_price_subtitle') : "LKR / kg",
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 14),
                _chartType == "trend"
                    ? GammirisTrendChart(
                        trendData: weeklyTrends,
                        filter: _pepperFilter,
                        isDark: isDark,
                      )
                    : GammirisBarChart(
                        districtData: districtPrices,
                        filter: _pepperFilter,
                        isDark: isDark,
                        locale: locale,
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // District Price Table
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(ref, 'gammiris_table_title'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 10),

                // Table Header Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(isDark ? 0.1 : 0.08),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          tr(ref, 'gammiris_table_district'),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tr(ref, 'gammiris_filter_black'),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tr(ref, 'gammiris_filter_white'),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tr(ref, 'gammiris_filter_green'),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          tr(ref, 'gammiris_table_trend'),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Body Rows
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: List.generate(districtPrices.length, (idx) {
                      final item = districtPrices[idx];
                      final isSelected = _selectedDistrict?.district == item.district;
                      final isEven = idx % 2 == 0;

                      final trendColor = item.trend == "up"
                          ? const Color(0xFF22C55E)
                          : (item.trend == "down" ? const Color(0xFFF87171) : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted));

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDistrict = isSelected ? null : item;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          color: isSelected
                              ? const Color(0xFFF59E0B).withOpacity(isDark ? 0.08 : 0.06)
                              : (isEven ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.015) : Colors.black.withOpacity(0.015))),
                          child: Row(
                            children: [
                              // District Label
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getLocalizedDistrictName(item.district, locale),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      locale == 'en' ? item.districtSinhala : item.district,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Black Price
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "${(item.black / 1000).toStringAsFixed(2)}k",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                                ),
                              ),
                              // White Price
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "${(item.white / 1000).toStringAsFixed(2)}k",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC9B89A)),
                                ),
                              ),
                              // Green Price
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "${(item.green / 1000).toStringAsFixed(2)}k",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                                ),
                              ),
                              // Trend indicator
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Text(
                                      item.trend == "up" ? "↑" : (item.trend == "down" ? "↓" : "→"),
                                      style: TextStyle(fontSize: 13, color: trendColor, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "${item.change > 0 ? "+" : ""}${item.change}%",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: trendColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Detail Card for Selected District
          if (_selectedDistrict != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSelectedDistrictDetailCard(isDark, locale),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDistrictDetailCard(bool isDark, String locale) {
    final d = _selectedDistrict!;
    final trendColor = d.trend == "up"
        ? const Color(0xFF22C55E)
        : (d.trend == "down" ? const Color(0xFFF87171) : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted));

    final rates = [
      {"label": tr(ref, 'gammiris_black_pepper'), "price": d.black, "color": const Color(0xFFF59E0B)},
      {"label": tr(ref, 'gammiris_white_pepper'), "price": d.white, "color": const Color(0xFFC9B89A)},
      {"label": tr(ref, 'gammiris_green_pepper'), "price": d.green, "color": const Color(0xFF22C55E)},
      {"label": tr(ref, 'gammiris_mixed_grade'), "price": d.mixed, "color": const Color(0xFFA78BFA)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedDistrictName(d.district, locale),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  Text(
                    "${locale == 'en' ? d.districtSinhala : d.district} · ${tr(ref, 'gammiris_rates_breakdown')}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      d.trend == "up" ? "↑" : (d.trend == "down" ? "↓" : "→"),
                      style: TextStyle(fontSize: 14, color: trendColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${d.change > 0 ? "+" : ""}${d.change}% ${tr(ref, 'gammiris_week_change').toLowerCase()}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.5,
            children: rates.map((rate) {
              final color = rate["color"] as Color;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.07),
                  border: Border.all(color: color.withOpacity(0.18)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          rate["label"] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Rs. ${(rate["price"] as double).toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                        fontFamily: 'Outfit',
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      "per kg",
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestRequestForm(bool isDark, String locale) {
    if (_formSubmitted) {
      return _buildSuccessScreen(isDark, locale);
    }

    final currentRate = _getCurrentMarketRate();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.12),
                    const Color(0xFFF59E0B).withOpacity(0.04),
                  ],
                ),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🌿", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(ref, 'gammiris_sell_banner_title'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr(ref, 'gammiris_sell_banner_body'),
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _buildInputField(
              label: tr(ref, 'gammiris_form_name'),
              controller: _nameController,
              placeholder: locale == 'si' ? "ඔබගේ නම" : (locale == 'ta' ? "உங்கள் பெயர்" : "Your full name"),
              validator: (v) => v == null || v.trim().isEmpty
                  ? (locale == 'si' ? "ගොවියාගේ නම අවශ්‍ය වේ" : (locale == 'ta' ? "விவசாயி பெயர் தேவை" : "Name is required"))
                  : null,
              isDark: isDark,
            ),
            _buildInputField(
              label: tr(ref, 'gammiris_form_phone'),
              controller: _phoneController,
              placeholder: "+94 77 123 4567",
              validator: (v) => v == null || v.trim().isEmpty
                  ? (locale == 'si' ? "දුරකථන අංකය අවශ්‍ය වේ" : (locale == 'ta' ? "தொடர்பு எண் தேவை" : "Phone number is required"))
                  : null,
              isDark: isDark,
            ),
            _buildInputField(
              label: tr(ref, 'gammiris_form_location'),
              controller: _locationController,
              placeholder: locale == 'si' ? "උදා. උකුවෙල, මාතලේ" : (locale == 'ta' ? "எ.கா. உகுவெல, மாத்தளை" : "e.g. Ukuwela, Matale"),
              validator: (v) => v == null || v.trim().isEmpty
                  ? (locale == 'si' ? "පිහිටීම අවශ්‍ය වේ" : (locale == 'ta' ? "இருப்பிடம் தேவை" : "Location is required"))
                  : null,
              isDark: isDark,
            ),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: tr(ref, 'gammiris_form_district'),
                    value: _formDistrict,
                    items: ["", ...figmaDistrictPrices.map((d) => d.district)],
                    itemLabels: {
                      "": locale == 'si' ? "තෝරන්න..." : (locale == 'ta' ? "தேர்வு செய்க..." : "Select..."),
                      ...Map.fromEntries(figmaDistrictPrices.map((d) => MapEntry(d.district, _getLocalizedDistrictName(d.district, locale)))),
                    },
                    onChanged: (val) => setState(() => _formDistrict = val ?? ""),
                    validator: (v) => v == null || v.isEmpty
                        ? (locale == 'si' ? "දිස්ත්‍රික්කය තෝරන්න" : (locale == 'ta' ? "மாவட்டத்தை தேர்வு செய்க" : "Select a district"))
                        : null,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    label: tr(ref, 'gammiris_form_type'),
                    value: _formPepperType,
                    items: const ["", "black", "white", "green", "mixed"],
                    itemLabels: {
                      "": locale == 'si' ? "තෝරන්න..." : (locale == 'ta' ? "தேர்வு செய்க..." : "Select..."),
                      "black": tr(ref, 'gammiris_black_pepper'),
                      "white": tr(ref, 'gammiris_white_pepper'),
                      "green": tr(ref, 'gammiris_green_pepper'),
                      "mixed": tr(ref, 'gammiris_mixed_grade'),
                    },
                    onChanged: (val) => setState(() => _formPepperType = val ?? ""),
                    validator: (v) => v == null || v.isEmpty
                        ? (locale == 'si' ? "ගම්මිරිස් වර්ගය තෝරන්න" : (locale == 'ta' ? "மிளகு வகையைத் தேர்வு செய்க" : "Select pepper type"))
                        : null,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _buildNumberInputField(
                    label: tr(ref, 'gammiris_form_qty'),
                    controller: _qtyController,
                    placeholder: "e.g. 250",
                    suffix: "kg",
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return locale == 'si' ? "ප්‍රමාණය ඇතුළත් කරන්න" : (locale == 'ta' ? "அளவை உள்ளிடவும்" : "Enter quantity");
                      }
                      final num = double.tryParse(v);
                      if (num == null || num <= 0) {
                        return locale == 'si' ? "ධන අගයක් විය යුතුය" : (locale == 'ta' ? "நேர்மறை எண் தேவை" : "Must be positive");
                      }
                      return null;
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInputField(
                    label: tr(ref, 'gammiris_form_price'),
                    controller: _priceController,
                    placeholder: "1800",
                    prefix: "Rs.",
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return locale == 'si' ? "මිල ඇතුළත් කරන්න" : (locale == 'ta' ? "விலையை உள்ளிடவும்" : "Enter price");
                      }
                      final num = double.tryParse(v);
                      if (num == null || num <= 0) {
                        return locale == 'si' ? "ධන අගයක් විය යුතුය" : (locale == 'ta' ? "நேர்மறை எண் தேவை" : "Must be positive");
                      }
                      return null;
                    },
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            if (currentRate != null) ...[
              const SizedBox(height: 4),
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.08),
                  border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text("💡", style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _getRecommendedRateText(_formDistrict, locale),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "Rs. ${currentRate.toStringAsFixed(0)}/kg",
                              style: const TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            _buildInputField(
              label: tr(ref, 'gammiris_form_notes'),
              controller: _notesController,
              placeholder: locale == 'si'
                  ? "අස්වැන්න නෙළූ දිනය, ගුණාත්මකභාවය, ගෙවීම් කැමැත්ත..."
                  : (locale == 'ta' ? "அறுவடை தேதி, தரம், கட்டண விருப்பம்..." : "Harvest date, quality grade, payment preference..."),
              maxLines: 3,
              isDark: isDark,
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _submitHarvestForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🌿", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    tr(ref, 'gammiris_btn_submit'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Outfit',
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr(ref, 'gammiris_free_to_list'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    String? sinhala,
    required TextEditingController controller,
    required String placeholder,
    String? Function(String?)? validator,
    int maxLines = 1,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
              ),
              if (sinhala != null) ...[
                const SizedBox(width: 6),
                Text(
                  sinhala,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              fillColor: isDark ? AppTheme.darkInput : const Color(0xFFF5F5F7),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF59E0B)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    String? sinhala,
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
              ),
              if (sinhala != null) ...[
                const SizedBox(width: 6),
                Text(
                  sinhala,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            validator: validator,
            dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              fillColor: isDark ? AppTheme.darkInput : const Color(0xFFF5F5F7),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF59E0B)),
              ),
            ),
            items: items.map((val) {
              final labelText = itemLabels != null ? (itemLabels[val] ?? val) : (val.isEmpty ? "Select..." : val);
              return DropdownMenuItem<String>(
                value: val.isEmpty ? null : val,
                child: Text(labelText),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputField({
    required String label,
    String? sinhala,
    required TextEditingController controller,
    required String placeholder,
    String? prefix,
    String? suffix,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
              ),
              if (sinhala != null) ...[
                const SizedBox(width: 6),
                Text(
                  sinhala,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            validator: validator,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
              prefixText: prefix,
              prefixStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              fillColor: isDark ? AppTheme.darkInput : const Color(0xFFF5F5F7),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF59E0B)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _getCurrentMarketRate() {
    if (_formDistrict.isEmpty || _formPepperType.isEmpty) return null;
    final districtPrices = ref.read(gammirisDistrictPricesProvider).value ?? figmaDistrictPrices;
    final d = districtPrices.firstWhere(
      (x) => x.district == _formDistrict,
      orElse: () => const GammirisDistrictPrice(
        district: "",
        districtSinhala: "",
        black: 0,
        white: 0,
        green: 0,
        mixed: 0,
        trend: "",
        change: 0,
      ),
    );
    if (d.district.isEmpty) return null;
    if (_formPepperType == "black") return d.black;
    if (_formPepperType == "white") return d.white;
    if (_formPepperType == "green") return d.green;
    if (_formPepperType == "mixed") return d.mixed;
    return null;
  }

  void _submitHarvestForm() {
    if (_formKey.currentState!.validate()) {
      final double qty = double.tryParse(_qtyController.text) ?? 0.0;
      final double price = double.tryParse(_priceController.text) ?? 0.0;

      final newReq = GammirisHarvestRequest(
        id: "r_${Random().nextInt(1000000)}",
        farmerName: _nameController.text.trim(),
        location: _locationController.text.trim(),
        district: _formDistrict,
        pepperType: _formPepperType,
        quantityKg: qty,
        pricePerKg: price,
        phone: _phoneController.text.trim(),
        submittedAt: "Just now",
        status: "pending",
        avatarColor: 0xFF34D399,
      );

      ref.read(gammirisListingsProvider.notifier).addRequest(newReq);

      setState(() {
        _formSubmitted = true;
      });
    }
  }

  Widget _buildSuccessScreen(bool isDark, String locale) {
    String typeLabel = _formPepperType;
    if (_formPepperType == "black") typeLabel = tr(ref, 'gammiris_black_pepper');
    if (_formPepperType == "white") typeLabel = tr(ref, 'gammiris_white_pepper');
    if (_formPepperType == "green") typeLabel = tr(ref, 'gammiris_green_pepper');
    if (_formPepperType == "mixed") typeLabel = tr(ref, 'gammiris_mixed_grade');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Text("🌿", style: TextStyle(fontSize: 56))),
          const SizedBox(height: 16),
          Center(
            child: Text(
              tr(ref, 'gammiris_dialog_success_title'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              locale == 'si'
                  ? "ඔබගේ ගම්මිරිස් අස්වනු ලැයිස්තුගත කිරීම සාර්ථකව ඉදිරිපත් කරන ලදී. ගැනුම්කරුවන් ${_phoneController.text} ඔස්සේ පැය 24ක් ඇතුළත ඔබව සම්බන්ධ කරගනු ඇත."
                  : (locale == 'ta'
                      ? "உங்கள் மிளகு அறுவடை விளம்பரம் சமர்ப்பிக்கப்பட்டது. வாங்குபவர்கள் ${_phoneController.text} மூலம் 24 மணி நேரத்திற்குள் உங்களைத் தொடர்பு கொள்வார்கள்."
                      : "Your harvest listing has been submitted. Buyers will contact you at ${_phoneController.text} within 24 hours."),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.08),
              border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildRecapRow(tr(ref, 'gammiris_recap_farmer'), _nameController.text, isDark),
                _buildRecapRow(tr(ref, 'gammiris_recap_district'), _getLocalizedDistrictName(_formDistrict, locale), isDark),
                _buildRecapRow(tr(ref, 'gammiris_recap_type'), typeLabel, isDark),
                _buildRecapRow(tr(ref, 'gammiris_recap_qty'), "${_qtyController.text} kg", isDark),
                _buildRecapRow(tr(ref, 'gammiris_recap_price'), "Rs. ${_priceController.text}/kg", isDark, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _formSubmitted = false;
                _nameController.clear();
                _phoneController.clear();
                _locationController.clear();
                _qtyController.clear();
                _priceController.clear();
                _notesController.clear();
                _formDistrict = "";
                _formPepperType = "";
                _hubTab = "requests";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              tr(ref, 'gammiris_btn_view_all_listings'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapRow(String label, String value, bool isDark, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestRequestList(bool isDark, String locale) {
    final listings = ref.watch(gammirisListingsProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr(ref, 'gammiris_active_listings').toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
          const SizedBox(height: 10),

          listings.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Text(
                    tr(ref, 'gammiris_no_listings'),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listings.length,
                  itemBuilder: (context, idx) {
                    final item = listings[idx];
                    return _buildListingCard(item, isDark, locale);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildListingCard(GammirisHarvestRequest item, bool isDark, String locale) {
    final initial = item.farmerName.isNotEmpty ? item.farmerName[0] : "?";
    String typeLabel = item.pepperType;
    if (item.pepperType == "black") typeLabel = tr(ref, 'gammiris_black_pepper');
    if (item.pepperType == "white") typeLabel = tr(ref, 'gammiris_white_pepper');
    if (item.pepperType == "green") typeLabel = tr(ref, 'gammiris_green_pepper');
    if (item.pepperType == "mixed") typeLabel = tr(ref, 'gammiris_mixed_grade');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(item.avatarColor).withOpacity(0.12),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Color(item.avatarColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.farmerName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${item.location} · ${item.submittedAt}",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.status == "pending"
                      ? const Color(0xFFF59E0B).withOpacity(0.12)
                      : const Color(0xFF22C55E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status == "pending" ? tr(ref, 'gammiris_status_pending') : tr(ref, 'gammiris_status_contacted'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: item.status == "pending" ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkInput : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'gammiris_quantity'),
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${item.quantityKg.toStringAsFixed(0)} kg",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'gammiris_asking_price'),
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Rs. ${item.pricePerKg.toStringAsFixed(0)}/kg",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'gammiris_form_type'),
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.pepperType == "black"
                            ? const Color(0xFFF59E0B)
                            : (item.pepperType == "white" ? const Color(0xFFC9B89A) : const Color(0xFF22C55E)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(locale == 'si'
                            ? "${item.farmerName} ගොවි මහතා ඇමතීම ${item.phone}..."
                            : (locale == 'ta'
                                ? "${item.farmerName} இற்கு அழைப்பு மேற்கொள்ளப்படுகிறது ${item.phone}..."
                                : "Calling ${item.farmerName} at ${item.phone}...")),
                        backgroundColor: const Color(0xFFF59E0B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 14, color: isDark ? Colors.white70 : AppTheme.lightTextPrimary),
                      const SizedBox(width: 6),
                      Text(
                        locale == 'si' ? "අමතන්න" : (locale == 'ta' ? "அழை" : "Call"),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(locale == 'si'
                            ? "SMS/WhatsApp පණිවිඩය ${item.farmerName} වෙත සූදානම් කෙරේ..."
                            : (locale == 'ta'
                                ? "SMS/WhatsApp செய்தி ${item.farmerName} இற்கு தயார் செய்யப்படுகிறது..."
                                : "SMS/WhatsApp context shared with ${item.farmerName}...")),
                        backgroundColor: const Color(0xFF22C55E),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        locale == 'si' ? "මිලක් ඉදිරිපත් කරන්න" : (locale == 'ta' ? "விலை வழங்குக" : "Offer Bid"),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// --- CUSTOM GRAPH DRAWING PAINTERS FOR FIGMA CHART ALIGNMENT ---

class GammirisTrendChart extends StatefulWidget {
  final List<GammirisWeeklyPrice> trendData;
  final String filter;
  final bool isDark;

  const GammirisTrendChart({
    super.key,
    required this.trendData,
    required this.filter,
    required this.isDark,
  });

  @override
  State<GammirisTrendChart> createState() => _GammirisTrendChartState();
}

class _GammirisTrendChartState extends State<GammirisTrendChart> {
  int? _hoveredIndex;

  void _updateHoverIndex(double dx, double drawWidth) {
    if (drawWidth <= 0) return;
    const double leftPadding = 35;
    final double relativeX = dx - leftPadding;
    final int dataCount = widget.trendData.length;
    int idx = (relativeX / drawWidth * (dataCount - 1)).round();
    idx = idx.clamp(0, dataCount - 1);
    if (_hoveredIndex != idx) {
      setState(() {
        _hoveredIndex = idx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double leftPadding = 35;
    const double rightPadding = 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double drawWidth = width - leftPadding - rightPadding;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onPanStart: (details) => _updateHoverIndex(details.localPosition.dx, drawWidth),
              onPanUpdate: (details) => _updateHoverIndex(details.localPosition.dx, drawWidth),
              onTapDown: (details) => _updateHoverIndex(details.localPosition.dx, drawWidth),
              onPanEnd: (_) => setState(() => _hoveredIndex = null),
              onTapUp: (_) => setState(() => _hoveredIndex = null),
              onPanCancel: () => setState(() => _hoveredIndex = null),
              child: CustomPaint(
                size: Size(width, 200),
                painter: GammirisTrendPainter(widget.trendData, widget.filter, widget.isDark, _hoveredIndex),
              ),
            ),
            if (_hoveredIndex != null) () {
              final weekData = widget.trendData[_hoveredIndex!];
              final double xPos = leftPadding + drawWidth * (_hoveredIndex! / (widget.trendData.length - 1));
              const double tooltipWidth = 110;
              final double tooltipX = (xPos - tooltipWidth / 2).clamp(leftPadding, width - rightPadding - tooltipWidth);

              return Positioned(
                top: 15,
                left: tooltipX,
                child: Container(
                  width: tooltipWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppTheme.darkCard : Colors.white,
                    border: Border.all(color: widget.isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weekData.week,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? Colors.white70 : AppTheme.lightTextPrimary,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.filter == "black" || widget.filter == "all")
                        _buildTooltipRow("Black", weekData.black, const Color(0xFFF59E0B)),
                      if (widget.filter == "white" || widget.filter == "all")
                        _buildTooltipRow("White", weekData.white, const Color(0xFFC9B89A)),
                      if (widget.filter == "green" || widget.filter == "all")
                        _buildTooltipRow("Green", weekData.green, const Color(0xFF22C55E)),
                    ],
                  ),
                ),
              );
            }(),
          ],
        );
      },
    );
  }

  Widget _buildTooltipRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 8.5, color: Colors.grey),
          ),
          Text(
            "${(value / 1000).toStringAsFixed(2)}k",
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class GammirisTrendPainter extends CustomPainter {
  final List<GammirisWeeklyPrice> data;
  final String filter;
  final bool isDark;
  final int? hoveredIndex;

  GammirisTrendPainter(this.data, this.filter, this.isDark, this.hoveredIndex);

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 35;
    const double rightPadding = 10;
    const double topPadding = 10;
    const double bottomPadding = 25;

    final double drawWidth = size.width - leftPadding - rightPadding;
    final double drawHeight = size.height - topPadding - bottomPadding;

    const double minY = 500;
    const double maxY = 2800;

    final paintGrid = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
      fontSize: 9,
      fontFamily: 'Outfit',
    );

    // 1. Draw horizontal grid lines and Y-axis labels
    const int gridLinesCount = 5;
    for (int i = 0; i < gridLinesCount; i++) {
      final double ratio = i / (gridLinesCount - 1);
      final double y = topPadding + drawHeight * (1 - ratio);
      final double val = minY + (maxY - minY) * ratio;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        paintGrid,
      );

      final textSpan = TextSpan(
        text: "${(val / 1000).toStringAsFixed(1)}k",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // 2. Draw X-axis labels
    final int dataCount = data.length;
    for (int i = 0; i < dataCount; i++) {
      final double ratio = i / (dataCount - 1);
      final double x = leftPadding + drawWidth * ratio;

      final textSpan = TextSpan(
        text: data[i].week,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPadding + 6),
      );
    }

    Offset getCoord(int index, double price) {
      final double xRatio = index / (dataCount - 1);
      final double yRatio = (price - minY) / (maxY - minY);
      final double x = leftPadding + drawWidth * xRatio;
      final double y = topPadding + drawHeight * (1 - yRatio);
      return Offset(x, y);
    }

    // Draw hovered index vertical dashed cursor line
    if (hoveredIndex != null) {
      final double xCursor = leftPadding + drawWidth * (hoveredIndex! / (dataCount - 1));
      final cursorPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.15)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      double startY = topPadding;
      while (startY < topPadding + drawHeight) {
        canvas.drawLine(Offset(xCursor, startY), Offset(xCursor, startY + 4), cursorPaint);
        startY += 8;
      }
    }

    // 3. Draw lines & areas
    final List<String> typesToDraw = [];
    if (filter == "all") {
      typesToDraw.addAll(["black", "white", "green"]);
    } else {
      typesToDraw.add(filter);
    }

    for (final type in typesToDraw) {
      final List<Offset> points = [];
      Color color;
      if (type == "black") {
        color = const Color(0xFFF59E0B);
        for (int i = 0; i < dataCount; i++) {
          points.add(getCoord(i, data[i].black));
        }
      } else if (type == "white") {
        color = const Color(0xFFC9B89A);
        for (int i = 0; i < dataCount; i++) {
          points.add(getCoord(i, data[i].white));
        }
      } else {
        color = const Color(0xFF22C55E);
        for (int i = 0; i < dataCount; i++) {
          points.add(getCoord(i, data[i].green));
        }
      }

      if (points.isEmpty) continue;

      // Area fill path
      final Path fillPath = Path()
        ..moveTo(points[0].dx, topPadding + drawHeight);
      for (final pt in points) {
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(points.last.dx, topPadding + drawHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(leftPadding, topPadding, drawWidth, drawHeight))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // Line path (smoothed bezier curve)
      final Path linePath = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        final p0 = points[i - 1];
        final p1 = points[i];
        final controlX = (p0.dx + p1.dx) / 2;
        linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linePath, linePaint);

      // Point dots
      for (int i = 0; i < points.length; i++) {
        final pt = points[i];
        final bool isHovered = (hoveredIndex == i);
        final double radius = isHovered ? 6.0 : 4.0;
        final double innerRadius = isHovered ? 3.5 : 2.0;

        final dotPaintFill = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final dotPaintBorder = Paint()
          ..color = isDark ? const Color(0xFF1E293B) : Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(pt, radius, dotPaintBorder);
        canvas.drawCircle(pt, innerRadius, dotPaintFill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GammirisTrendPainter oldDelegate) =>
      oldDelegate.filter != filter || oldDelegate.isDark != isDark || oldDelegate.hoveredIndex != hoveredIndex;
}

class GammirisBarChart extends StatefulWidget {
  final List<GammirisDistrictPrice> districtData;
  final String filter;
  final bool isDark;
  final String locale;

  const GammirisBarChart({
    super.key,
    required this.districtData,
    required this.filter,
    required this.isDark,
    required this.locale,
  });

  @override
  State<GammirisBarChart> createState() => _GammirisBarChartState();
}

class _GammirisBarChartState extends State<GammirisBarChart> {
  int? _hoveredIndex;

  void _updateHoverIndex(double dx, double drawWidth) {
    if (drawWidth <= 0) return;
    const double leftPadding = 35;
    final double relativeX = dx - leftPadding;
    final int dataCount = widget.districtData.length;
    final double colWidth = drawWidth / dataCount;
    int idx = (relativeX / colWidth).floor();
    idx = idx.clamp(0, dataCount - 1);
    if (_hoveredIndex != idx) {
      setState(() {
        _hoveredIndex = idx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double leftPadding = 35;
    const double rightPadding = 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double drawWidth = width - leftPadding - rightPadding;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onPanStart: (details) => _updateHoverIndex(details.localPosition.dx, drawWidth),
              onPanUpdate: (details) => _updateHoverIndex(details.localPosition.dx, drawWidth),
              onTapDown: (details) => _updateHoverIndex(details.localPosition.dx, drawWidth),
              onPanEnd: (_) => setState(() => _hoveredIndex = null),
              onTapUp: (_) => setState(() => _hoveredIndex = null),
              onPanCancel: () => setState(() => _hoveredIndex = null),
              child: CustomPaint(
                size: Size(width, 220), // Slightly taller to account for rotated bottom labels!
                painter: GammirisBarPainter(widget.districtData, widget.filter, widget.isDark, _hoveredIndex, widget.locale),
              ),
            ),
            if (_hoveredIndex != null) () {
              final d = widget.districtData[_hoveredIndex!];
              final double colWidth = drawWidth / widget.districtData.length;
              final double xPos = leftPadding + (colWidth * _hoveredIndex!) + (colWidth / 2);
              const double tooltipWidth = 110;
              final double tooltipX = (xPos - tooltipWidth / 2).clamp(leftPadding, width - rightPadding - tooltipWidth);

              return Positioned(
                top: 15,
                left: tooltipX,
                child: Container(
                  width: tooltipWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppTheme.darkCard : Colors.white,
                    border: Border.all(color: widget.isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d.district,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? Colors.white70 : AppTheme.lightTextPrimary,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.filter == "black" || widget.filter == "all")
                        _buildTooltipRow("Black", d.black, const Color(0xFFF59E0B)),
                      if (widget.filter == "white" || widget.filter == "all")
                        _buildTooltipRow("White", d.white, const Color(0xFFC9B89A)),
                      if (widget.filter == "green" || widget.filter == "all")
                        _buildTooltipRow("Green", d.green, const Color(0xFF22C55E)),
                    ],
                  ),
                ),
              );
            }(),
          ],
        );
      },
    );
  }

  Widget _buildTooltipRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 8.5, color: Colors.grey),
          ),
          Text(
            "${(value / 1000).toStringAsFixed(2)}k",
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class GammirisBarPainter extends CustomPainter {
  final List<GammirisDistrictPrice> data;
  final String filter;
  final bool isDark;
  final int? hoveredIndex;
  final String locale;

  GammirisBarPainter(this.data, this.filter, this.isDark, this.hoveredIndex, this.locale);

  String _getLocalizedName(String englishName) {
    if (locale == 'si') {
      for (var p in data) {
        if (p.district.toLowerCase() == englishName.toLowerCase()) {
          return p.districtSinhala;
        }
      }
    }
    if (locale == 'ta') {
      const tamilNames = {
        "Matale": "மாத்தளை",
        "Kandy": "கண்டி",
        "Kurunegala": "குருணாகல்",
        "Kegalle": "கேகாலை",
        "Ratnapura": "இரத்தினபுரி",
        "Gampaha": "கம்பஹா",
        "Colombo": "கொழும்பு",
        "Galle": "காலி",
        "Hambantota": "அம்பாந்தோட்டை",
        "Badulla": "பதுளை",
      };
      return tamilNames[englishName] ?? englishName;
    }
    return englishName;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 45; // Increased to provide space for rotated district labels
    const double rightPadding = 30; // Increased to provide space for rotated district labels
    const double topPadding = 10;
    const double bottomPadding = 60; // Increased to accommodate full district names
    

    final double drawWidth = size.width - leftPadding - rightPadding;
    final double drawHeight = size.height - topPadding - bottomPadding;

    const double minY = 0;
    const double maxY = 2800;

    final paintGrid = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
      fontSize: 8.5, // Slightly smaller font for premium look
      fontWeight: FontWeight.w600,
      fontFamily: 'Outfit',
    );

    // 1. Draw horizontal grid lines and Y-axis labels
    const int gridLinesCount = 5;
    for (int i = 0; i < gridLinesCount; i++) {
      final double ratio = i / (gridLinesCount - 1);
      final double y = topPadding + drawHeight * (1 - ratio);
      final double val = minY + (maxY - minY) * ratio;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        paintGrid,
      );

      final textSpan = TextSpan(
        text: "${(val / 1000).toStringAsFixed(1)}k",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    final int dataCount = data.length;
    final double colWidth = drawWidth / dataCount;

    // 2. Draw bottom labels for districts (complete name, rotated diagonally)
    for (int i = 0; i < dataCount; i++) {
      final double x = leftPadding + (i * colWidth) + (colWidth / 2);
      final label = _getLocalizedName(data[i].district);

      final textSpan = TextSpan(
        text: label,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, size.height - bottomPadding + 6);
      canvas.rotate(0.55); // Rotated diagonally by 31.5 degrees

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );   canvas.restore();
    }

    // Draw background hover band
    if (hoveredIndex != null) {
      final double hoverStartX = leftPadding + (hoveredIndex! * colWidth);
      final hoverRect = Rect.fromLTWH(hoverStartX, topPadding, colWidth, drawHeight);
      final hoverPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.04)
        ..style = PaintingStyle.fill;
      canvas.drawRect(hoverRect, hoverPaint);
    }

    // 3. Draw bars
    final double barWidth = filter == "all" ? 4.0 : 8.0;
    const double gapBetweenBars = 2.0;

    for (int i = 0; i < dataCount; i++) {
      final item = data[i];
      final double centerX = leftPadding + (i * colWidth) + (colWidth / 2);

      final List<MapEntry<Color, double>> barsToDraw = [];
      if (filter == "black" || filter == "all") {
        barsToDraw.add(MapEntry(const Color(0xFFF59E0B), item.black));
      }
      if (filter == "white" || filter == "all") {
        barsToDraw.add(MapEntry(const Color(0xFFC9B89A), item.white));
      }
      if (filter == "green" || filter == "all") {
        barsToDraw.add(MapEntry(const Color(0xFF22C55E), item.green));
      }

      final double totalBarsWidth = (barsToDraw.length * barWidth) + ((barsToDraw.length - 1) * gapBetweenBars);
      double startX = centerX - (totalBarsWidth / 2);

      for (final bar in barsToDraw) {
        final double barHeightVal = bar.value;
        final double yRatio = barHeightVal / (maxY - minY);
        final double y = topPadding + drawHeight * (1 - yRatio);
        final double bottomY = topPadding + drawHeight;

        final rect = RRect.fromRectAndCorners(
          Rect.fromLTRB(startX, y, startX + barWidth, bottomY),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        );

        final paintBar = Paint()
          ..color = bar.key
          ..style = PaintingStyle.fill;

        canvas.drawRRect(rect, paintBar);
        startX += barWidth + gapBetweenBars;
      }
    }
  }

  @override
  bool shouldRepaint(covariant GammirisBarPainter oldDelegate) =>
      oldDelegate.filter != filter || oldDelegate.isDark != isDark || oldDelegate.hoveredIndex != hoveredIndex;
}


// Inner Content wrapper for Tab 0 of FarmerHubScreen
class FarmerMarketplaceContent extends ConsumerStatefulWidget {
  const FarmerMarketplaceContent({super.key});

  @override
  ConsumerState<FarmerMarketplaceContent> createState() => _FarmerMarketplaceContentState();
}

class _FarmerMarketplaceContentState extends ConsumerState<FarmerMarketplaceContent> {
  String _selectedCategory = "All";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final posts = ref.watch(farmerPostsProvider);

    final filteredPosts = posts.where((post) {
      final matchesCategory = _selectedCategory == "All" || post.category == _selectedCategory;
      final matchesSearch = post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.farmerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final featuredPosts = posts.where((post) => post.featured).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Info Bar (without leading back arrow since it is now a top-level tab section!)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppTheme.primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Gampaha, Western Province",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          fontFamily: 'Outfit',
                          letterSpacing: -0.5,
                        ),
                        children: const [
                          TextSpan(text: "Fresh "),
                          TextSpan(
                            text: "Market",
                            style: TextStyle(color: Color(0xFF22C55E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Publish Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePostScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF15803D)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Sell Crop",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
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
                  hintText: "Search fresh veggies, fruits, grains...",
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Category Chips Row
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryChip("All", isDark),
                _buildCategoryChip("Vegetables", isDark),
                _buildCategoryChip("Fruits", isDark),
                _buildCategoryChip("Grains", isDark),
                _buildCategoryChip("Spices", isDark),
              ],
            ),
          ),

          // Featured Today — only when viewing all and no active search
          if (_selectedCategory == "All" && _searchQuery.isEmpty && featuredPosts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "✨ Featured Today",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      fontFamily: 'Outfit',
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    "Freshest picks",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 130,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featuredPosts.length,
                itemBuilder: (context, index) {
                  final post = featuredPosts[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _buildFeaturedCard(post, isDark),
                  );
                },
              ),
            ),
          ],

          // Products Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory == "All" ? "All Products" : _selectedCategory,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    fontFamily: 'Outfit',
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  "(${filteredPosts.length})",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),

          // 2-Column Grid of Products
          if (filteredPosts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "No produce listings found",
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredPosts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  return _buildProductGridCard(post, isDark);
                },
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String categoryName, bool isDark) {
    final bool isActive = _selectedCategory == categoryName;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(categoryName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        selected: isActive,
        onSelected: (val) {
          setState(() {
            _selectedCategory = categoryName;
          });
        },
        selectedColor: const Color(0xFF22C55E).withOpacity(0.12),
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        side: BorderSide(
          color: isActive ? const Color(0xFF22C55E) : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        labelStyle: TextStyle(
          color: isActive ? const Color(0xFF22C55E) : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(FarmerPost post, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        width: 180,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1A2A1A) : const Color(0xFFE8F5E9),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                post.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.white24),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            if (post.organic)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "ORGANIC",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          post.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          post.location,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Rs.${post.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF86EFAC),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGridCard(FarmerPost post, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      post.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (post.organic)
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          "ORGANIC",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.location,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs.${post.price.toStringAsFixed(0)}/${post.unit}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 12),
                          const SizedBox(width: 2),
                          Text(
                            post.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

