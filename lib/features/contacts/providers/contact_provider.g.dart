// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run build_runner build --delete-conflicting-outputs

part of 'contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$phoneContactsHash() => r'phoneContacts1';

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

String _$savedPersonsHash() => r'savedPersons1';

/// See also [savedPersons].
@ProviderFor(savedPersons)
final savedPersonsProvider =
    AutoDisposeFutureProvider<List<Person>>.internal(
  savedPersons,
  name: r'savedPersonsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedPersonsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SavedPersonsRef = AutoDisposeFutureProviderRef<List<Person>>;

String _$getOrCreatePersonHash() => r'getOrCreate1';

/// See also [getOrCreatePerson].
@ProviderFor(getOrCreatePerson)
const getOrCreatePersonProvider = GetOrCreatePersonFamily();

class GetOrCreatePersonFamily extends Family<AsyncValue<Person>> {
  const GetOrCreatePersonFamily();

  GetOrCreatePersonProvider call({
    required String name,
    String? phoneNumber,
    bool isFromContacts = false,
  }) {
    return GetOrCreatePersonProvider(
      name: name,
      phoneNumber: phoneNumber,
      isFromContacts: isFromContacts,
    );
  }

  @override
  String toString() => 'getOrCreatePersonProvider';
}

class GetOrCreatePersonProvider extends AutoDisposeFutureProvider<Person> {
  GetOrCreatePersonProvider({
    required this.name,
    this.phoneNumber,
    this.isFromContacts = false,
  }) : super.internal(
          (ref) => getOrCreatePerson(
            ref,
            name: name,
            phoneNumber: phoneNumber,
            isFromContacts: isFromContacts,
          ),
          from: getOrCreatePersonProvider,
          name: r'getOrCreatePersonProvider',
          debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$getOrCreatePersonHash,
          dependencies: null,
          allTransitiveDependencies: null,
          name: name,
          phoneNumber: phoneNumber,
          isFromContacts: isFromContacts,
        );

  final String name;
  final String? phoneNumber;
  final bool isFromContacts;

  @override
  bool operator ==(Object other) {
    return other is GetOrCreatePersonProvider &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.isFromContacts == isFromContacts;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, name.hashCode);
    hash = _SystemHash.combine(hash, phoneNumber.hashCode);
    hash = _SystemHash.combine(hash, isFromContacts.hashCode);
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
