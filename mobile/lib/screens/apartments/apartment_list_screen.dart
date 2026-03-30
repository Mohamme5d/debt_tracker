import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/list_card_widgets.dart';
import '../../core/theme/app_colors.dart';

class ApartmentListScreen extends StatefulWidget {
  const ApartmentListScreen({super.key});

  @override
  State<ApartmentListScreen> createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends State<ApartmentListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApartmentProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isOwner = context.watch<AuthProvider>().isOwner;

    return Consumer<ApartmentProvider>(
      builder: (context, provider, _) {
        final filtered = provider.apartments
            .where((a) =>
                a.name.toLowerCase().contains(_search.toLowerCase()) ||
                (a.address ?? '').toLowerCase().contains(_search.toLowerCase()))
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(l.apartments)),
          floatingActionButton: isOwner
              ? FloatingActionButton.extended(
                  onPressed: () => context.push('/apartments/new'),
                  icon: const Icon(Icons.add),
                  label: Text(l.add),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                )
              : null,
          body: Column(
            children: [
              ListSearchBar(
                hint: l.searchApartment,
                onChanged: (v) => setState(() => _search = v),
              ),
              Expanded(
                child: provider.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : filtered.isEmpty
                        ? EmptyListState(l.noData, Icons.apartment_rounded)
                        : RefreshIndicator(
                            color: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            onRefresh: provider.load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final apt = filtered[i];
                                final cardChild = Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(children: [
                                    LeadingIcon(
                                      icon: Icons.apartment_rounded,
                                      gradient: AppColors.gradientPrimary,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(apt.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  fontSize: 15)),
                                          const SizedBox(height: 5),
                                          Row(children: [
                                            Icon(
                                                Icons
                                                    .location_on_outlined,
                                                size: 13,
                                                color: Colors.white
                                                    .withValues(
                                                        alpha: 0.4)),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(apt.address ?? '',
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha:
                                                                  0.55),
                                                      fontSize: 13)),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white
                                          .withValues(alpha: 0.3),
                                      size: 18,
                                    ),
                                  ]),
                                );

                                return AnimatedListItem(
                                  index: i,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SwipeCard(
                                      onEdit: isOwner
                                          ? () => context
                                              .push('/apartments/edit/${apt.id}')
                                          : null,
                                      onDelete: isOwner
                                          ? () async {
                                              if (await showConfirmDialog(context)) {
                                                if (!context.mounted) return;
                                                final ok =
                                                    await provider.remove(apt.id!);
                                                if (!ok && context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              provider.error ??
                                                                  l.error)));
                                                }
                                              }
                                            }
                                          : null,
                                      editLabel: l.edit,
                                      deleteLabel: l.delete,
                                      child: cardChild,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
