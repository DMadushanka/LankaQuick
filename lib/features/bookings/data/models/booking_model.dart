import 'package:local_link/features/bookings/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.seekerId,
    required super.providerId,
    required super.status,
    required super.timestamp,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      seekerId: map['seeker_id'] ?? '',
      providerId: map['provider_id'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seeker_id': seekerId,
      'provider_id': providerId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
