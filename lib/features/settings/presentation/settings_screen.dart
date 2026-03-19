import 'package:flutter/material.dart';
import 'package:debt_tracker/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers/locale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _flagFlipController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _flagFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _flagFlipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeNotifierProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Language section
          _buildStaggeredChild(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageCard(
                  theme: theme,
                  isArabic: isArabic,
                  l10n: l10n,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Language toggle tiles
          _buildStaggeredChild(
            1,
            _LanguageTile(
              flag: '\u{1F1F8}\u{1F1E6}',
              label: l10n.arabic,
              sublabel: 'العربية',
              isSelected: isArabic,
              onTap: () {
                _flagFlipController.forward(from: 0);
                ref
                    .read(localeNotifierProvider.notifier)
                    .setLocale(const Locale('ar'));
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildStaggeredChild(
            2,
            _LanguageTile(
              flag: '\u{1F1EC}\u{1F1E7}',
              label: l10n.english,
              sublabel: 'English',
              isSelected: !isArabic,
              onTap: () {
                _flagFlipController.forward(from: 0);
                ref
                    .read(localeNotifierProvider.notifier)
                    .setLocale(const Locale('en'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredChild(int index, Widget child) {
    final start = (index * 0.1).clamp(0.0, 0.5);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    final fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: child,
      ),
    );
  }

  Widget _buildLanguageCard({
    required ThemeData theme,
    required bool isArabic,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppTheme.primaryColor.withOpacity(0.08),
            AppTheme.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Animated flag swap
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              isArabic ? '\u{1F1F8}\u{1F1E6}' : '\u{1F1EC}\u{1F1E7}',
              key: ValueKey(isArabic),
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isArabic ? l10n.arabic : l10n.english,
                    key: ValueKey('label_$isArabic'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isArabic ? 'Arabic - RTL' : 'English - LTR',
                    key: ValueKey('sub_$isArabic'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Toggle button
          _AnimatedLanguageToggle(
            isArabic: isArabic,
            onToggle: () =>
                ref.read(localeNotifierProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}

/// Animated language toggle switch
class _AnimatedLanguageToggle extends StatelessWidget {
  const _AnimatedLanguageToggle({
    required this.isArabic,
    required this.onToggle,
  });

  final bool isArabic;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 64,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: isArabic
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withOpacity(0.3),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment:
              isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isArabic ? 'ع' : 'A',
                  key: ValueKey(isArabic),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual language tile
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.08)
              : theme.cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey('checked'),
                      color: AppTheme.primaryColor,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      key: const ValueKey('unchecked'),
                      color: Colors.grey[300],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
