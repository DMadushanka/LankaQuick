import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:local_link/features/bookings/presentation/screens/bookings_demo_screen.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final List<Map<String, String>> menuItems = [
    {"icon": "💬", "label": "In-App Messages"},
    {"icon": "📅", "label": "My Bookings"},
    {"icon": "🔖", "label": "Saved Providers"},
    {"icon": "💳", "label": "Payment Methods"},
    {"icon": "🔔", "label": "Notifications"},
    {"icon": "🌐", "label": "Language / භාෂාව"},
    {"icon": "⭐", "label": "Rate the App"},
    {"icon": "🤝", "label": "Refer a Friend"},
    {"icon": "❓", "label": "Help & Support"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = ref.watch(localeStateProvider);
    ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Gradient Block
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                children: [
                  // Avatar "A" with Orange Gradient
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: AppTheme.primaryGradient,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66F97316),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "A",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    "Amara Wickramasinghe",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      fontFamily: 'Outfit',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Contact details
                  Text(
                    "+94 77 123 4567 · Gampaha",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats Row Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.lightInput,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildStatItem("24", "Services Used", isLast: false, isDark: isDark),
                        _buildStatItem("8", "Providers Saved", isLast: false, isDark: isDark),
                        _buildStatItem("19", "Reviews Given", isLast: true, isDark: isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Settings and Menu Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Appearance Title
                  Text(
                    "APPEARANCE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Theme Mode Toggle Switch Card
                  Container(
                    decoration: AppTheme.glassDecoration(
                      isDark: isDark,
                      borderRadius: 18,
                    ),
                    child: InkWell(
                      onTap: () {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icon
                            Text(
                              isDark ? "🌙" : "☀️",
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            // Text Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDark ? "Dark Mode" : "Light Mode",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Tap to switch to ${isDark ? 'light' : 'dark'} theme",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Custom Sliding Switch Knob Pill
                            Container(
                              width: 50,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.primaryColor : const Color(0x1F000000),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    top: 3,
                                    left: isDark ? 25 : 3,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        isDark ? "🌙" : "☀️",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Settings Title
                  Text(
                    "SETTINGS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Menu Items Card List
                  Container(
                    decoration: AppTheme.glassDecoration(
                      isDark: isDark,
                      borderRadius: 18,
                    ),
                    child: Column(
                      children: List.generate(menuItems.length, (index) {
                        final item = menuItems[index];
                        final isLast = index == menuItems.length - 1;
                        final isMessagesRow = item["label"] == "In-App Messages";
                        final isLanguageRow = item["label"]!.contains("Language");

                        return InkWell(
                          onTap: () {
                            if (isMessagesRow) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatListScreen(),
                                ),
                              );
                            } else if (item["label"] == "My Bookings") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingsDemoScreen(
                                    isSupabaseConfigured: ref.read(supabaseConfiguredProvider),
                                  ),
                                ),
                              );
                            } else if (isLanguageRow) {
                              // Dynamically toggle language between English and Sinhala
                              final nextLocale = currentLocale == 'en' ? 'si' : 'en';
                              ref.read(localeStateProvider.notifier).setLocale(nextLocale);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Language switched to ${nextLocale == 'si' ? 'Sinhala' : 'English'}!'),
                                  backgroundColor: AppTheme.primaryColor,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: isLast ? null : Border(
                                bottom: BorderSide(
                                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  item["icon"]!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isLanguageRow 
                                        ? "Language / භාෂාව (${currentLocale.toUpperCase()})"
                                        : item["label"]!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign Out Button
                  InkWell(
                    onTap: () {
                      // Perform signout resetting
                      final isSupabase = ref.read(supabaseConfiguredProvider);
                      if (isSupabase) {
                        ref.read(authControllerProvider.notifier).logout();
                      } else {
                        ref.read(mockUserControllerProvider.notifier).setUser(null);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x12EF4444), // rgba(239,68,68,0.07)
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0x40EF4444), // rgba(239,68,68,0.25)
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Sign Out",
                        style: TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Footer Version Text
                  Text(
                    "SevaFind v1.0.0 · Made in Sri Lanka 🇱🇰",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {required bool isLast, required bool isDark}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            right: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
                fontFamily: 'Outfit',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
