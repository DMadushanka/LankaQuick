import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:local_link/features/bookings/data/repositories/bookings_repository_impl.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/domain/repositories/bookings_repository.dart';

part 'bookings_provider.g.dart';

@riverpod
BookingsRepository bookingsRepository(Ref ref) {
  return BookingsRepositoryImpl();
}

@riverpod
Stream<List<BookingEntity>> bookingsStream(
  Ref ref, {
  required String userId,
  required String role,
}) {
  final repository = ref.watch(bookingsRepositoryProvider);
  return repository.watchBookingsForUser(userId, role);
}

@riverpod
class BookingsController extends _$BookingsController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> requestBooking({
    required String seekerId,
    required String providerId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookingsRepositoryProvider);
      final booking = BookingEntity(
        id: '', // Firestore auto-generates
        seekerId: seekerId,
        providerId: providerId,
        status: 'pending',
        timestamp: DateTime.now(),
      );
      await repository.createBooking(booking);
    });
  }

  Future<void> updateStatus({
    required String bookingId,
    required String status,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(bookingsRepositoryProvider);
      await repository.updateBookingStatus(bookingId, status);
    });
  }
}

class MockBookingsNotifier extends StateNotifier<List<BookingEntity>> {
  MockBookingsNotifier() : super([
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

  void updateStatus(String bookingId, String newStatus) {
    state = state.map((b) {
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
  }

  void addBooking(BookingEntity booking) {
    state = [...state, booking];
  }
}

final mockBookingsProvider = StateNotifierProvider<MockBookingsNotifier, List<BookingEntity>>((ref) {
  return MockBookingsNotifier();
});
