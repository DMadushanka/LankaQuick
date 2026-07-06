import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_link/features/bookings/data/models/booking_model.dart';
import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';
import 'package:local_link/features/bookings/domain/repositories/bookings_repository.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final SupabaseClient _supabase;

  BookingsRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<void> createBooking(BookingEntity booking) async {
    final data = {
      'seeker_id': booking.seekerId,
      'provider_id': booking.providerId,
      'status': booking.status,
      'timestamp': booking.timestamp.toIso8601String(),
    };

    if (booking.id.isEmpty) {
      await _supabase.from('bookings').insert(data);
    } else {
      data['id'] = booking.id;
      await _supabase.from('bookings').upsert(data);
    }
  }

  @override
  Stream<List<BookingEntity>> watchBookingsForUser(String userId, String role) {
    // Filter bookings based on user's role (seeker vs provider)
    final queryField = (role == 'provider') ? 'provider_id' : 'seeker_id';

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq(queryField, userId)
        .map((event) {
          final bookings = event.map((e) => BookingModel.fromMap(e, e['id'].toString())).toList();
          // Sort descending by timestamp (most recent first)
          bookings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return bookings;
        });
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _supabase.from('bookings').update({
      'status': status,
    }).eq('id', bookingId);
  }
}
