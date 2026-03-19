import 'package:flutter/material.dart';
import 'package:debt_tracker/l10n/app_localizations.dart';

import '../db/models/enums.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.isOverdue = false,
  });

  final TransactionStatus status;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color backgroundColor;
    final Color foregroundColor;
    final String label;

    if (isOverdue || status == TransactionStatus.overdue) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red.shade700;
      label = l10n.overdue;
    } else if (status == TransactionStatus.settled) {
      backgroundColor = Colors.green.shade50;
      foregroundColor = Colors.green.shade700;
      label = l10n.settled;
    } else {
      backgroundColor = Colors.blue.shade50;
      foregroundColor = Colors.blue.shade700;
      label = l10n.active;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
