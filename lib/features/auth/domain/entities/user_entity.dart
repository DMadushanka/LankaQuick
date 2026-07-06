class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String role; // 'seeker' or 'provider'
  final double? locationLat;
  final double? locationLng;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.locationLat,
    this.locationLng,
  });
}
