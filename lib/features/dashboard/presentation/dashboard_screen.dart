import 'package:flutter/material.dart';
import 'package:debt_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/providers/locale_provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/person_balance_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _summaryAnimController;
  late final AnimationController _listAnimController;
  late final AnimationController _fabAnimController;
  late final AnimationController _langToggleController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _summaryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _langToggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // Start entrance animations with stagger
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _summaryAnimController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listAnimController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabAnimController.forward();
    });
  }

  @override
  void dispose() {
    _summaryAnimController.dispose();
    _listAnimController.dispose();
    _fabAnimController.dispose();
    _langToggleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onLanguageToggle() {
    _langToggleController.forward(from: 0);
    ref.read(localeNotifierProvider.notifier).toggle();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeNotifierProvider);
    final isArabic = locale.languageCode == 'ar';

    final appBarOpacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Animated app bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor:
                theme.colorScheme.surface.withOpacity(appBarOpacity),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title: Text(
                l10n.appTitle,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Language toggle with rotation animation
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_langToggleController),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      isArabic ? 'EN' : '\u0639',
                      key: ValueKey(isArabic),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  onPressed: _onLanguageToggle,
                  tooltip: l10n.language,
                ),
              ),
              // Settings button
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: summaryAsync.when(
              data: (summary) => _buildContent(summary, l10n, theme),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error, theme, l10n),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/add-transaction'),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addTransaction),
        ),
      ),
    );
  }

  Widget _buildContent(
    DashboardSummary summary,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _AnimatedSummaryCard(
                  title: l10n.iOwe,
                  amount: summary.totalIOwe,
                  color: AppTheme.debtColor,
                  icon: Icons.arrow_upward_rounded,
                  controller: _summaryAnimController,
                  beginInterval: 0.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnimatedSummaryCard(
                  title: l10n.owedToMe,
                  amount: summary.totalOwedToMe,
                  color: AppTheme.loanColor,
                  icon: Icons.arrow_downward_rounded,
                  controller: _summaryAnimController,
                  beginInterval: 0.15,
                ),
              ),
            ],
          ),
        ),

        // Net balance card
        _AnimatedNetBalance(
          totalIOwe: summary.totalIOwe,
          totalOwedToMe: summary.totalOwedToMe,
          controller: _summaryAnimController,
          l10n: l10n,
        ),

        const SizedBox(height: 16),

        if (summary.personBalances.isEmpty)
          _buildEmptyState(theme, l10n)
        else ...[
          // People header
          FadeTransition(
            opacity: _listAnimController,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
              child: Text(
                l10n.people,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Person cards with staggered animation
          ...List.generate(
            summary.personBalances.length,
            (index) {
              final pb = summary.personBalances[index];
              return PersonBalanceCard(
                personBalance: pb,
                index: index,
                controller: _listAnimController,
                onTap: () =>
                    context.push('/add-transaction?personId=${pb.person.id}'),
              );
            },
          ),
        ],

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _listAnimController,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatingEmptyIcon(),
              const SizedBox(height: 24),
              Text(
                l10n.noActiveDebts,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tapToAdd,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(
    Object error,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.errorLoading, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error.toString(), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Animated summary card with slide + fade + animated counter
class _AnimatedSummaryCard extends StatelessWidget {
  const _AnimatedSummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.controller,
    required this.beginInterval,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final AnimationController controller;
  final double beginInterval;

  static final _formatter = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    final endInterval = (beginInterval + 0.6).clamp(0.0, 1.0);

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(beginInterval, endInterval, curve: Curves.easeOutCubic),
    ));

    final fadeAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(beginInterval, (beginInterval + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                color.withOpacity(0.12),
                color.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PulsingIcon(icon: icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: amount),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return Text(
                    _formatter.format(val),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pulsing icon widget
class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(widget.icon, color: widget.color, size: 16),
      ),
    );
  }
}

/// Animated net balance indicator
class _AnimatedNetBalance extends StatelessWidget {
  const _AnimatedNetBalance({
    required this.totalIOwe,
    required this.totalOwedToMe,
    required this.controller,
    required this.l10n,
  });

  final double totalIOwe;
  final double totalOwedToMe;
  final AnimationController controller;
  final AppLocalizations l10n;

  static final _formatter = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    final net = totalOwedToMe - totalIOwe;
    final isPositive = net >= 0;
    final color = isPositive ? AppTheme.loanColor : AppTheme.debtColor;

    final fadeAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.netBalance,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: net.abs()),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: color,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatter.format(val),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating empty state icon with gentle bounce animation
class _FloatingEmptyIcon extends StatefulWidget {
  @override
  State<_FloatingEmptyIcon> createState() => _FloatingEmptyIconState();
}

class _FloatingEmptyIconState extends State<_FloatingEmptyIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.loanColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }
}
