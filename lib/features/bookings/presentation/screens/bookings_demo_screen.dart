import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/theme/app_theme.dart';

class FigmaBooking {
  final String id;
  final String provider;
  final String service;
  final String emoji;
  final String date;
  final String status; // 'upcoming' or 'completed'
  final String price;
  final Color color;

  const FigmaBooking({
    required this.id,
    required this.provider,
    required this.service,
    required this.emoji,
    required this.date,
    required this.status,
    required this.price,
    required this.color,
  });
}

class BookingsDemoScreen extends ConsumerStatefulWidget {
  final bool isSupabaseConfigured;

  const BookingsDemoScreen({
    super.key,
    required this.isSupabaseConfigured,
  });

  @override
  ConsumerState<BookingsDemoScreen> createState() => _BookingsDemoScreenState();
}

class _BookingsDemoScreenState extends ConsumerState<BookingsDemoScreen> {
  String _activeTab = 'upcoming';

  final List<FigmaBooking> figmaBookings = [
    const FigmaBooking(
      id: "b1",
      provider: "Kamal Perera",
      service: "Plumbing",
      emoji: "🔧",
      date: "Today, 2:30 PM",
      status: "upcoming",
      price: "Rs. 1,500",
      color: Color(0xFF3B82F6),
    ),
    const FigmaBooking(
      id: "b2",
      provider: "Chamari Silva",
      service: "House Cleaning",
      emoji: "🧹",
      date: "Yesterday, 10:00 AM",
      status: "completed",
      price: "Rs. 2,400",
      color: Color(0xFF34D399),
    ),
    const FigmaBooking(
      id: "b3",
      provider: "Nuwan Jayasinghe",
      service: "Electrical",
      emoji: "⚡",
      date: "Jul 3, 9:00 AM",
      status: "completed",
      price: "Rs. 3,000",
      color: Color(0xFFF59E0B),
    ),
    const FigmaBooking(
      id: "b4",
      provider: "Dilini Fernando",
      service: "Salon & Beauty",
      emoji: "💇",
      date: "Jul 10, 4:00 PM",
      status: "upcoming",
      price: "Rs. 800",
      color: Color(0xFFF472B6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filtered = figmaBookings.where((b) => b.status == _activeTab).toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              "My Bookings",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                fontFamily: 'Outfit',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Track and manage your service requests",
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
            const SizedBox(height: 20),

            // Tab Buttons
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x0DFFFFFF) : const Color(0x0D000000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton("upcoming", "Upcoming", isDark),
                  ),
                  Expanded(
                    child: _buildTabButton("completed", "Completed", isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bookings List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        "No $_activeTab bookings",
                        style: TextStyle(
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        final Color statusColor = b.color;
                        final isUpcoming = b.status == 'upcoming';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                            boxShadow: !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Stack(
                            children: [
                              // Left Color Ribbon Bar Accent
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Emoji Avatar
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.09),
                                            borderRadius: BorderRadius.circular(13),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            b.emoji,
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Booking Metadata
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                b.provider,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                                  fontFamily: 'Outfit',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                b.service,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 12,
                                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    b.date,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Pricing & Badge
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              b.price,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isUpcoming
                                                    ? AppTheme.primaryColor.withOpacity(0.12)
                                                    : const Color(0xFF22C55E).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                b.status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isUpcoming
                                                      ? AppTheme.primaryColor
                                                      : const Color(0xFF22C55E),
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (isUpcoming) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {},
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                side: BorderSide(
                                                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                                ),
                                                foregroundColor: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                              ),
                                              child: const Text(
                                                "Reschedule",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: AppTheme.primaryGradient,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.transparent,
                                                  shadowColor: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                child: const Text(
                                                  "Message",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String key, String label, bool isDark) {
    final bool isActive = _activeTab == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive 
                ? Colors.white 
                : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
