import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui'; // Add this import for FontFeature
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:io';

class ChronometerView extends StatefulWidget {
  const ChronometerView({Key? key}) : super(key: key);

  @override
  State<ChronometerView> createState() => _ChronometerViewState();
}

class _ChronometerViewState extends State<ChronometerView> {
  bool _isRunning = false;
  int _milliseconds = 0;
  Timer? _timer;
  List<int> _laps = [];
  int? _startTimeMillis; // When the timer was started
  int? _pausedAtMillis; // When the timer was paused

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    WakelockPlus.enable();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _startTimeMillis = prefs.getInt('chronometer_start_time');
      _pausedAtMillis = prefs.getInt('chronometer_paused_at');

      final lapsJson = prefs.getString('chronometer_laps');
      if (lapsJson != null) {
        final List<dynamic> decoded = jsonDecode(lapsJson);
        _laps = decoded.map((e) => e as int).toList();
      }

      // If we had a running timer when the app was closed
      if (_startTimeMillis != null && _pausedAtMillis == null) {
        // Calculate elapsed time and continue running
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsedSinceStart = now - _startTimeMillis!;
        _milliseconds = elapsedSinceStart;
        _isRunning = true;
        _startTimer();
      }
      // If we had a paused timer
      else if (_pausedAtMillis != null) {
        _milliseconds = _pausedAtMillis!;
        _isRunning = false;
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();

    if (_isRunning) {
      // Save when we started the timer
      await prefs.setInt('chronometer_start_time',
          DateTime.now().millisecondsSinceEpoch - _milliseconds);
      await prefs.remove('chronometer_paused_at');
    } else {
      // Save the time when we paused
      await prefs.setInt('chronometer_paused_at', _milliseconds);
      if (_milliseconds == 0) {
        // If reset, clear the start time
        await prefs.remove('chronometer_start_time');
      }
    }

    // Save laps
    await prefs.setString('chronometer_laps', jsonEncode(_laps));
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimeMillis =
            DateTime.now().millisecondsSinceEpoch - _milliseconds;
        _pausedAtMillis = null;
        _startTimer();
      } else {
        _pausedAtMillis = _milliseconds;
        _stopTimer();
      }
      _saveState();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        final now = DateTime.now().millisecondsSinceEpoch;
        _milliseconds = now - _startTimeMillis!;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _resetTimer() async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Timer'),
        content: const Text(
            'Are you sure you want to reset the timer and clear all laps?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      _stopTimer();
      setState(() {
        _milliseconds = 0;
        _isRunning = false;
        _laps = [];
        _startTimeMillis = null;
        _pausedAtMillis = null;
        _saveState();
      });
    }
  }

  void _markLap() {
    if (_isRunning) {
      HapticFeedback.mediumImpact();
      setState(() {
        _laps.add(_milliseconds);
        _saveState();
      });
    }
  }

  Future<void> _deleteLap(int index) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lap'),
        content: const Text('Are you sure you want to delete this lap?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _laps.removeAt(index);
        _saveState();
      });
    }
  }

  List<int> _breakDownTime(int ms) {
    final hours = ms ~/ 3600000;
    final minutes = (ms % 3600000) ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final hundredths = (ms % 1000) ~/ 10;
    return [hours, minutes, seconds, hundredths];
  }

  String _formatTimeForExport(int ms) {
    final parts = _breakDownTime(ms);
    final h = parts[0], m = parts[1], s = parts[2], hs = parts[3];

    return '$h:${m.toString().padLeft(2, '0')}\'${s.toString().padLeft(2, '0')}.${hs.toString().padLeft(2, '0')}';
  }

  String _formatTimeForUI(int ms) {
    final parts = _breakDownTime(ms);
    final h = parts[0], m = parts[1], s = parts[2], hs = parts[3];

    final hStr = h > 0 ? '${h.toString().padLeft(2, '0')}:' : '';
    return '$hStr${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${hs.toString().padLeft(2, '0')}';
  }

  Future<void> _exportToFile() async {
    if (_laps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No laps to export')),
      );
      return;
    }

    final now = DateTime.now();
    final dayOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][now.weekday - 1];

    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    String content = 'MCH:\t\t001\n\n';
    content += 'Record Date:\t$dateStr\t$dayOfWeek\n\n';

    int previousLapTime = 0;
    for (int i = 0; i < _laps.length; i++) {
      final lapNumber = i + 1;
      final lapTime = _laps[i];
      final splitTime = lapTime - previousLapTime;

      final splitTimeStr = _formatTimeForExport(splitTime);
      final totalTimeStr = _formatTimeForExport(lapTime);

      content +=
          'Lap$lapNumber:\t$splitTimeStr\tSplit$lapNumber:\t$totalTimeStr\n';
      previousLapTime = lapTime;
    }

    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'chronometer_results_${dateStr.replaceAll('-', '')}.txt';
      final file = File('${directory.path}/$fileName');

      // Write content to file
      await file.writeAsString(content);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Chronometer Results - $dateStr',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing results: $e')),
      );
    }
  }

  @override
  void dispose() {
    _stopTimer();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chronometer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportToFile,
            tooltip: 'Export Results',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              _formatTimeForUI(_milliseconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(_isRunning ? 'Stop' : 'Start'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: _laps.isEmpty
                ? const Center(child: Text('No laps recorded'))
                : ListView.builder(
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = _laps.length - 1 - index;
                      final lapNumber = reversedIndex + 1;
                      final lapTime = _laps[reversedIndex];
                      final previousLapTime =
                          reversedIndex > 0 ? _laps[reversedIndex - 1] : 0;
                      final lapDuration = lapTime - previousLapTime;

                      return Dismissible(
                        key: Key('lap_$reversedIndex'),
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
                              title: const Text('Delete Lap'),
                              content: const Text(
                                  'Are you sure you want to delete this lap?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            setState(() {
                              _laps.removeAt(reversedIndex);
                              _saveState();
                            });
                          }
                          return shouldDelete;
                        },
                        child: ListTile(
                          leading: CircleAvatar(child: Text('$lapNumber')),
                          title:
                              Text('Total time: ${_formatTimeForUI(lapTime)}'),
                          subtitle: Text(
                            'Lap: ${_formatTimeForUI(lapDuration)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _markLap,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 96),
                textStyle: const TextStyle(fontSize: 20),
              ),
              icon: const Icon(Icons.flag, size: 32),
              label: const Text('Lap'),
            ),
          ),
        ],
      ),
    );
  }
}
