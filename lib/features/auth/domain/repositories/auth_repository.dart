import 'package:local_link/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<UserEntity?> get onAuthStateChanged;

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String role,
  });

  Future<void> updateLocation({
    required String uid,
    required double lat,
    required double lng,
  });

  Stream<List<UserEntity>> watchProviders();
}
