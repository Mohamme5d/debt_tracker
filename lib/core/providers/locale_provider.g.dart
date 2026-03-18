// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run build_runner build --delete-conflicting-outputs

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeNotifierHash() => r'locale_notifier_hash';

/// See also [LocaleNotifier].
@ProviderFor(LocaleNotifier)
final localeNotifierProvider =
    AutoDisposeNotifierProvider<LocaleNotifier, Locale>.internal(
  LocaleNotifier.new,
  name: r'localeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleNotifier = AutoDisposeNotifier<Locale>;
