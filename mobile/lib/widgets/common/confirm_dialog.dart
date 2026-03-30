import 'package:flutter/material.dart';
import 'package:rent_manager/l10n/app_localizations.dart';

Future<bool> showConfirmDialog(BuildContext context, {String? message}) async {
  final l = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.confirmDelete),
      content: Text(message ?? l.deleteConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(l.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}
