import 'package:flutter_riverpod/flutter_riverpod.dart';
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
