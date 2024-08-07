import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoSignatureScreen extends StatelessWidget {
  const AutoSignatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Signature'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Function to auto-generate a signature
            // For now, just displaying a placeholder
            Get.defaultDialog(
              title: 'Auto-generated signature',
              middleText: 'John Doe',
            );
          },
          child: const Text('Generate Signature'),
        ),
      ),
    );
  }
}
