import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:local_link/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';
import 'package:local_link/features/marketplace/domain/repositories/marketplace_repository.dart';

part 'marketplace_provider.g.dart';

@riverpod
MarketplaceRepository marketplaceRepository(Ref ref) {
  return MarketplaceRepositoryImpl();
}

@riverpod
Stream<List<ServiceEntity>> servicesStream(Ref ref) {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.watchServices();
}

@riverpod
class MarketplaceController extends _$MarketplaceController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addService({
    required String providerId,
    required String category,
    required String title,
    required String description,
    required double price,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(marketplaceRepositoryProvider);
      final service = ServiceEntity(
        id: '', // Firestore auto-generates
        providerId: providerId,
        category: category,
        title: title,
        description: description,
        price: price,
      );
      await repository.createService(service);
    });
  }
}
