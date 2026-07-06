import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';

abstract class MarketplaceRepository {
  Future<void> createService(ServiceEntity service);
  Stream<List<ServiceEntity>> watchServices();
  Future<ServiceEntity?> getServiceById(String id);
}
