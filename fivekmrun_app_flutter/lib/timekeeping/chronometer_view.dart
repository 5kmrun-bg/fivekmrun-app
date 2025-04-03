import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui'; // Add this import for FontFeature

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

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _milliseconds += 10;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _milliseconds = 0;
      _isRunning = false;
      _laps = [];
    });
  }

  void _markLap() {
    if (_isRunning) {
      setState(() {
        _laps.add(_milliseconds);
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
      appBar: AppBar(title: const Text('Chronometer')),
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

                      return ListTile(
                        leading: CircleAvatar(child: Text('$lapNumber')),
                        title: Text('Lap time: ${_formatTime(lapDuration)}'),
                        subtitle: Text('Total time: ${_formatTime(lapTime)}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
