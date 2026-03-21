// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$phoneContactsHash() => r'cb40a6e3977ee31c81a01069a7be56570c8542a4';

/// See also [phoneContacts].
@ProviderFor(phoneContacts)
final phoneContactsProvider =
    AutoDisposeFutureProvider<List<fc.Contact>>.internal(
  phoneContacts,
  name: r'phoneContactsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$phoneContactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PhoneContactsRef = AutoDisposeFutureProviderRef<List<fc.Contact>>;
String _$savedPersonsHash() => r'a798143b3b885f846f627f9a8b5135b8979ca18e';

/// See also [savedPersons].
@ProviderFor(savedPersons)
final savedPersonsProvider = AutoDisposeFutureProvider<List<Person>>.internal(
  savedPersons,
  name: r'savedPersonsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$savedPersonsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SavedPersonsRef = AutoDisposeFutureProviderRef<List<Person>>;
String _$getOrCreatePersonHash() => r'771b07974268b08f2e820da9b2bd37500fd2da80';

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

/// See also [getOrCreatePerson].
@ProviderFor(getOrCreatePerson)
const getOrCreatePersonProvider = GetOrCreatePersonFamily();

/// See also [getOrCreatePerson].
class GetOrCreatePersonFamily extends Family<AsyncValue<Person>> {
  /// See also [getOrCreatePerson].
  const GetOrCreatePersonFamily();

  /// See also [getOrCreatePerson].
  GetOrCreatePersonProvider call({
    required String personName,
    String? phoneNumber,
    bool isFromContacts = false,
  }) {
    return GetOrCreatePersonProvider(
      personName: personName,
      phoneNumber: phoneNumber,
      isFromContacts: isFromContacts,
    );
  }

  @override
  GetOrCreatePersonProvider getProviderOverride(
    covariant GetOrCreatePersonProvider provider,
  ) {
    return call(
      personName: provider.personName,
      phoneNumber: provider.phoneNumber,
      isFromContacts: provider.isFromContacts,
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
  String? get name => r'getOrCreatePersonProvider';
}

/// See also [getOrCreatePerson].
class GetOrCreatePersonProvider extends AutoDisposeFutureProvider<Person> {
  /// See also [getOrCreatePerson].
  GetOrCreatePersonProvider({
    required String personName,
    String? phoneNumber,
    bool isFromContacts = false,
  }) : this._internal(
          (ref) => getOrCreatePerson(
            ref as GetOrCreatePersonRef,
            personName: personName,
            phoneNumber: phoneNumber,
            isFromContacts: isFromContacts,
          ),
          from: getOrCreatePersonProvider,
          name: r'getOrCreatePersonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getOrCreatePersonHash,
          dependencies: GetOrCreatePersonFamily._dependencies,
          allTransitiveDependencies:
              GetOrCreatePersonFamily._allTransitiveDependencies,
          personName: personName,
          phoneNumber: phoneNumber,
          isFromContacts: isFromContacts,
        );

  GetOrCreatePersonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personName,
    required this.phoneNumber,
    required this.isFromContacts,
  }) : super.internal();

  final String personName;
  final String? phoneNumber;
  final bool isFromContacts;

  @override
  Override overrideWith(
    FutureOr<Person> Function(GetOrCreatePersonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetOrCreatePersonProvider._internal(
        (ref) => create(ref as GetOrCreatePersonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personName: personName,
        phoneNumber: phoneNumber,
        isFromContacts: isFromContacts,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Person> createElement() {
    return _GetOrCreatePersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOrCreatePersonProvider &&
        other.personName == personName &&
        other.phoneNumber == phoneNumber &&
        other.isFromContacts == isFromContacts;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personName.hashCode);
    hash = _SystemHash.combine(hash, phoneNumber.hashCode);
    hash = _SystemHash.combine(hash, isFromContacts.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetOrCreatePersonRef on AutoDisposeFutureProviderRef<Person> {
  /// The parameter `personName` of this provider.
  String get personName;

  /// The parameter `phoneNumber` of this provider.
  String? get phoneNumber;

  /// The parameter `isFromContacts` of this provider.
  bool get isFromContacts;
}

class _GetOrCreatePersonProviderElement
    extends AutoDisposeFutureProviderElement<Person> with GetOrCreatePersonRef {
  _GetOrCreatePersonProviderElement(super.provider);

  @override
  String get personName => (origin as GetOrCreatePersonProvider).personName;
  @override
  String? get phoneNumber => (origin as GetOrCreatePersonProvider).phoneNumber;
  @override
  bool get isFromContacts =>
      (origin as GetOrCreatePersonProvider).isFromContacts;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
