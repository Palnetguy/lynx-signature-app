import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:io';

import 'saved_signature_screen.dart';

class DrawSignatureScreen extends StatefulWidget {
  DrawSignatureScreen({super.key});

  @override
  State<DrawSignatureScreen> createState() => _DrawSignatureScreenState();
}

class _DrawSignatureScreenState extends State<DrawSignatureScreen> {
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  TextEditingController controller = TextEditingController();

  bool isSignatureDrawn = false;

  Future<void> _saveSignatureWithConfirmation(Uint8List pngBytes) async {
    if (isSignatureDrawn) {
      await Get.defaultDialog(
        title: 'Save Signature',
        content: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Signature Name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) {
                  Get.snackbar(
                      'Error', 'Please enter a name for the signature');
                  return;
                }

                final name = controller.text;
                final result = await _saveSignature(pngBytes, name);
                if (result) {
                  controller.clear();
                  setState(() {
                    isSignatureDrawn = false;
                  });
                  Get.back();
                  _signaturePadKey.currentState?.clear();
                  Get.snackbar('Success', 'Signature saved to device',
                      backgroundColor: Colors.white, colorText: Colors.green);
                  Get.to(() => SavedSignatureScreen());
                } else {
                  print("ERROR SAVING SIGNATURE");
                }

                // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      Get.defaultDialog(
          middleText:
              "Please use your finger to draw your signature on the white space");
    }
  }

  Future<void> _confirmDiscardChanges() async {
    Get.defaultDialog(
      title: "Discard Changes?",
      content: Text("You have unsaved changes. Do you want to discard them?"),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
            Navigator.of(Get.context!).pop(); // Go back to the previous screen
          },
          child: Text("Discard"),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }

  Future<bool> _saveSignature(Uint8List pngBytes, String name) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final signatureDir = Directory('${directory.path}/signatures');

      if (!signatureDir.existsSync()) {
        signatureDir.createSync(recursive: true);
      }

      final filePath = '${signatureDir.path}/$name.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      // Get.to(() => SavedSignatureScreen());
      return true;
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  Future<void> _saveImage(Uint8List pngBytes) async {
    final status = await Permission.storage.status;

    if (!status.isGranted) {
      await Permission.storage.request();
    }

    await _saveSignatureWithConfirmation(pngBytes);
  }

  Future<ByteData?> _convertImageToByteData(ui.Image image) async {
    return await image.toByteData(format: ui.ImageByteFormat.png);
  }

  Future<Uint8List?> _exportSignatureToImage(ByteData data) async {
    ui.Image image = await _convertToImage(data);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      Uint8List pngBytes = byteData.buffer.asUint8List();
      img.Image processedImage = img.decodePng(pngBytes)!;
      // removeTransparentBackground(processedImage);
      return Uint8List.fromList(img.encodePng(processedImage));
    }
    return null;
  }

  Future<ui.Image> _convertToImage(ByteData data) async {
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool disposition) async {
        if (disposition == true &&
            _signaturePadKey.currentState?.toImage() != null) {
          await _confirmDiscardChanges();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Draw Signature'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (isSignatureDrawn) {
                await _confirmDiscardChanges();
              } else {
                // Navigator.of(context).pop();
                Get.back();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SfSignaturePad(
                key: _signaturePadKey,
                minimumStrokeWidth: 2,
                maximumStrokeWidth: 5,
                strokeColor: Colors.black,
                onDrawEnd: () {
                  setState(() {
                    isSignatureDrawn = true;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _signaturePadKey.currentState!.clear();
                    setState(() {
                      isSignatureDrawn = false;
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var signature =
                        await _signaturePadKey.currentState!.toImage();
                    var byteData = await _convertImageToByteData(signature);
                    if (byteData == null) {
                      Get.snackbar('Error', 'Please draw the signature first.');
                      return;
                    }
                    var pngBytes = await _exportSignatureToImage(byteData);
                    if (pngBytes != null) {
                      await _saveImage(pngBytes);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
