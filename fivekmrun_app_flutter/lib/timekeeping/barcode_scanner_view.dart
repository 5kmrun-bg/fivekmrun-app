import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final List<ScanRecord> _scanRecords = [];
  bool _isScanning = false;
  String _currentUserId = '';
  String _statusMessage = 'Ready to scan';

  @override
  void initState() {
    super.initState();
    _loadSavedRecords();
  }

  Future<void> _loadSavedRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString('barcode_scan_records');

    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      setState(() {
        _scanRecords.clear();
        _scanRecords.addAll(
          decoded.map((record) => ScanRecord.fromJson(record)).toList(),
        );
      });
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson =
        jsonEncode(_scanRecords.map((r) => r.toJson()).toList());
    await prefs.setString('barcode_scan_records', recordsJson);
  }

  Future<void> _scanUserIdBarcode() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning User ID...';
    });

    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        // -1 is returned when scanning is canceled
        setState(() {
          _currentUserId = barcodeScanRes;
          _statusMessage =
              'User ID: $_currentUserId - Now scan finish position';
        });

        // Proceed to scan finish position
        _scanFinishPositionBarcode();
      } else {
        setState(() {
          _isScanning = false;
          _statusMessage = 'Scan canceled';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error scanning: ${e.toString()}';
      });
    }
  }

  Future<void> _scanFinishPositionBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#66FF66',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        final timestamp = DateTime.now();
        final newRecord = ScanRecord(
          userId: _currentUserId,
          finishPosition: barcodeScanRes,
          timestamp: timestamp,
        );

        setState(() {
          _scanRecords.add(newRecord);
          _isScanning = false;
          _statusMessage =
              'Recorded: User $_currentUserId at position $barcodeScanRes';
          _currentUserId = '';
        });

        await _saveRecords();
      } else {
        setState(() {
          _isScanning = false;
          _statusMessage = 'Finish position scan canceled';
          _currentUserId = '';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error scanning: ${e.toString()}';
        _currentUserId = '';
      });
    }
  }

  Future<void> _clearRecords() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Records'),
        content: const Text('Are you sure you want to clear all scan records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _scanRecords.clear();
                _statusMessage = 'Records cleared';
              });

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('barcode_scan_records');

              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearRecords,
            tooltip: 'Clear Records',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isScanning ? null : _scanUserIdBarcode,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: _scanRecords.isEmpty
                ? const Center(child: Text('No scan records'))
                : ListView.builder(
                    itemCount: _scanRecords.length,
                    itemBuilder: (context, index) {
                      // Show newest records at the top
                      final record =
                          _scanRecords[_scanRecords.length - 1 - index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(record.finishPosition),
                        ),
                        title: Text('User ID: ${record.userId}'),
                        subtitle: Text(
                          'Scanned: ${_formatDateTime(record.timestamp)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _scanRecords.remove(record);
                              _saveRecords();
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}

class ScanRecord {
  final String userId;
  final String finishPosition;
  final DateTime timestamp;

  ScanRecord({
    required this.userId,
    required this.finishPosition,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'finishPosition': finishPosition,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      userId: json['userId'],
      finishPosition: json['finishPosition'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
