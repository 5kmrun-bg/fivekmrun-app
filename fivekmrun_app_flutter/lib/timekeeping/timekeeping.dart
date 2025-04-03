import 'package:flutter/material.dart';
import 'chronometer_view.dart';
import 'barcode_scanner_view.dart';

class Timekeeping extends StatelessWidget {
  const Timekeeping({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Времеизмерване компонент'),
        // Add Chronometer button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChronometerView()),
            );
          },
          child: const Text('Chronometer'),
        ),

        // Add Barcode Scanner button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BarcodeScannerView()),
            );
          },
          child: const Text('Barcode Scanner'),
        ),
        // Add your timekeeping UI elements here
      ],
    );
  }
}
