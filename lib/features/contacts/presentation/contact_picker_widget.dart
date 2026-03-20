import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/db/models/person.dart';
import '../providers/contact_provider.dart';

class ContactPickerWidget extends ConsumerStatefulWidget {
  const ContactPickerWidget({super.key, this.onPersonSelected});

  final void Function(Person person)? onPersonSelected;

  @override
  ConsumerState<ContactPickerWidget> createState() =>
      _ContactPickerWidgetState();
}

class _ContactPickerWidgetState extends ConsumerState<ContactPickerWidget>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _query = '';
  late final AnimationController _listAnimController;

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneContactsAsync = ref.watch(phoneContactsProvider);
    final savedPersonsAsync = ref.watch(savedPersonsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Search field
        Padding(
          padding: const EdgeInsets.all(16),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchOrType,
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.white.withOpacity(0.4)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: Colors.white.withOpacity(0.4)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              // "Add manually" option
              if (_query.isNotEmpty)
                _buildAnimatedTile(
                  index: 0,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(
                      l10n.addNameManually(_query),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => _addManually(_query),
                  ),
                ),

              // Saved persons
              savedPersonsAsync.when(
                data: (persons) {
                  final filtered = _query.isEmpty
                      ? persons
                      : persons
                          .where((p) => p.name
                              .toLowerCase()
                              .contains(_query.toLowerCase()))
                          .toList();

                  if (filtered.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 8, 16, 8),
                          child: Text(
                            l10n.recent,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ...filtered.asMap().entries.map(
                              (entry) => _buildAnimatedTile(
                                index: entry.key + 1,
                                child: ListTile(
                                  leading: _GradientAvatar(
                                      name: entry.value.name),
                                  title: Text(
                                    entry.value.name,
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                  subtitle: entry.value.phoneNumber != null
                                      ? Text(
                                          entry.value.phoneNumber!,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.4),
                                          ),
                                        )
                                      : null,
                                  onTap: () =>
                                      _selectPerson(entry.value),
                                ),
                              ),
                            ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Phone contacts
              phoneContactsAsync.when(
                data: (contacts) {
                  final filtered = _query.isEmpty
                      ? contacts
                      : contacts
                          .where((c) => (c.displayName ?? '')
                              .toLowerCase()
                              .contains(_query.toLowerCase()))
                          .toList();

                  if (filtered.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 8, 16, 8),
                        child: Text(
                          l10n.phoneContacts,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...filtered.take(50).toList().asMap().entries.map(
                            (entry) => _buildAnimatedTile(
                              index: entry.key + 5,
                              child: ListTile(
                                leading: _GradientAvatar(
                                    name: entry.value.displayName ?? ''),
                                title: Text(
                                  entry.value.displayName ?? '',
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                                subtitle: entry.value.phones.isNotEmpty
                                    ? Text(
                                        entry.value.phones.first.number,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.4),
                                        ),
                                      )
                                    : null,
                                onTap: () =>
                                    _selectContact(entry.value),
                              ),
                            ),
                          ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.couldNotLoadContacts,
                    style: const TextStyle(color: AppTheme.debtColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTile({required int index, required Widget child}) {
    final start = (index * 0.04).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(start + 0.1, 1.0);

    final fadeAnim = CurvedAnimation(
      parent: _listAnimController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _listAnimController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }

  Future<void> _addManually(String name) async {
    final saved = await ref.read(
      getOrCreatePersonProvider(personName: name).future,
    );
    if (mounted) {
      widget.onPersonSelected?.call(saved);
      Navigator.of(context).pop();
    }
  }

  void _selectPerson(Person person) {
    widget.onPersonSelected?.call(person);
    Navigator.of(context).pop();
  }

  Future<void> _selectContact(fc.Contact contact) async {
    final phone =
        contact.phones.isNotEmpty ? contact.phones.first.number : null;

    final person = await ref.read(
      getOrCreatePersonProvider(
        personName: contact.displayName ?? '',
        phoneNumber: phone,
        isFromContacts: true,
      ).future,
    );

    if (mounted) {
      widget.onPersonSelected?.call(person);
      Navigator.of(context).pop();
    }
  }
}

/// Gradient avatar used in contact picker — dark theme
class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    final gradientColors = AppTheme.avatarGradient(name);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: gradientColors,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
