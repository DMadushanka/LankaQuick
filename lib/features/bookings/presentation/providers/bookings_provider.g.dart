// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingsRepository)
const bookingsRepositoryProvider = BookingsRepositoryProvider._();

final class BookingsRepositoryProvider
    extends
        $FunctionalProvider<
          BookingsRepository,
          BookingsRepository,
          BookingsRepository
        >
    with $Provider<BookingsRepository> {
  const BookingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingsRepository create(Ref ref) {
    return bookingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingsRepository>(value),
    );
  }
}

String _$bookingsRepositoryHash() =>
    r'0836105a00614db928a2fb3bd58d093a0b1e3161';

@ProviderFor(bookingsStream)
const bookingsStreamProvider = BookingsStreamFamily._();

final class BookingsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookingEntity>>,
          List<BookingEntity>,
          Stream<List<BookingEntity>>
        >
    with
        $FutureModifier<List<BookingEntity>>,
        $StreamProvider<List<BookingEntity>> {
  const BookingsStreamProvider._({
    required BookingsStreamFamily super.from,
    required ({String userId, String role}) super.argument,
  }) : super(
         retry: null,
         name: r'bookingsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingsStreamHash();

  @override
  String toString() {
    return r'bookingsStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<BookingEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BookingEntity>> create(Ref ref) {
    final argument = this.argument as ({String userId, String role});
    return bookingsStream(ref, userId: argument.userId, role: argument.role);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingsStreamHash() => r'4075e141e16b71f157d0c4a08793bc40849cd42b';

final class BookingsStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<BookingEntity>>,
          ({String userId, String role})
        > {
  const BookingsStreamFamily._()
    : super(
        retry: null,
        name: r'bookingsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookingsStreamProvider call({required String userId, required String role}) =>
      BookingsStreamProvider._(
        argument: (userId: userId, role: role),
        from: this,
      );

  @override
  String toString() => r'bookingsStreamProvider';
}

@ProviderFor(BookingsController)
const bookingsControllerProvider = BookingsControllerProvider._();

final class BookingsControllerProvider
    extends $AsyncNotifierProvider<BookingsController, void> {
  const BookingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingsControllerHash();

  @$internal
  @override
  BookingsController create() => BookingsController();
}

String _$bookingsControllerHash() =>
    r'17a26c01d7569b87bf3cb3b8f2243b60b52e2234';

abstract class _$BookingsController extends $AsyncNotifier<void> {
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
