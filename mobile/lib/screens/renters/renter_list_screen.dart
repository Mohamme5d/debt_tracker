import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/renter_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/list_card_widgets.dart';
import '../../core/theme/app_colors.dart';

class RenterListScreen extends StatefulWidget {
  const RenterListScreen({super.key});

  @override
  State<RenterListScreen> createState() => _RenterListScreenState();
}

class _RenterListScreenState extends State<RenterListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RenterProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isOwner = context.watch<AuthProvider>().isOwner;

    return Consumer<RenterProvider>(
      builder: (context, provider, _) {
        final filtered = provider.renters
            .where((r) => r.name.toLowerCase().contains(_search.toLowerCase()) ||
                (r.phone ?? '').contains(_search))
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(l.renters)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/renters/new'),
            icon: const Icon(Icons.add),
            label: Text(l.add),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              ListSearchBar(
                hint: l.searchRenter,
                onChanged: (v) => setState(() => _search = v),
              ),
              Expanded(
                child: provider.loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : filtered.isEmpty
                        ? EmptyListState(l.noData, Icons.people_rounded)
                        : RefreshIndicator(
                            color: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            onRefresh: provider.load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final r = filtered[i];
                                return AnimatedListItem(
                                  index: i,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SwipeCard(
                                      onEdit: () => context.push('/renters/edit/${r.id}'),
                                      onDelete: isOwner
                                          ? () async {
                                              if (await showConfirmDialog(context)) {
                                                if (!context.mounted) return;
                                                await provider.remove(r.id!);
                                              }
                                            }
                                          : null,
                                      editLabel: l.edit,
                                      deleteLabel: l.delete,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(children: [
                                          GradientAvatar(name: r.name),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  Expanded(
                                                    child: Text(r.name,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 15)),
                                                  ),
                                                  _statusBadge(r.status),
                                                ]),
                                                if (r.phone != null) ...[
                                                  const SizedBox(height: 4),
                                                  Row(children: [
                                                    const Icon(Icons.phone_outlined, size: 13, color: AppColors.textSecondary),
                                                    const SizedBox(width: 4),
                                                    Text(r.phone!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                                  ]),
                                                ],
                                                if (r.email != null) ...[
                                                  const SizedBox(height: 2),
                                                  Row(children: [
                                                    const Icon(Icons.email_outlined, size: 13, color: AppColors.textSecondary),
                                                    const SizedBox(width: 4),
                                                    Text(r.email!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                                  ]),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
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

Widget _statusBadge(String? status) {
  if (status == null) return const SizedBox.shrink();
  final color = status == 'Approved'
      ? const Color(0xFF10B981)
      : status == 'Rejected'
          ? const Color(0xFFF43F5E)
          : const Color(0xFFF59E0B);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Text(status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}
