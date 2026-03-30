import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/rent_contract_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/list_card_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/num_format.dart';

class RentContractListScreen extends StatefulWidget {
  const RentContractListScreen({super.key});

  @override
  State<RentContractListScreen> createState() => _RentContractListScreenState();
}

class _RentContractListScreenState extends State<RentContractListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentContractProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AuthProvider>().isOwner;

    return Consumer<RentContractProvider>(
      builder: (context, provider, _) {
        final filtered = provider.contracts
            .where((c) =>
                c.renterName.toLowerCase().contains(_search.toLowerCase()) ||
                c.apartmentName.toLowerCase().contains(_search.toLowerCase()))
            .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('عقود / Contracts')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/contracts/new'),
            icon: const Icon(Icons.add),
            label: const Text('إضافة / Add'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              ListSearchBar(
                hint: 'بحث عقد... / Search contract...',
                onChanged: (v) => setState(() => _search = v),
              ),
              Expanded(
                child: provider.loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : filtered.isEmpty
                        ? EmptyListState('لا توجد عقود', Icons.description_rounded)
                        : RefreshIndicator(
                            color: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            onRefresh: provider.load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final c = filtered[i];
                                final statusColor = c.isActive
                                    ? AppColors.success
                                    : AppColors.textSecondary;

                                return AnimatedListItem(
                                  index: i,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SwipeCard(
                                      onEdit: () => context.push('/contracts/edit/${c.id}'),
                                      onDelete: isOwner
                                          ? () async {
                                              if (await showConfirmDialog(context)) {
                                                if (!context.mounted) return;
                                                await provider.remove(c.id!);
                                              }
                                            }
                                          : null,
                                      editLabel: 'تعديل',
                                      deleteLabel: 'حذف',
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: AppColors.gradientPrimary,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(Icons.description_rounded,
                                                    color: Colors.white, size: 22),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(c.renterName,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 15)),
                                                    const SizedBox(height: 2),
                                                    Row(children: [
                                                      const Icon(Icons.apartment_outlined,
                                                          size: 13, color: AppColors.textSecondary),
                                                      const SizedBox(width: 4),
                                                      Text(c.apartmentName,
                                                          style: const TextStyle(
                                                              color: AppColors.textSecondary,
                                                              fontSize: 12)),
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                                ),
                                                child: Text(
                                                  c.isActive ? 'نشط' : 'منتهي',
                                                  style: TextStyle(
                                                      color: statusColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ]),
                                            const SizedBox(height: 10),
                                            Row(children: [
                                              _InfoChip(
                                                icon: Icons.payments_outlined,
                                                text: '${NumFormat.fmt(c.monthlyRent)} / شهر',
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              _InfoChip(
                                                icon: Icons.calendar_today_outlined,
                                                text: c.startDate,
                                                color: AppColors.textSecondary,
                                              ),
                                            ]),
                                          ],
                                        ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
