import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/timekeeping/manual_entry_dialog.dart';
import 'dart:convert';
import 'dart:io';

class ScannedBarcode {
  final String value;
  final DateTime timestamp;
  final bool isManual;

  ScannedBarcode({
    required this.value,
    required this.timestamp,
    this.isManual = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'isManual': isManual,
    };
  }

  factory ScannedBarcode.fromJson(Map<String, dynamic> json) {
    return ScannedBarcode(
      value: json['value'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      // Missing in JSON saved by a previous app version — default false so
      // an in-progress session survives the update.
      isManual: json['isManual'] as bool? ?? false,
    );
  }
}

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({Key? key}) : super(key: key);

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  final List<ScannedBarcode> scannedValues = [];
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? lastScannedValue;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey _saveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final scannedValuesJson = prefs.getString('barcode_scanner_values');
    final lastScannedValueStr = prefs.getString('barcode_scanner_last_value');

    if (scannedValuesJson != null) {
      final List<dynamic> decoded = jsonDecode(scannedValuesJson);
      final loadedValues = decoded
          .map((e) => ScannedBarcode.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        scannedValues.clear();
        scannedValues.addAll(loadedValues);
        lastScannedValue = lastScannedValueStr;
      });
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final scannedValuesJson =
        jsonEncode(scannedValues.map((e) => e.toJson()).toList());
    await prefs.setString('barcode_scanner_values', scannedValuesJson);
    if (lastScannedValue != null) {
      await prefs.setString('barcode_scanner_last_value', lastScannedValue!);
    } else {
      await prefs.remove('barcode_scanner_last_value');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool _isExpectedCode(String value) {
    // Even count → next scan is runner ID (must start with "00")
    // Odd count  → next scan is place number (must start with "J")
    if (scannedValues.length.isEven) {
      return value.startsWith('00');
    } else {
      return value.startsWith('J');
    }
  }

  void _onBarcodeDetect(BarcodeCapture barcodeCapture) {
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw == lastScannedValue) continue;
      if (!_isExpectedCode(raw)) continue;

      setState(() {
        lastScannedValue = raw;
        scannedValues.add(ScannedBarcode(
          value: raw,
          timestamp: DateTime.now(),
        ));
      });
      _saveState();
      HapticFeedback.heavyImpact();
      _audioPlayer.play(AssetSource('beep.wav'));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  int _getPairCount() {
    return (scannedValues.length / 2).ceil();
  }

  Future<void> _exportToFile() async {
    final l10n = AppLocalizations.of(context)!;
    if (scannedValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.barcode_scanner_nothing_to_save)),
      );
      return;
    }

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Build lines in chronological order (scannedValues is newest-first)
    String content = '';
    for (int i = 0; i < scannedValues.length; i++) {
      final entry = scannedValues[i];
      final t = entry.timestamp;
      final yy = (t.year % 100).toString().padLeft(2, '0');
      final mm = t.month.toString().padLeft(2, '0');
      final dd = t.day.toString().padLeft(2, '0');
      final hh = t.hour.toString().padLeft(2, '0');
      final min = t.minute.toString().padLeft(2, '0');
      final ss = t.second.toString().padLeft(2, '0');
      content += '$yy/$mm/$dd,$hh:$min:$ss,01,${entry.value}\n';
    }

    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'BARCODES_${dateStr.replaceAll('-', '')}.txt';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      final box =
          _saveButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final origin =
          box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'BARCODES_${dateStr.replaceAll('-', '')}',
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.barcode_scanner_save_error(e.toString()))),
        );
      }
    }
  }

  Future<void> _clearScannedValues() async {
    if (scannedValues.isEmpty) return;

    final pairCount = _getPairCount();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.barcode_scanner_clear_all_title),
          content: Text(
            l10n.barcode_scanner_clear_all_content(
                pairCount, scannedValues.length),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.barcode_scanner_clear),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        scannedValues.clear();
        lastScannedValue = null;
      });
      _saveState();
    }
  }

  bool _isDuplicateRunnerId(String formattedRunnerId, {int? excludingIndex}) {
    for (var i = 0; i < scannedValues.length; i += 2) {
      if (i == excludingIndex) continue;
      if (scannedValues[i].value == formattedRunnerId) return true;
    }
    return false;
  }

  /// Appends a manually-entered pair, or — if the last scan is a dangling
  /// runner ID with no place yet — completes that pair instead of starting a
  /// new one, so pair numbering stays correct.
  Future<void> _addManually() async {
    final bool completingDanglingPair = scannedValues.length.isOdd;
    final String? initialRunnerId =
        completingDanglingPair ? stripRunnerId(scannedValues.last.value) : null;

    final result = await showDialog<ManualEntryResult>(
      context: context,
      builder: (context) => ManualEntryDialog(
        initialRunnerIdDigits: initialRunnerId,
        lockRunnerId: completingDanglingPair,
        isDuplicateRunner: (id) => _isDuplicateRunnerId(id),
      ),
    );
    if (result == null || !mounted) return;

    final now = DateTime.now();
    setState(() {
      if (completingDanglingPair) {
        scannedValues.add(ScannedBarcode(
            value: result.place, timestamp: now, isManual: true));
      } else {
        scannedValues.add(ScannedBarcode(
            value: result.runnerId!, timestamp: now, isManual: true));
        scannedValues.add(ScannedBarcode(
            value: result.place, timestamp: now, isManual: true));
      }
      // A stray camera re-detection of the same code right after a manual
      // entry must not duplicate it.
      lastScannedValue = scannedValues.last.value;
    });
    _saveState();
  }

  /// Opens the same dialog pre-filled with an existing pair's values so it
  /// can be corrected in place. Keeps both entries' original timestamps —
  /// only the values change — preserving chronology and export line order.
  Future<void> _editPair(int firstIndex, int? secondIndex) async {
    if (secondIndex == null) {
      // Tapped the trailing dangling pair — complete it rather than editing
      // a place entry that doesn't exist yet.
      return _addManually();
    }

    final first = scannedValues[firstIndex];
    final second = scannedValues[secondIndex];

    final result = await showDialog<ManualEntryResult>(
      context: context,
      builder: (context) => ManualEntryDialog(
        initialRunnerIdDigits: stripRunnerId(first.value),
        initialPlaceDigits: stripPlace(second.value),
        isDuplicateRunner: (id) =>
            _isDuplicateRunnerId(id, excludingIndex: firstIndex),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      scannedValues[firstIndex] = ScannedBarcode(
          value: result.runnerId!, timestamp: first.timestamp, isManual: true);
      scannedValues[secondIndex] = ScannedBarcode(
          value: result.place, timestamp: second.timestamp, isManual: true);
    });
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timekeeping_scanning),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: _addManually,
            tooltip: l10n.barcode_scanner_add_manually,
          ),
          IconButton(
            key: _saveButtonKey,
            icon: const Icon(Icons.save_alt),
            onPressed: _exportToFile,
            tooltip: l10n.barcode_scanner_save,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearScannedValues,
            tooltip: l10n.barcode_scanner_clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: _onBarcodeDetect,
                      scanWindow: Rect.fromLTWH(
                        40,
                        40,
                        constraints.maxWidth - 80,
                        constraints.maxHeight - 80,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(40),
                    ),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final scanAreaHeight = constraints.maxHeight - 80;
                        return Positioned(
                          left: 40,
                          right: 40,
                          top: 40 + (_animation.value * scanAreaHeight),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.8),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: scannedValues.isEmpty
                ? Center(child: Text(l10n.barcode_scanner_scan_prompt))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _getPairCount(),
                    itemBuilder: (context, index) {
                      final pairIndex = _getPairCount() - index - 1;
                      final firstIndex = pairIndex * 2;
                      final secondIndex = firstIndex + 1;

                      final first = scannedValues[firstIndex];
                      final second = secondIndex < scannedValues.length
                          ? scannedValues[secondIndex]
                          : null;

                      return Dismissible(
                        key: Key('pair_$pairIndex'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          final bool? shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title:
                                  Text(l10n.barcode_scanner_delete_pair_title),
                              content: Text(
                                  l10n.barcode_scanner_delete_pair_content),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: Text(l10n.barcode_scanner_delete),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            setState(() {
                              // Remove both items (or just one if pair is incomplete)
                              if (secondIndex < scannedValues.length) {
                                scannedValues.removeAt(secondIndex);
                              }
                              scannedValues.removeAt(firstIndex);

                              // Reset lastScannedValue if we deleted the most recent scan
                              if (scannedValues.isEmpty) {
                                lastScannedValue = null;
                              }
                            });
                            _saveState();
                          }
                          return shouldDelete;
                        },
                        child: ListTile(
                          onTap: () => _editPair(
                              firstIndex,
                              secondIndex < scannedValues.length
                                  ? secondIndex
                                  : null),
                          leading: CircleAvatar(
                              child: Text('${_getPairCount() - index}')),
                          title: Text(
                            l10n.barcode_scanner_participant(first.value),
                            style: TextStyle(
                              fontSize: index < 1 ? 24 : 20,
                              fontWeight: index < 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            second != null
                                ? l10n.barcode_scanner_place(second.value)
                                : l10n.barcode_scanner_place_pending,
                            style: TextStyle(
                              fontSize: index < 1 ? 18 : 16,
                              fontWeight: index < 1
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: (first.isManual ||
                                  (second?.isManual ?? false))
                              ? Tooltip(
                                  message:
                                      l10n.barcode_scanner_manual_entry_badge,
                                  child: const Icon(Icons.edit, size: 18),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
