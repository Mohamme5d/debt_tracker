import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../app/theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/person.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../backup/services/backup_service.dart';
import '../../export/pdf_export_service.dart';
import '../../security/presentation/passcode_screen.dart';
import '../../security/providers/security_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  bool _isBackingUp = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final start = (index * 0.08).clamp(0.0, 0.5);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeNotifierProvider);
    final isArabic = locale.languageCode == 'ar';
    final security = ref.watch(securityNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Section
          _stagger(0, _sectionHeader(l10n.security, Icons.lock_rounded)),
          _stagger(
            1,
            GradientCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _switchTile(
                    icon: Icons.fingerprint_rounded,
                    title: l10n.biometricAuth,
                    subtitle: l10n.biometricSubtitle,
                    value: security.isBiometricEnabled,
                    onChanged: (val) async {
                      final notifier =
                          ref.read(securityNotifierProvider.notifier);
                      if (val) {
                        // Must have passcode enabled first
                        if (!security.isPasscodeEnabled) {
                          if (!mounted) return;
                          final shouldSetup = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppTheme.surfaceDark,
                              title: Text(
                                isArabic ? 'مطلوب رمز المرور' : 'Passcode Required',
                                style: const TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                isArabic
                                    ? 'يجب تفعيل رمز المرور أولاً قبل تفعيل بصمة الإصبع أو الوجه.\n\nهل تريد إعداد رمز المرور الآن؟'
                                    : 'You must enable a passcode first before activating biometric authentication.\n\nWould you like to set up a passcode now?',
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    isArabic ? 'إلغاء' : 'Cancel',
                                    style: const TextStyle(color: AppTheme.primaryColor),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    isArabic ? 'إعداد رمز المرور' : 'Set Passcode',
                                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (shouldSetup == true && mounted) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PasscodeScreen(mode: PasscodeMode.set),
                              ),
                            );
                            // After passcode setup, check again and enable biometric if passcode is now set
                            final updatedSecurity = ref.read(securityNotifierProvider);
                            if (!updatedSecurity.isPasscodeEnabled) return;
                            // Fall through to enable biometric
                          } else {
                            return;
                          }
                        }
                        final available = await notifier.isBiometricAvailable();
                        if (!available && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.biometricNotAvailable)),
                          );
                          return;
                        }
                      }
                      await notifier.toggleBiometric(val);
                    },
                  ),
                  const Divider(
                      height: 1,
                      indent: 56,
                      color: AppTheme.borderDark),
                  _switchTile(
                    icon: Icons.pin_rounded,
                    title: l10n.passcode,
                    subtitle: l10n.passcodeSubtitle,
                    value: security.isPasscodeEnabled,
                    onChanged: (val) async {
                      if (val) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PasscodeScreen(
                              mode: PasscodeMode.set,
                            ),
                          ),
                        );
                      } else {
                        final notifier = ref.read(securityNotifierProvider.notifier);
                        // If biometric is enabled, disable it first since passcode is required
                        if (security.isBiometricEnabled) {
                          await notifier.toggleBiometric(false);
                        }
                        await notifier.removePasscode();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.passcodeRemoved)),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(
                      height: 1,
                      indent: 56,
                      color: AppTheme.borderDark),
                  _autoLockTile(l10n, security),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Backup & Sync Section
          _stagger(
              2, _sectionHeader(l10n.backupSync, Icons.cloud_rounded)),
          _stagger(
            3,
            GradientCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  if (Platform.isIOS)
                    _actionTile(
                      icon: Icons.cloud_upload_rounded,
                      title: l10n.icloudBackup,
                      subtitle: l10n.icloudSubtitle,
                      onTap: _backupToiCloud,
                      isLoading: _isBackingUp,
                    ),
                  if (Platform.isIOS)
                    const Divider(
                        height: 1,
                        indent: 56,
                        color: AppTheme.borderDark),
                  _actionTile(
                    icon: Icons.add_to_drive_rounded,
                    title: l10n.googleDriveBackup,
                    subtitle: l10n.googleDriveSubtitle,
                    onTap: _backupToGoogleDrive,
                    isLoading: _isBackingUp,
                  ),
                  const Divider(
                      height: 1,
                      indent: 56,
                      color: AppTheme.borderDark),
                  _actionTile(
                    icon: Icons.save_alt_rounded,
                    title: l10n.localBackup,
                    subtitle: l10n.localBackupSubtitle,
                    onTap: _backupToLocal,
                    isLoading: _isBackingUp,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Import / Restore Section
          _stagger(
              4, _sectionHeader(l10n.importBackup, Icons.restore_rounded)),
          _stagger(
            5,
            GradientCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.add_to_drive_rounded,
                    title: l10n.importFromGoogleDrive,
                    subtitle: l10n.importBackupSubtitle,
                    onTap: _restoreFromGoogleDrive,
                    isLoading: _isBackingUp,
                  ),
                  const Divider(
                      height: 1, indent: 56, color: AppTheme.borderDark),
                  _actionTile(
                    icon: Icons.folder_open_rounded,
                    title: l10n.importFromLocalFile,
                    subtitle: l10n.importBackupSubtitle,
                    onTap: _restoreFromLocalFile,
                    isLoading: _isBackingUp,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data Export Section
          _stagger(
              4,
              _sectionHeader(
                  l10n.dataExport, Icons.description_rounded)),
          _stagger(
            5,
            GradientCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.picture_as_pdf_rounded,
                    title: l10n.exportPdf,
                    subtitle: l10n.exportPdfSubtitle,
                    onTap: () => _showExportSheet(l10n),
                    isLoading: _isExporting,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Section
          _stagger(
              6, _sectionHeader(l10n.app, Icons.settings_rounded)),
          _stagger(
            7,
            GradientCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _languageTile(l10n, isArabic),
                  const Divider(
                      height: 1,
                      indent: 56,
                      color: AppTheme.borderDark),
                  _infoTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.appVersion,
                    trailing: '1.0.0',
                  ),
                  const Divider(height: 1, indent: 56, color: AppTheme.borderDark),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor, size: 20),
                    ),
                    title: Text(l10n.aboutApp, style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.borderDark),
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.7)),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: Colors.white.withOpacity(0.4), fontSize: 12)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.7)),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: Colors.white.withOpacity(0.4), fontSize: 12)),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3)),
      onTap: isLoading ? null : onTap,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.7)),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: Text(trailing,
          style: TextStyle(
              color: Colors.white.withOpacity(0.4), fontSize: 14)),
    );
  }

  Widget _autoLockTile(AppLocalizations l10n, SecurityState security) {
    final options = {
      0: l10n.immediately,
      60: l10n.after1Min,
      300: l10n.after5Min,
      3600: l10n.after1Hour,
      -1: l10n.never,
    };

    return ListTile(
      leading:
          Icon(Icons.timer_rounded, color: Colors.white.withOpacity(0.7)),
      title: Text(l10n.autoLock,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: DropdownButton<int>(
        value: security.autoLockSeconds,
        dropdownColor: AppTheme.surfaceDark,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        items: options.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (val) {
          if (val != null) {
            ref
                .read(securityNotifierProvider.notifier)
                .setAutoLock(val);
          }
        },
      ),
    );
  }

  Widget _languageTile(AppLocalizations l10n, bool isArabic) {
    return ListTile(
      leading: Icon(Icons.language_rounded,
          color: Colors.white.withOpacity(0.7)),
      title: Text(l10n.language,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: GestureDetector(
        onTap: () => ref.read(localeNotifierProvider.notifier).toggle(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            isArabic ? 'العربية' : 'English',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _backupToiCloud() async {
    setState(() => _isBackingUp = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = ref.read(isarProvider);
      final service = BackupService(db);
      await service.backupToiCloud();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupSuccess)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.backupFailed}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _backupToGoogleDrive() async {
    setState(() => _isBackingUp = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final db = ref.read(isarProvider);
      final service = BackupService(db);
      await service.backupToGoogleDrive();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            title: const Text('Backup Error', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: SelectableText(
                e.toString(),
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: AppTheme.primaryColor)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _backupToLocal() async {
    setState(() => _isBackingUp = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = ref.read(isarProvider);
      final service = BackupService(db);
      await service.backupToLocalFile();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupSuccess)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.backupFailed}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromGoogleDrive() async {
    setState(() => _isBackingUp = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = ref.read(isarProvider);
      final service = BackupService(db);
      await service.restoreFromGoogleDrive();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importSuccess)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.importFailed}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromLocalFile() async {
    setState(() => _isBackingUp = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = ref.read(isarProvider);
      final service = BackupService(db);
      await service.restoreFromLocalFile();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importSuccess)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.importFailed}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  void _showExportSheet(AppLocalizations l10n) {
    Person? selectedPerson;
    bool exportAll = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 20),
                  Text(
                    l10n.exportPdf,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Export type toggle
                  Row(
                    children: [
                      Expanded(
                        child: _exportOption(
                          label: l10n.exportAll,
                          selected: exportAll,
                          onTap: () =>
                              setSheetState(() => exportAll = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _exportOption(
                          label: l10n.exportActiveOnly,
                          selected: !exportAll,
                          onTap: () =>
                              setSheetState(() => exportAll = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting
                          ? null
                          : () async {
                              Navigator.pop(sheetContext);
                              await _exportPdf(
                                person: selectedPerson,
                                activeOnly: !exportAll,
                              );
                            },
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded),
                      label: Text(l10n.generateReport),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _exportOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? AppTheme.primaryColor : AppTheme.borderDark,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportPdf({
    Person? person,
    bool activeOnly = false,
  }) async {
    setState(() => _isExporting = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final locale = ref.read(localeNotifierProvider);
    final isArabic = locale.languageCode == 'ar';

    try {
      final db = ref.read(isarProvider);
      var transactions =
          await db.debtTransactions.where().findAll();

      for (final tx in transactions) {
        await tx.person.load();
      }

      if (person != null) {
        transactions = transactions
            .where((tx) => tx.person.value?.id == person.id)
            .toList();
      }

      if (activeOnly) {
        transactions = transactions
            .where((tx) =>
                tx.status == TransactionStatus.active ||
                tx.status == TransactionStatus.overdue)
            .toList();
      }

      final service = PdfExportService();
      final bytes = await service.generateTransactionReport(
        transactions: transactions,
        person: person,
        l10n: l10n,
        isArabic: isArabic,
      );

      await service.sharePdf(
          bytes, 'debt_tracker_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
