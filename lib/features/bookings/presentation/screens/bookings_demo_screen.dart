import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/presentation/providers/bookings_provider.dart';
import 'package:local_link/features/bookings/presentation/screens/live_tracking_screen.dart';

// Mock bookings list for offline testing
final mockBookingsProvider = StateProvider<List<BookingEntity>>((ref) => [
      BookingEntity(
        id: 'booking_1',
        seekerId: 'mock_seeker_123',
        providerId: 'mock_provider_1',
        status: 'pending',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BookingEntity(
        id: 'booking_2',
        seekerId: 'mock_seeker_123',
        providerId: 'mock_provider_2',
        status: 'accepted',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BookingEntity(
        id: 'booking_3',
        seekerId: 'mock_seeker_123',
        providerId: 'mock_provider_3',
        status: 'completed',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);

class BookingsDemoScreen extends ConsumerWidget {
  final bool isSupabaseConfigured;

  const BookingsDemoScreen({
    super.key,
    required this.isSupabaseConfigured,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.accentColor;
      case 'accepted':
        return AppTheme.primaryColor;
      case 'completed':
        return AppTheme.secondaryColor;
      case 'cancelled':
      default:
        return Colors.redAccent;
    }
  }

  void _updateMockStatus(WidgetRef ref, String bookingId, String newStatus) {
    ref.read(mockBookingsProvider.notifier).update((state) {
      return state.map((b) {
        if (b.id == bookingId) {
          return BookingEntity(
            id: b.id,
            seekerId: b.seekerId,
            providerId: b.providerId,
            status: newStatus,
            timestamp: b.timestamp,
          );
        }
        return b;
      }).toList();
    });
  }

  void _updateRealStatus(WidgetRef ref, String bookingId, String newStatus) {
    ref.read(bookingsControllerProvider.notifier).updateStatus(
          bookingId: bookingId,
          status: newStatus,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bookingsStream = currentUser != null
        ? ref.watch(bookingsStreamProvider(userId: currentUser.uid, role: currentUser.role))
        : null;

    final mockBookings = ref.watch(mockBookingsProvider);

    final List<BookingEntity> bookingsList = isSupabaseConfigured
        ? (bookingsStream?.value ?? [])
        : mockBookings;

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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(tr(ref, 'bookings_title')),
      ),
      body: bookingsList.isEmpty
          ? Center(
              child: Text(
                tr(ref, 'bookings_empty'),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: bookingsList.length,
              itemBuilder: (context, index) {
                final booking = bookingsList[index];
                final statusColor = _getStatusColor(booking.status);
                final isProvider = currentUser.role == 'provider';

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
                            Text(
                              '${tr(ref, 'bookings_id')}: ${booking.id.substring(0, booking.id.length > 8 ? 8 : booking.id.length)}...',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                booking.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              booking.timestamp.toLocal().toString().substring(0, 16),
                              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_pin_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              isProvider ? 'Seeker ID: ${booking.seekerId}' : 'Provider ID: ${booking.providerId}',
                              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                        if (booking.status == 'pending' ||
                            booking.status == 'accepted' ||
                            booking.status == 'en_route' ||
                            booking.status == 'arrived') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (booking.status == 'pending') ...[
                                if (isProvider) ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      if (isSupabaseConfigured) {
                                        _updateRealStatus(ref, booking.id, 'accepted');
                                      } else {
                                        _updateMockStatus(ref, booking.id, 'accepted');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.secondaryColor,
                                      minimumSize: const Size(100, 36),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(tr(ref, 'btn_accept'), style: const TextStyle(fontSize: 12, color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (isSupabaseConfigured) {
                                        _updateRealStatus(ref, booking.id, 'cancelled');
                                      } else {
                                        _updateMockStatus(ref, booking.id, 'cancelled');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                                      foregroundColor: Colors.redAccent,
                                      minimumSize: const Size(100, 36),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(tr(ref, 'btn_decline'), style: const TextStyle(fontSize: 12)),
                                  ),
                                ] else ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      if (isSupabaseConfigured) {
                                        _updateRealStatus(ref, booking.id, 'cancelled');
                                      } else {
                                        _updateMockStatus(ref, booking.id, 'cancelled');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                                      foregroundColor: Colors.redAccent,
                                      minimumSize: const Size(100, 36),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(tr(ref, 'btn_cancel_request'), style: const TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ],
                              if (booking.status == 'accepted' ||
                                  booking.status == 'en_route' ||
                                  booking.status == 'arrived') ...[
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => LiveTrackingScreen(
                                          booking: booking,
                                          isSupabaseConfigured: isSupabaseConfigured,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.secondaryColor,
                                    minimumSize: const Size(120, 36),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.map_outlined, size: 14, color: Colors.white),
                                  label: Text(tr(ref, 'btn_track'), style: const TextStyle(fontSize: 12, color: Colors.white)),
                                ),
                                if (isProvider) ...[
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (isSupabaseConfigured) {
                                        _updateRealStatus(ref, booking.id, 'completed');
                                      } else {
                                        _updateMockStatus(ref, booking.id, 'completed');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      minimumSize: const Size(120, 36),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(tr(ref, 'btn_complete_work'), style: const TextStyle(fontSize: 12, color: Colors.white)),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
