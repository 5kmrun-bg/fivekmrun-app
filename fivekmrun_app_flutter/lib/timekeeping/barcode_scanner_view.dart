import 'package:flutter/material.dart';

class BarcodeScannerView extends StatelessWidget {
  const BarcodeScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: const Center(child: Text('Barcode Scanner View')),
    );
  }
}
