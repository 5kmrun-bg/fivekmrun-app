import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui'; // Add this import for FontFeature
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).floor() % 100;
    int seconds = (milliseconds / 1000).floor() % 60;
    int minutes = (milliseconds / 60000).floor() % 60;
    int hours = (milliseconds / 3600000).floor();

    String hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    return '$hoursStr${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chronometer'),
        actions: [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              _formatTime(_milliseconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _toggleTimer,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(_isRunning ? 'Stop' : 'Start'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _markLap,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Lap'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetTimer,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
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
                          title: Text('Lap time: ${_formatTime(lapDuration)}'),
                          subtitle: Text('Total time: ${_formatTime(lapTime)}'),
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
