import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/marketplace/presentation/providers/farmer_marketplace_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(text: "kg");
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController(text: "Gampaha");

  String _selectedCategory = "Vegetables";
  String _selectedEmoji = "🍅";

  final List<String> categoriesList = ["Vegetables", "Fruits", "Grains", "Spices"];
  final Map<String, List<String>> categoryEmojis = {
    "Vegetables": ["🍅", "🥕", "🥔", "🧅", "🥦", "🥬", "🌽", "🍆"],
    "Fruits": ["🍎", "🍌", "🍍", "🥭", "🍇", "🍉", "🍒", "🍊"],
    "Grains": ["🌾", "🌽", "🌾", "🌾"],
    "Spices": ["🌶️", "🧄", "🧅", "🧂"],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final double qty = double.tryParse(_qtyController.text) ?? 0.0;

      final newPost = FarmerPost(
        id: "fp_${Random().nextInt(1000000)}",
        farmerId: "f_104", // Custom Demo Farmer
        farmerName: "Amara Wickramasinghe (My Farm)",
        farmerAvatar: "A",
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        unit: _unitController.text.trim(),
        image: _selectedEmoji,
        category: _selectedCategory,
        quantity: qty,
        location: _locationController.text.trim(),
        date: "Just now",
      );

      ref.read(farmerPostsProvider.notifier).addPost(newPost);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product post published successfully!'),
          backgroundColor: AppTheme.primaryColor,
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
          "Publish Product Post",
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
                // Title
                _buildSectionLabel("PRODUCT TITLE", isDark),
                _buildTextField(
                  controller: _titleController,
                  hint: "e.g. Fresh Red Onions (Rathu Lunu)",
                  isDark: isDark,
                  validator: (val) => val == null || val.trim().isEmpty ? "Title is required" : null,
                ),
                const SizedBox(height: 16),

                // Category & Emoji Picker Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("CATEGORY", isDark),
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
                                value: _selectedCategory,
                                dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
                                isExpanded: true,
                                items: categoriesList.map((String cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(cat),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCategory = val;
                                      _selectedEmoji = categoryEmojis[_selectedCategory]![0];
                                    });
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
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("ICON/EMOJI", isDark),
                          GestureDetector(
                            onTap: () {
                              _showEmojiPickerDialog(isDark);
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _selectedEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing Row (Price & Unit)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("PRICE (LKR)", isDark),
                          _buildTextField(
                            controller: _priceController,
                            hint: "e.g. 350",
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Price required";
                              if (double.tryParse(val) == null) return "Invalid number";
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("UNIT TYPE", isDark),
                          _buildTextField(
                            controller: _unitController,
                            hint: "e.g. kg",
                            isDark: isDark,
                            validator: (val) => val == null || val.trim().isEmpty ? "Unit required" : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quantity & Location Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("STOCK QUANTITY", isDark),
                          _buildTextField(
                            controller: _qtyController,
                            hint: "e.g. 50.0",
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Stock required";
                              if (double.tryParse(val) == null) return "Invalid number";
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("LOCATION", isDark),
                          _buildTextField(
                            controller: _locationController,
                            hint: "e.g. Gampaha",
                            isDark: isDark,
                            validator: (val) => val == null || val.trim().isEmpty ? "Location required" : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                _buildSectionLabel("DESCRIPTION", isDark),
                _buildTextField(
                  controller: _descController,
                  hint: "Write details about harvest date, quality, organic nature...",
                  isDark: isDark,
                  maxLines: 4,
                  validator: (val) => val == null || val.trim().isEmpty ? "Description is required" : null,
                ),
                const SizedBox(height: 28),

                // Publish Button
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
                      "Publish Post",
                      style: TextStyle(
                        fontSize: 14,
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

  void _showEmojiPickerDialog(bool isDark) {
    final emojis = categoryEmojis[_selectedCategory]!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          title: Text(
            "Select Post Icon",
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: emojis.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEmoji = emojis[index];
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      emojis[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
