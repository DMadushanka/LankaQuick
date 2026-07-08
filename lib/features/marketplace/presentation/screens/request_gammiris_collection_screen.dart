import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/marketplace/presentation/providers/farmer_marketplace_provider.dart';

class RequestGammirisCollectionScreen extends ConsumerStatefulWidget {
  const RequestGammirisCollectionScreen({super.key});

  @override
  ConsumerState<RequestGammirisCollectionScreen> createState() => _RequestGammirisCollectionScreenState();
}

class _RequestGammirisCollectionScreenState extends ConsumerState<RequestGammirisCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController(text: "Amara Wickramasinghe");
  final _phoneController = TextEditingController(text: "+94 77 123 4567");

  String _selectedGrade = "Grade 1 (Black Pepper)";
  String _selectedDistrict = "Matale";
  double _estimatedValue = 0.0;

  final List<String> _grades = ["Grade 1 (Black Pepper)", "Grade 2 (Standard)", "Light Berries (Bora)", "Organic Certified"];
  final List<String> _districts = ["Matale", "Kandy", "Gampaha", "Kurunegala", "Kegalle"];

  @override
  void dispose() {
    _weightController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _calculatePayout() {
    final double weight = double.tryParse(_weightController.text) ?? 0.0;
    // Find price in price table
    final priceObj = gammirisPrices.firstWhere(
      (p) => p.grade == _selectedGrade && p.district == _selectedDistrict,
      orElse: () => const GammirisPrice(grade: "", district: "", pricePerKg: 1000.0, trend: ""),
    );

    setState(() {
      _estimatedValue = weight * priceObj.pricePerKg;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double weight = double.tryParse(_weightController.text) ?? 0.0;

      final newReq = GammirisCollectionRequest(
        id: "gr_${Random().nextInt(1000000)}",
        grade: _selectedGrade,
        weight: weight,
        district: _selectedDistrict,
        address: _addressController.text.trim(),
        contactName: _nameController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        totalEstimatedValue: _estimatedValue,
        status: "Pending Verification",
        requestedAt: DateTime.now(),
      );

      ref.read(gammirisRequestsProvider.notifier).addRequest(newReq);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Collection request submitted! We will contact you soon.'),
          backgroundColor: Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Find current rate per kg
    final currentRateObj = gammirisPrices.firstWhere(
      (p) => p.grade == _selectedGrade && p.district == _selectedDistrict,
      orElse: () => const GammirisPrice(grade: "", district: "", pricePerKg: 1000.0, trend: ""),
    );

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppTheme.lightTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Request Harvest Collection",
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "We collect black pepper harvests directly from your farm/location and pay cash instantly upon grade verification.",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFD0D0D0) : AppTheme.lightTextSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Select Gammiris Grade
                _buildSectionLabel("GAMMIRIS GRADE / TYPE", isDark),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGrade,
                      dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
                      isExpanded: true,
                      items: _grades.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedGrade = val;
                          });
                          _calculatePayout();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // District & Weight row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("DISTRICT", isDark),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDistrict,
                                dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
                                isExpanded: true,
                                items: _districts.map((String val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(val),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedDistrict = val;
                                    });
                                    _calculatePayout();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("HARVEST WEIGHT (KG)", isDark),
                          _buildTextField(
                            controller: _weightController,
                            hint: "e.g. 150",
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _calculatePayout(),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Weight required";
                              if (double.tryParse(val) == null || double.parse(val) <= 0) return "Invalid weight";
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current Market Reference Rate Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Current Matched Market Rate:",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    Text(
                      "Rs. ${currentRateObj.pricePerKg.toStringAsFixed(0)} / kg",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pickup Address
                _buildSectionLabel("PICKUP ADDRESS", isDark),
                _buildTextField(
                  controller: _addressController,
                  hint: "e.g. No. 42, Gampaha Road, Yakkala",
                  isDark: isDark,
                  maxLines: 2,
                  validator: (val) => val == null || val.trim().isEmpty ? "Address is required" : null,
                ),
                const SizedBox(height: 16),

                // Contact Name & Phone Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("CONTACT NAME", isDark),
                          _buildTextField(
                            controller: _nameController,
                            hint: "e.g. Sunil",
                            isDark: isDark,
                            validator: (val) => val == null || val.trim().isEmpty ? "Name required" : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("CONTACT PHONE", isDark),
                          _buildTextField(
                            controller: _phoneController,
                            hint: "e.g. +9477...",
                            isDark: isDark,
                            validator: (val) => val == null || val.trim().isEmpty ? "Phone required" : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live estimated payout display card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                    boxShadow: !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ESTIMATED PAYOUT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Cash Paid on Collection",
                            style: TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        "Rs. ${_estimatedValue.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Request Button
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Submit Collection Request",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark ? AppTheme.darkInput : AppTheme.lightInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
