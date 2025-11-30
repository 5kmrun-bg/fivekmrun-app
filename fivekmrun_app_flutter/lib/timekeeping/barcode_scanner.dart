import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScannedBarcode {
  final String value;
  final DateTime timestamp;

  ScannedBarcode({
    required this.value,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScannedBarcode.fromJson(Map<String, dynamic> json) {
    return ScannedBarcode(
      value: json['value'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
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
  String? lastScannedValue;
  late AnimationController _animationController;
  late Animation<double> _animation;

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
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture barcodeCapture) {
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue != lastScannedValue) {
        setState(() {
          lastScannedValue = barcode.rawValue;
          scannedValues.insert(
              0,
              ScannedBarcode(
                value: barcode.rawValue!,
                timestamp: DateTime.now(),
              ));
        });
        _saveState();
        // Vibrate when a new barcode is scanned
        HapticFeedback.mediumImpact();
        // Scroll to top to show the newly added item
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
  }

  int _getPairCount() {
    return (scannedValues.length / 2).ceil();
  }

  Future<void> _clearScannedValues() async {
    if (scannedValues.isEmpty) return;

    final pairCount = _getPairCount();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Изчисти всички записи?'),
          content: Text(
            'Сигурни ли сте, че искате да изтриете всички $pairCount двойки (${scannedValues.length} сканирани баркода)?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отказ'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Изчисти'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчитане'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearScannedValues,
            tooltip: 'Изчисти',
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
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
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
                                  color: Colors.red.withOpacity(0.8),
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
            child: Container(
              color: Colors.grey[100],
              child: scannedValues.isEmpty
                  ? const Center(
                      child: Text(
                        'Сканирайте баркод',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
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
                                title: const Text('Изтрий двойката?'),
                                content: const Text(
                                    'Сигурни ли сте, че искате да изтриете тази двойка?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Отказ'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Изтрий'),
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
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  '${_getPairCount() - index}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Участник: ${first.value}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          second != null
                                              ? 'Място: ${second.value}'
                                              : 'Място: (чака сканиране)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: second != null
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Участник: ${first.timestamp.toString().substring(0, 19)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (second != null)
                                    Text(
                                      'Място: ${second.timestamp.toString().substring(0, 19)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              isThreeLine: true,
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
  }
}
