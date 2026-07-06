class BookingEntity {
  final String id;
  final String seekerId;
  final String providerId;
  final String status; // 'pending', 'accepted', 'completed', 'cancelled'
  final DateTime timestamp;

  const BookingEntity({
    required this.id,
    required this.seekerId,
    required this.providerId,
    required this.status,
    required this.timestamp,
  });
}
