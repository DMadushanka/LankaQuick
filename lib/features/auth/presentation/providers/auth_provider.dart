import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_link/features/auth/data/models/user_model.dart';
import 'package:local_link/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:local_link/features/auth/domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

@riverpod
Stream<UserEntity?> authState(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.onAuthStateChanged;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<UserEntity?> build() {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.signIn(email: email, password: password);
    });
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    });
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isSupabase = ref.read(supabaseConfiguredProvider);
      if (isSupabase) {
        final repository = ref.read(authRepositoryProvider);
        await repository.updateProfile(uid: uid, name: name, role: role);
        final currentUserData = ref.read(currentUserProvider);
        return UserEntity(
          uid: uid,
          name: name,
          email: currentUserData?.email ?? '',
          role: role,
        );
      } else {
        final currentUserData = ref.read(currentUserProvider);
        final updatedUser = UserEntity(
          uid: uid,
          name: name,
          email: currentUserData?.email ?? 'demo@gmail.com',
          role: role,
        );
        ref.read(mockUserControllerProvider.notifier).setUser(updatedUser);
        return updatedUser;
      }
    });
  }

  Future<void> updateLocation({
    required String uid,
    required double lat,
    required double lng,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isSupabase = ref.read(supabaseConfiguredProvider);
      if (isSupabase) {
        final repository = ref.read(authRepositoryProvider);
        await repository.updateLocation(uid: uid, lat: lat, lng: lng);
        final currentUserData = ref.read(currentUserProvider);
        return UserEntity(
          uid: uid,
          name: currentUserData?.name ?? '',
          email: currentUserData?.email ?? '',
          role: currentUserData?.role ?? 'seeker',
          locationLat: lat,
          locationLng: lng,
        );
      } else {
        final currentUserData = ref.read(currentUserProvider);
        final updatedUser = UserEntity(
          uid: uid,
          name: currentUserData?.name ?? 'Demo User',
          email: currentUserData?.email ?? 'demo@gmail.com',
          role: currentUserData?.role ?? 'seeker',
          locationLat: lat,
          locationLng: lng,
        );
        ref.read(mockUserControllerProvider.notifier).setUser(updatedUser);
        return updatedUser;
      }
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
      return null;
    });
  }
}

@riverpod
bool supabaseConfigured(Ref ref) {
  return false;
}

@riverpod
class MockUserController extends _$MockUserController {
  @override
  UserEntity? build() => null;

  void setUser(UserEntity? user) {
    state = user;
  }
}
@riverpod
Stream<UserEntity?> userProfile(Ref ref) {
  final supabaseUser = ref.watch(authStateProvider).asData?.value;
  if (supabaseUser == null) return Stream.value(null);
  
  final supabase = Supabase.instance.client;
  return supabase.from('users').stream(primaryKey: ['id']).eq('id', supabaseUser.uid).map((event) {
    if (event.isNotEmpty) {
      return UserModel.fromMap(event.first);
    }
    return null;
  });
}

@riverpod
UserEntity? currentUser(Ref ref) {
  final isSupabase = ref.watch(supabaseConfiguredProvider);
  if (isSupabase) {
    return ref.watch(userProfileProvider).asData?.value;
  } else {
    return ref.watch(mockUserControllerProvider);
  }
}

enum AppLockState {
  checking,
  unauthenticated,
  setPin,
  locked,
  unlocked,
}

@riverpod
class AppLockController extends _$AppLockController {
  static const String _pinKey = 'user_login_pin';

  @override
  FutureOr<AppLockState> build() async {
    // Watch currentUser to automatically react to sign in / sign out in both modes
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return AppLockState.unauthenticated;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey);
    
    if (storedPin == null || storedPin.isEmpty) {
      return AppLockState.setPin;
    }
    
    return AppLockState.locked;
  }

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    state = const AsyncValue.data(AppLockState.unlocked);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey);
    if (storedPin == pin) {
      state = const AsyncValue.data(AppLockState.unlocked);
      return true;
    }
    return false;
  }

  Future<void> resetAndLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    final isSupabase = ref.read(supabaseConfiguredProvider);
    if (isSupabase) {
      await ref.read(authControllerProvider.notifier).logout();
    } else {
      ref.read(mockUserControllerProvider.notifier).setUser(null);
    }
    state = const AsyncValue.data(AppLockState.unauthenticated);
  }

  void lock() {
    state.whenData((currentState) {
      if (currentState == AppLockState.unlocked) {
        state = const AsyncValue.data(AppLockState.locked);
      }
    });
  }
}

@riverpod
class SplashCompleted extends _$SplashCompleted {
  @override
  bool build() => false;

  void complete() {
    state = true;
  }
}

// Manual providers to support nearby explorer and live location sync
final mockProvidersProvider = StateProvider<List<UserEntity>>((ref) => [
  const UserEntity(
    uid: 'mock_provider_1',
    name: 'Perera Gardeners (Gewathu wada)',
    email: 'perera@gmail.com',
    role: 'provider',
    locationLat: 6.9271, // Colombo center
    locationLng: 79.8612,
  ),
  const UserEntity(
    uid: 'mock_provider_2',
    name: 'Silva Plumbers (Jala nala)',
    email: 'silva@gmail.com',
    role: 'provider',
    locationLat: 6.9150, // Cinnamon Gardens
    locationLng: 79.8700,
  ),
  const UserEntity(
    uid: 'mock_provider_3',
    name: 'Fernando Coconut Plucker (Pol kadima)',
    email: 'fernando@gmail.com',
    role: 'provider',
    locationLat: 6.9380, // Pettah / Fort area
    locationLng: 79.8480,
  ),
  const UserEntity(
    uid: 'mock_provider_4',
    name: 'Kumara Electrics (Viduli karmika)',
    email: 'kumara@gmail.com',
    role: 'provider',
    locationLat: 6.9200,
    locationLng: 79.8550,
  ),
  const UserEntity(
    uid: 'mock_provider_5',
    name: 'Suresh CCTV & Networks (CCTV)',
    email: 'suresh@gmail.com',
    role: 'provider',
    locationLat: 6.9100,
    locationLng: 79.8650,
  ),
]);

final providersStreamProvider = StreamProvider<List<UserEntity>>((ref) {
  final isSupabase = ref.watch(supabaseConfiguredProvider);
  if (isSupabase) {
    final repository = ref.watch(authRepositoryProvider);
    return repository.watchProviders();
  } else {
    // Just listen to the mockProvidersProvider and turn its updates into a stream!
    final providersList = ref.watch(mockProvidersProvider);
    return Stream.value(providersList);
  }
});

