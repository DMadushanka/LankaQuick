import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_link/features/marketplace/data/models/service_model.dart';
import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';
import 'package:local_link/features/marketplace/domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final SupabaseClient _supabase;

  MarketplaceRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<void> createService(ServiceEntity service) async {
    final data = {
      'provider_id': service.providerId,
      'category': service.category,
      'title': service.title,
      'description': service.description,
      'price': service.price,
    };

    if (service.id.isEmpty) {
      await _supabase.from('services').insert(data);
    } else {
      data['id'] = service.id;
      await _supabase.from('services').upsert(data);
    }
  }

  @override
  Stream<List<ServiceEntity>> watchServices() {
    return _supabase
        .from('services')
        .stream(primaryKey: ['id'])
        .map((event) {
          return event.map((e) => ServiceModel.fromMap(e, e['id'].toString())).toList();
        });
  }

  @override
  Future<ServiceEntity?> getServiceById(String id) async {
    final data = await _supabase.from('services').select().eq('id', id).maybeSingle();
    if (data != null) {
      return ServiceModel.fromMap(data, data['id'].toString());
    }
    return null;
  }
}
