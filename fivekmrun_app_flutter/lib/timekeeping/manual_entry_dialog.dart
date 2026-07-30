import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Digits the marshal types -> the zero-padded 10-digit barcode format used
/// everywhere else in the app (see `formatBarcode` in barcode_page.dart).
/// Returns null when the input can't be a valid runner ID.
String? formatRunnerId(String input) {
  final digits = input.trim();
  if (digits.isEmpty) return null;
  if (!RegExp(r'^\d+$').hasMatch(digits)) return null;
  if (digits.length > 10) return null;
  return digits.padLeft(10, '0');
}

/// Digits the marshal types -> the "J"-prefixed form real place tokens use.
/// The marshal types the digits already at the width the physical tokens use
/// (e.g. "001"), so this only adds the prefix.
String? formatPlace(String input) {
  final digits = input.trim();
  if (digits.isEmpty) return null;
  if (!RegExp(r'^\d+$').hasMatch(digits)) return null;
  return 'J$digits';
}

/// Strips a stored runner-ID barcode's zero-padding back to the digits a
/// marshal would type — used to prefill the dialog when editing.
String stripRunnerId(String storedValue) =>
    storedValue.replaceFirst(RegExp(r'^0+(?=\d)'), '');

/// Strips a stored place token's "J" prefix back to the digits a marshal
/// would type — used to prefill the dialog when editing.
String stripPlace(String storedValue) => storedValue.substring(1);

/// The dialog's outcome. [runnerId] is null when the runner ID field was
/// locked (completing a dangling pair) — the caller already knows it.
class ManualEntryResult {
  final String? runnerId;
  final String place;

  const ManualEntryResult({this.runnerId, required this.place});
}

/// Collects a runner ID + place pair for manual entry or correction.
///
/// Used in three modes, distinguished by the constructor params:
///  - fresh add: both fields empty and editable.
///  - completing a dangling pair (an odd-length scanned list): runner ID is
///    pre-filled and locked, only the place is collected.
///  - editing an existing pair: both fields pre-filled and editable.
class ManualEntryDialog extends StatefulWidget {
  final String? initialRunnerIdDigits;
  final String? initialPlaceDigits;
  final bool lockRunnerId;

  /// Checked against the live runner-ID field value to show a non-blocking
  /// duplicate warning — the caller decides what counts as a duplicate (e.g.
  /// excluding the pair currently being edited).
  final bool Function(String formattedRunnerId) isDuplicateRunner;

  const ManualEntryDialog({
    Key? key,
    this.initialRunnerIdDigits,
    this.initialPlaceDigits,
    this.lockRunnerId = false,
    required this.isDuplicateRunner,
  }) : super(key: key);

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  late final TextEditingController _runnerIdController;
  late final TextEditingController _placeController;
  String? _runnerIdError;
  String? _placeError;

  @override
  void initState() {
    super.initState();
    _runnerIdController =
        TextEditingController(text: widget.initialRunnerIdDigits ?? '');
    _placeController =
        TextEditingController(text: widget.initialPlaceDigits ?? '');
    _runnerIdController.addListener(() => setState(() {}));
    _placeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _runnerIdController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  String? get _previewRunnerId => widget.lockRunnerId
      ? widget.initialRunnerIdDigits == null
          ? null
          : formatRunnerId(widget.initialRunnerIdDigits!)
      : formatRunnerId(_runnerIdController.text);

  String? get _previewPlace => formatPlace(_placeController.text);

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final runnerId = _previewRunnerId;
    final place = _previewPlace;

    setState(() {
      _runnerIdError = (!widget.lockRunnerId && runnerId == null)
          ? l10n.manual_entry_dialog_invalid_runner_id
          : null;
      _placeError =
          place == null ? l10n.manual_entry_dialog_invalid_place : null;
    });

    if (runnerId == null || place == null) return;

    Navigator.of(context).pop(ManualEntryResult(
      runnerId: widget.lockRunnerId ? null : runnerId,
      place: place,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previewRunnerId = _previewRunnerId;
    final isDuplicate =
        previewRunnerId != null && widget.isDuplicateRunner(previewRunnerId);

    return AlertDialog(
      title: Text(l10n.manual_entry_dialog_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _runnerIdController,
              enabled: !widget.lockRunnerId,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.manual_entry_dialog_runner_id_label,
                errorText: _runnerIdError,
                helperText: previewRunnerId,
              ),
            ),
            if (isDuplicate)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  l10n.manual_entry_dialog_duplicate_runner_warning,
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _placeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.manual_entry_dialog_place_label,
                errorText: _placeError,
                helperText: _previewPlace,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.manual_entry_dialog_save),
        ),
      ],
    );
  }
}
