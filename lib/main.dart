import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/auth/presentation/screens/auth_demo_screen.dart';
import 'package:local_link/features/auth/presentation/screens/pin_screen.dart';
import 'package:local_link/features/bookings/presentation/screens/bookings_demo_screen.dart';
import 'package:local_link/features/marketplace/presentation/screens/marketplace_demo_screen.dart';
import 'package:local_link/features/marketplace/presentation/screens/nearby_map_screen.dart';
import 'package:local_link/features/auth/presentation/screens/profile_screen.dart';
import 'package:local_link/features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isSupabaseInitialized = false;
  try {
    // Placeholder credentials. Replace with your actual Supabase URL and Anon Key.
    const String supabaseUrl = 'https://pcfryraaxtbpggrofupk.supabase.co';
    const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBjZnJ5cmFheHRicGdncm9mdXBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyMzQxNDYsImV4cCI6MjA5ODgxMDE0Nn0.21nc1_v6k8RPmGFtRfRnlyVjTKJZgzs6d6Y9PfH3vbA';

    if (supabaseUrl != 'https://your-project.supabase.co' && supabaseUrl.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      isSupabaseInitialized = true;
    }
  } catch (e) {
    debugPrint('Supabase initialization warning: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Inject configuration flag
        supabaseConfiguredProvider.overrideWith((ref) => isSupabaseInitialized),
      ],
      child: LankaQuickApp(isSupabaseConfigured: isSupabaseInitialized),
    ),
  );
}

class LankaQuickApp extends ConsumerWidget {
  final bool isSupabaseConfigured;

  const LankaQuickApp({
    super.key,
    required this.isSupabaseConfigured,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashCompleted = ref.watch(splashCompletedProvider);
    final lockStateAsync = ref.watch(appLockControllerProvider);

    return MaterialApp(
      title: 'LankaQuick',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode for a premium aesthetic
      debugShowCheckedModeBanner: false,
      home: !splashCompleted
          ? const SplashScreen()
          : lockStateAsync.when(
              data: (state) {
                switch (state) {
                  case AppLockState.checking:
                    return const _SplashLoadingScreen();
                  case AppLockState.unauthenticated:
                    return AuthDemoScreen(isSupabaseConfigured: isSupabaseConfigured);
                  case AppLockState.setPin:
                    return const PinScreen(isSetup: true);
                  case AppLockState.locked:
                    return const PinScreen(isSetup: false);
                  case AppLockState.unlocked:
                    return MainNavigationScreen(isSupabaseConfigured: isSupabaseConfigured);
                }
              },
              loading: () => const _SplashLoadingScreen(),
              error: (err, stack) => Scaffold(
                body: Center(
                  child: Text('Startup error: $err'),
                ),
              ),
            ),
    );
  }
}

class _SplashLoadingScreen extends StatelessWidget {
  const _SplashLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.offline_bolt_outlined, size: 64, color: AppTheme.primaryColor),
            SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  final bool isSupabaseConfigured;

  const MainNavigationScreen({
    super.key,
    required this.isSupabaseConfigured,
  });

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> screens = [
      MarketplaceDemoScreen(isSupabaseConfigured: widget.isSupabaseConfigured),
      NearbyMapScreen(isSupabaseConfigured: widget.isSupabaseConfigured),
      BookingsDemoScreen(isSupabaseConfigured: widget.isSupabaseConfigured),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.offline_bolt_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'LankaQuick',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.isSupabaseConfigured)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: AppTheme.accentColor.withOpacity(0.2),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.accentColor, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Supabase is running in Demo Mode (Local Config missing).',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: screens[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey.shade500,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: tr(ref, 'nav_nearby'),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Bookings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
