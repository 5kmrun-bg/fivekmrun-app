import 'package:flutter/material.dart';
import 'chronometer_view.dart';
import 'barcode_scanner_view.dart';

class Timekeeping extends StatelessWidget {
  const Timekeeping({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Времеизмерване',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChronometerView()),
                      );
                    },
                    icon: const Icon(Icons.timer),
                    label: const Text('Хронометър'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BarcodeScannerView()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Сканер'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
