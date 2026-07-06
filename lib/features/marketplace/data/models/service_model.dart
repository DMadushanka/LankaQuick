import 'package:local_link/features/marketplace/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.providerId,
    required super.category,
    required super.title,
    required super.description,
    required super.price,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceModel(
      id: map['id']?.toString() ?? docId,
      providerId: map['provider_id'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'category': category,
      'title': title,
      'description': description,
      'price': price,
    };
  }
}
