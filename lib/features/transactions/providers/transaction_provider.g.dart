// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addTransactionUseCaseHash() =>
    r'7250d43c6b0c1a7a18cafe10a486fa7cff55fd9d';

/// See also [addTransactionUseCase].
@ProviderFor(addTransactionUseCase)
final addTransactionUseCaseProvider =
    AutoDisposeProvider<AddTransactionUseCase>.internal(
  addTransactionUseCase,
  name: r'addTransactionUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addTransactionUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AddTransactionUseCaseRef
    = AutoDisposeProviderRef<AddTransactionUseCase>;
String _$recordPaymentUseCaseHash() =>
    r'384001525ca65a436670f7abbae8e2a752c99282';

/// See also [recordPaymentUseCase].
@ProviderFor(recordPaymentUseCase)
final recordPaymentUseCaseProvider =
    AutoDisposeProvider<RecordPaymentUseCase>.internal(
  recordPaymentUseCase,
  name: r'recordPaymentUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recordPaymentUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecordPaymentUseCaseRef = AutoDisposeProviderRef<RecordPaymentUseCase>;
String _$transactionByIdHash() => r'84bd1dc769793aecce5826fa018cabb864a83596';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [transactionById].
@ProviderFor(transactionById)
const transactionByIdProvider = TransactionByIdFamily();

/// See also [transactionById].
class TransactionByIdFamily extends Family<AsyncValue<DebtTransaction?>> {
  /// See also [transactionById].
  const TransactionByIdFamily();

  /// See also [transactionById].
  TransactionByIdProvider call(
    int id,
  ) {
    return TransactionByIdProvider(
      id,
    );
  }

  @override
  TransactionByIdProvider getProviderOverride(
    covariant TransactionByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionByIdProvider';
}

/// See also [transactionById].
class TransactionByIdProvider
    extends AutoDisposeStreamProvider<DebtTransaction?> {
  /// See also [transactionById].
  TransactionByIdProvider(
    int id,
  ) : this._internal(
          (ref) => transactionById(
            ref as TransactionByIdRef,
            id,
          ),
          from: transactionByIdProvider,
          name: r'transactionByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionByIdHash,
          dependencies: TransactionByIdFamily._dependencies,
          allTransitiveDependencies:
              TransactionByIdFamily._allTransitiveDependencies,
          id: id,
        );

  TransactionByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Stream<DebtTransaction?> Function(TransactionByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionByIdProvider._internal(
        (ref) => create(ref as TransactionByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DebtTransaction?> createElement() {
    return _TransactionByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TransactionByIdRef on AutoDisposeStreamProviderRef<DebtTransaction?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _TransactionByIdProviderElement
    extends AutoDisposeStreamProviderElement<DebtTransaction?>
    with TransactionByIdRef {
  _TransactionByIdProviderElement(super.provider);

  @override
  int get id => (origin as TransactionByIdProvider).id;
}

String _$paymentsForTransactionHash() =>
    r'01bf51024df3245c8b6157e14c5bb42060c67d51';

/// See also [paymentsForTransaction].
@ProviderFor(paymentsForTransaction)
const paymentsForTransactionProvider = PaymentsForTransactionFamily();

/// See also [paymentsForTransaction].
class PaymentsForTransactionFamily extends Family<AsyncValue<List<Payment>>> {
  /// See also [paymentsForTransaction].
  const PaymentsForTransactionFamily();

  /// See also [paymentsForTransaction].
  PaymentsForTransactionProvider call(
    int transactionId,
  ) {
    return PaymentsForTransactionProvider(
      transactionId,
    );
  }

  @override
  PaymentsForTransactionProvider getProviderOverride(
    covariant PaymentsForTransactionProvider provider,
  ) {
    return call(
      provider.transactionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paymentsForTransactionProvider';
}

/// See also [paymentsForTransaction].
class PaymentsForTransactionProvider
    extends AutoDisposeStreamProvider<List<Payment>> {
  /// See also [paymentsForTransaction].
  PaymentsForTransactionProvider(
    int transactionId,
  ) : this._internal(
          (ref) => paymentsForTransaction(
            ref as PaymentsForTransactionRef,
            transactionId,
          ),
          from: paymentsForTransactionProvider,
          name: r'paymentsForTransactionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paymentsForTransactionHash,
          dependencies: PaymentsForTransactionFamily._dependencies,
          allTransitiveDependencies:
              PaymentsForTransactionFamily._allTransitiveDependencies,
          transactionId: transactionId,
        );

  PaymentsForTransactionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final int transactionId;

  @override
  Override overrideWith(
    Stream<List<Payment>> Function(PaymentsForTransactionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentsForTransactionProvider._internal(
        (ref) => create(ref as PaymentsForTransactionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionId: transactionId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Payment>> createElement() {
    return _PaymentsForTransactionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentsForTransactionProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PaymentsForTransactionRef on AutoDisposeStreamProviderRef<List<Payment>> {
  /// The parameter `transactionId` of this provider.
  int get transactionId;
}

class _PaymentsForTransactionProviderElement
    extends AutoDisposeStreamProviderElement<List<Payment>>
    with PaymentsForTransactionRef {
  _PaymentsForTransactionProviderElement(super.provider);

  @override
  int get transactionId =>
      (origin as PaymentsForTransactionProvider).transactionId;
}

String _$transactionsForPersonHash() =>
    r'9d359b065493a76b7722b493a5466570796d0606';

/// See also [transactionsForPerson].
@ProviderFor(transactionsForPerson)
const transactionsForPersonProvider = TransactionsForPersonFamily();

/// See also [transactionsForPerson].
class TransactionsForPersonFamily
    extends Family<AsyncValue<List<DebtTransaction>>> {
  /// See also [transactionsForPerson].
  const TransactionsForPersonFamily();

  /// See also [transactionsForPerson].
  TransactionsForPersonProvider call(
    int personId,
  ) {
    return TransactionsForPersonProvider(
      personId,
    );
  }

  @override
  TransactionsForPersonProvider getProviderOverride(
    covariant TransactionsForPersonProvider provider,
  ) {
    return call(
      provider.personId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionsForPersonProvider';
}

/// See also [transactionsForPerson].
class TransactionsForPersonProvider
    extends AutoDisposeStreamProvider<List<DebtTransaction>> {
  /// See also [transactionsForPerson].
  TransactionsForPersonProvider(
    int personId,
  ) : this._internal(
          (ref) => transactionsForPerson(
            ref as TransactionsForPersonRef,
            personId,
          ),
          from: transactionsForPersonProvider,
          name: r'transactionsForPersonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionsForPersonHash,
          dependencies: TransactionsForPersonFamily._dependencies,
          allTransitiveDependencies:
              TransactionsForPersonFamily._allTransitiveDependencies,
          personId: personId,
        );

  TransactionsForPersonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final int personId;

  @override
  Override overrideWith(
    Stream<List<DebtTransaction>> Function(TransactionsForPersonRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionsForPersonProvider._internal(
        (ref) => create(ref as TransactionsForPersonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DebtTransaction>> createElement() {
    return _TransactionsForPersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsForPersonProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TransactionsForPersonRef
    on AutoDisposeStreamProviderRef<List<DebtTransaction>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _TransactionsForPersonProviderElement
    extends AutoDisposeStreamProviderElement<List<DebtTransaction>>
    with TransactionsForPersonRef {
  _TransactionsForPersonProviderElement(super.provider);

  @override
  int get personId => (origin as TransactionsForPersonProvider).personId;
}

String _$personByIdHash() => r'57005c0253449c7fa520baa55961cd76cc07a217';

/// See also [personById].
@ProviderFor(personById)
const personByIdProvider = PersonByIdFamily();

/// See also [personById].
class PersonByIdFamily extends Family<AsyncValue<Person?>> {
  /// See also [personById].
  const PersonByIdFamily();

  /// See also [personById].
  PersonByIdProvider call(
    int id,
  ) {
    return PersonByIdProvider(
      id,
    );
  }

  @override
  PersonByIdProvider getProviderOverride(
    covariant PersonByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personByIdProvider';
}

/// See also [personById].
class PersonByIdProvider extends AutoDisposeFutureProvider<Person?> {
  /// See also [personById].
  PersonByIdProvider(
    int id,
  ) : this._internal(
          (ref) => personById(
            ref as PersonByIdRef,
            id,
          ),
          from: personByIdProvider,
          name: r'personByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$personByIdHash,
          dependencies: PersonByIdFamily._dependencies,
          allTransitiveDependencies:
              PersonByIdFamily._allTransitiveDependencies,
          id: id,
        );

  PersonByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Person?> Function(PersonByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonByIdProvider._internal(
        (ref) => create(ref as PersonByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Person?> createElement() {
    return _PersonByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PersonByIdRef on AutoDisposeFutureProviderRef<Person?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _PersonByIdProviderElement
    extends AutoDisposeFutureProviderElement<Person?> with PersonByIdRef {
  _PersonByIdProviderElement(super.provider);

  @override
  int get id => (origin as PersonByIdProvider).id;
}

String _$markAsSettledHash() => r'ec55848fe728de6585a7e837fd63a3f61d7f1d2c';

/// See also [markAsSettled].
@ProviderFor(markAsSettled)
const markAsSettledProvider = MarkAsSettledFamily();

/// See also [markAsSettled].
class MarkAsSettledFamily extends Family<AsyncValue<void>> {
  /// See also [markAsSettled].
  const MarkAsSettledFamily();

  /// See also [markAsSettled].
  MarkAsSettledProvider call(
    int transactionId,
  ) {
    return MarkAsSettledProvider(
      transactionId,
    );
  }

  @override
  MarkAsSettledProvider getProviderOverride(
    covariant MarkAsSettledProvider provider,
  ) {
    return call(
      provider.transactionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'markAsSettledProvider';
}

/// See also [markAsSettled].
class MarkAsSettledProvider extends AutoDisposeFutureProvider<void> {
  /// See also [markAsSettled].
  MarkAsSettledProvider(
    int transactionId,
  ) : this._internal(
          (ref) => markAsSettled(
            ref as MarkAsSettledRef,
            transactionId,
          ),
          from: markAsSettledProvider,
          name: r'markAsSettledProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$markAsSettledHash,
          dependencies: MarkAsSettledFamily._dependencies,
          allTransitiveDependencies:
              MarkAsSettledFamily._allTransitiveDependencies,
          transactionId: transactionId,
        );

  MarkAsSettledProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final int transactionId;

  @override
  Override overrideWith(
    FutureOr<void> Function(MarkAsSettledRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkAsSettledProvider._internal(
        (ref) => create(ref as MarkAsSettledRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionId: transactionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _MarkAsSettledProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkAsSettledProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MarkAsSettledRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `transactionId` of this provider.
  int get transactionId;
}

class _MarkAsSettledProviderElement
    extends AutoDisposeFutureProviderElement<void> with MarkAsSettledRef {
  _MarkAsSettledProviderElement(super.provider);

  @override
  int get transactionId => (origin as MarkAsSettledProvider).transactionId;
}

String _$deleteTransactionHash() => r'4bd6d4cdbf18150b1c4021a81ccad7e64b0fa698';

/// See also [deleteTransaction].
@ProviderFor(deleteTransaction)
const deleteTransactionProvider = DeleteTransactionFamily();

/// See also [deleteTransaction].
class DeleteTransactionFamily extends Family<AsyncValue<void>> {
  /// See also [deleteTransaction].
  const DeleteTransactionFamily();

  /// See also [deleteTransaction].
  DeleteTransactionProvider call(
    int transactionId,
  ) {
    return DeleteTransactionProvider(
      transactionId,
    );
  }

  @override
  DeleteTransactionProvider getProviderOverride(
    covariant DeleteTransactionProvider provider,
  ) {
    return call(
      provider.transactionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deleteTransactionProvider';
}

/// See also [deleteTransaction].
class DeleteTransactionProvider extends AutoDisposeFutureProvider<void> {
  /// See also [deleteTransaction].
  DeleteTransactionProvider(
    int transactionId,
  ) : this._internal(
          (ref) => deleteTransaction(
            ref as DeleteTransactionRef,
            transactionId,
          ),
          from: deleteTransactionProvider,
          name: r'deleteTransactionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deleteTransactionHash,
          dependencies: DeleteTransactionFamily._dependencies,
          allTransitiveDependencies:
              DeleteTransactionFamily._allTransitiveDependencies,
          transactionId: transactionId,
        );

  DeleteTransactionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final int transactionId;

  @override
  Override overrideWith(
    FutureOr<void> Function(DeleteTransactionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeleteTransactionProvider._internal(
        (ref) => create(ref as DeleteTransactionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionId: transactionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _DeleteTransactionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteTransactionProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeleteTransactionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `transactionId` of this provider.
  int get transactionId;
}

class _DeleteTransactionProviderElement
    extends AutoDisposeFutureProviderElement<void> with DeleteTransactionRef {
  _DeleteTransactionProviderElement(super.provider);

  @override
  int get transactionId => (origin as DeleteTransactionProvider).transactionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
