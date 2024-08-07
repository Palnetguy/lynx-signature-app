import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'saved_signature_screen.dart';

class ScanSignatureScreen extends StatefulWidget {
  const ScanSignatureScreen({super.key});

  @override
  _ScanSignatureScreenState createState() => _ScanSignatureScreenState();
}

class _ScanSignatureScreenState extends State<ScanSignatureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _scanSignature() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
      // Display the scanned image
      Get.defaultDialog(
        title: 'Scanned Signature',
        content: Column(
          children: [
            Image.file(File(_image!.path)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveSignature,
              child: const Text('Save Signature'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveSignature() async {
    if (_image == null) {
      Get.snackbar('Error', 'No image to save');
      return;
    }

    // final directory = await getApplicationDocumentsDirectory();
    // final path =
    //     '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
    // final File file = File(path);

    // final result = await ImageGallerySaver.saveImage(
    //     await _image!.readAsBytes(),
    //     name: 'signature_${DateTime.now().millisecondsSinceEpoch}.png');
    // final isSuccessful = result['isSuccess'];

    try {
      final directory = await getApplicationDocumentsDirectory();
      final signatureDir = Directory('${directory.path}/signatures');

      if (!signatureDir.existsSync()) {
        signatureDir.createSync(recursive: true);
      }

      final filePath =
          '${signatureDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(await _image!.readAsBytes());

      Get.back();
      Get.snackbar('Success', 'Signature saved to Device',
          backgroundColor: Colors.white, colorText: Colors.green);
      Get.to(() => SavedSignatureScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to save signature');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Signature'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _scanSignature,
          child: const Text('Scan Signature'),
        ),
      ),
    );
  }
}
