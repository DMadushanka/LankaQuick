import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';

abstract class BookingsRepository {
  Future<void> createBooking(BookingEntity booking);
  Stream<List<BookingEntity>> watchBookingsForUser(String userId, String role);
  Future<void> updateBookingStatus(String bookingId, String status);
}
