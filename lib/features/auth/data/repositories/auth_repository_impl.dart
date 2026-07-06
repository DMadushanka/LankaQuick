import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_link/core/errors/failures.dart';
import 'package:local_link/features/auth/data/models/user_model.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:local_link/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure('User creation failed.');
      }

      final userModel = UserModel(
        uid: user.id,
        name: name,
        email: email,
        role: role,
      );

      // Save user profile details to public.users table in Supabase
      await _supabase.from('users').upsert({
        'id': user.id,
        'name': name,
        'email': email,
        'role': role,
      });

      return userModel;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure('User sign in failed.');
      }

      // Fetch user profile from public.users table
      final data = await _supabase.from('users').select().eq('id', user.id).maybeSingle();
      if (data == null) {
        throw const AuthFailure('User profile not found in database.');
      }

      return UserModel.fromMap(data);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String role,
  }) async {
    try {
      await _supabase.from('users').update({
        'name': name,
        'role': role,
      }).eq('id', uid);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> updateLocation({
    required String uid,
    required double lat,
    required double lng,
  }) async {
    try {
      await _supabase.from('users').update({
        'location_lat': lat,
        'location_lng': lng,
      }).eq('id', uid);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Stream<List<UserEntity>> watchProviders() {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('role', 'provider')
        .map((event) {
          return event.map((e) => UserModel.fromMap(e)).toList();
        });
  }

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;
      try {
        final profile = await _supabase.from('users').select().eq('id', user.id).maybeSingle();
        if (profile != null) {
          return UserModel.fromMap(profile);
        }
        return UserEntity(
          uid: user.id,
          name: user.userMetadata?['name'] ?? '',
          email: user.email ?? '',
          role: 'seeker',
        );
      } catch (_) {
        return null;
      }
    });
  }
}
