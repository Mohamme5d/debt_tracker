// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run build_runner build --delete-conflicting-outputs

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addTransactionUseCaseHash() => r'addTxUseCase1';

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

String _$recordPaymentUseCaseHash() => r'recPayUseCase1';

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

typedef RecordPaymentUseCaseRef
    = AutoDisposeProviderRef<RecordPaymentUseCase>;

String _$transactionByIdHash() => r'txById123';

/// See also [transactionById].
@ProviderFor(transactionById)
const transactionByIdProvider = TransactionByIdFamily();

class TransactionByIdFamily extends Family<AsyncValue<DebtTransaction?>> {
  const TransactionByIdFamily();

  TransactionByIdProvider call(int id) {
    return TransactionByIdProvider(id);
  }

  @override
  String toString() => 'transactionByIdProvider';
}

class TransactionByIdProvider
    extends AutoDisposeStreamProvider<DebtTransaction?> {
  TransactionByIdProvider(this.id)
      : super.internal(
          (ref) => transactionById(ref, id),
          from: transactionByIdProvider,
          name: r'transactionByIdProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$transactionByIdHash,
          dependencies: null,
          allTransitiveDependencies: null,
          id: id,
        );

  final int id;

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

String _$paymentsForTransactionHash() => r'payForTx123';

/// See also [paymentsForTransaction].
@ProviderFor(paymentsForTransaction)
const paymentsForTransactionProvider = PaymentsForTransactionFamily();

class PaymentsForTransactionFamily
    extends Family<AsyncValue<List<Payment>>> {
  const PaymentsForTransactionFamily();

  PaymentsForTransactionProvider call(int transactionId) {
    return PaymentsForTransactionProvider(transactionId);
  }

  @override
  String toString() => 'paymentsForTransactionProvider';
}

class PaymentsForTransactionProvider
    extends AutoDisposeStreamProvider<List<Payment>> {
  PaymentsForTransactionProvider(this.transactionId)
      : super.internal(
          (ref) => paymentsForTransaction(ref, transactionId),
          from: paymentsForTransactionProvider,
          name: r'paymentsForTransactionProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$paymentsForTransactionHash,
          dependencies: null,
          allTransitiveDependencies: null,
          transactionId: transactionId,
        );

  final int transactionId;

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

String _$transactionsForPersonHash() => r'txForPerson1';

/// See also [transactionsForPerson].
@ProviderFor(transactionsForPerson)
const transactionsForPersonProvider = TransactionsForPersonFamily();

class TransactionsForPersonFamily
    extends Family<AsyncValue<List<DebtTransaction>>> {
  const TransactionsForPersonFamily();

  TransactionsForPersonProvider call(int personId) {
    return TransactionsForPersonProvider(personId);
  }

  @override
  String toString() => 'transactionsForPersonProvider';
}

class TransactionsForPersonProvider
    extends AutoDisposeStreamProvider<List<DebtTransaction>> {
  TransactionsForPersonProvider(this.personId)
      : super.internal(
          (ref) => transactionsForPerson(ref, personId),
          from: transactionsForPersonProvider,
          name: r'transactionsForPersonProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$transactionsForPersonHash,
          dependencies: null,
          allTransitiveDependencies: null,
          personId: personId,
        );

  final int personId;

  @override
  bool operator ==(Object other) {
    return other is TransactionsForPersonProvider &&
        other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);
    return _SystemHash.finish(hash);
  }
}

String _$personByIdHash() => r'personById1';

/// See also [personById].
@ProviderFor(personById)
const personByIdProvider = PersonByIdFamily();

class PersonByIdFamily extends Family<AsyncValue<Person?>> {
  const PersonByIdFamily();

  PersonByIdProvider call(int id) {
    return PersonByIdProvider(id);
  }

  @override
  String toString() => 'personByIdProvider';
}

class PersonByIdProvider extends AutoDisposeFutureProvider<Person?> {
  PersonByIdProvider(this.id)
      : super.internal(
          (ref) => personById(ref, id),
          from: personByIdProvider,
          name: r'personByIdProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$personByIdHash,
          dependencies: null,
          allTransitiveDependencies: null,
          id: id,
        );

  final int id;

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

String _$markAsSettledHash() => r'markSettled1';

/// See also [markAsSettled].
@ProviderFor(markAsSettled)
const markAsSettledProvider = MarkAsSettledFamily();

class MarkAsSettledFamily extends Family<AsyncValue<void>> {
  const MarkAsSettledFamily();

  MarkAsSettledProvider call(int transactionId) {
    return MarkAsSettledProvider(transactionId);
  }

  @override
  String toString() => 'markAsSettledProvider';
}

class MarkAsSettledProvider extends AutoDisposeFutureProvider<void> {
  MarkAsSettledProvider(this.transactionId)
      : super.internal(
          (ref) => markAsSettled(ref, transactionId),
          from: markAsSettledProvider,
          name: r'markAsSettledProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$markAsSettledHash,
          dependencies: null,
          allTransitiveDependencies: null,
          transactionId: transactionId,
        );

  final int transactionId;

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

String _$deleteTransactionHash() => r'deleteTx1';

/// See also [deleteTransaction].
@ProviderFor(deleteTransaction)
const deleteTransactionProvider = DeleteTransactionFamily();

class DeleteTransactionFamily extends Family<AsyncValue<void>> {
  const DeleteTransactionFamily();

  DeleteTransactionProvider call(int transactionId) {
    return DeleteTransactionProvider(transactionId);
  }

  @override
  String toString() => 'deleteTransactionProvider';
}

class DeleteTransactionProvider extends AutoDisposeFutureProvider<void> {
  DeleteTransactionProvider(this.transactionId)
      : super.internal(
          (ref) => deleteTransaction(ref, transactionId),
          from: deleteTransactionProvider,
          name: r'deleteTransactionProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$deleteTransactionHash,
          dependencies: null,
          allTransitiveDependencies: null,
          transactionId: transactionId,
        );

  final int transactionId;

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

class _SystemHash {
  static int combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}
