// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(marketplaceRepository)
const marketplaceRepositoryProvider = MarketplaceRepositoryProvider._();

final class MarketplaceRepositoryProvider
    extends
        $FunctionalProvider<
          MarketplaceRepository,
          MarketplaceRepository,
          MarketplaceRepository
        >
    with $Provider<MarketplaceRepository> {
  const MarketplaceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketplaceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketplaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<MarketplaceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketplaceRepository create(Ref ref) {
    return marketplaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketplaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketplaceRepository>(value),
    );
  }
}

String _$marketplaceRepositoryHash() =>
    r'e235e1cd58ecd519113298ff483281556bc629e4';

@ProviderFor(servicesStream)
const servicesStreamProvider = ServicesStreamProvider._();

final class ServicesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceEntity>>,
          List<ServiceEntity>,
          Stream<List<ServiceEntity>>
        >
    with
        $FutureModifier<List<ServiceEntity>>,
        $StreamProvider<List<ServiceEntity>> {
  const ServicesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servicesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servicesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<ServiceEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ServiceEntity>> create(Ref ref) {
    return servicesStream(ref);
  }
}

String _$servicesStreamHash() => r'5dea592257437a81286933db26408fbf1b6a3e9b';

@ProviderFor(MarketplaceController)
const marketplaceControllerProvider = MarketplaceControllerProvider._();

final class MarketplaceControllerProvider
    extends $AsyncNotifierProvider<MarketplaceController, void> {
  const MarketplaceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketplaceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketplaceControllerHash();

  @$internal
  @override
  MarketplaceController create() => MarketplaceController();
}

String _$marketplaceControllerHash() =>
    r'dd0237767b1a5695c8d153d47207d162dfa6dbb1';

abstract class _$MarketplaceController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
