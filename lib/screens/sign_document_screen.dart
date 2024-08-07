import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'signed_pdf_preview_screen.dart';

class SignDocumentScreen extends StatefulWidget {
  const SignDocumentScreen({super.key});

  @override
  _SignDocumentScreenState createState() => _SignDocumentScreenState();
}

class _SignDocumentScreenState extends State<SignDocumentScreen> {
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  PlatformFile? _document;
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _signatureBytes;
  Offset _signaturePosition = const Offset(0, 0);
  Offset _signatureIndicatorPosition = const Offset(0, 0);

  late int pageNumber = 0;
  late bool showSignature = false;
  var removedbg = false;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _document = result.files.first;
      });
    }
  }

  Future<void> imageToUint8List() async {
    // Get the image from the signature pad
    ui.Image imageFile = await _signaturePadKey.currentState!.toImage();

    // Convert the ui.Image to ByteData
    ByteData? byteData =
        await imageFile.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Unable to convert image to ByteData');
    }

    // Convert the ByteData to Uint8List
    final Uint8List imageBytes = byteData.buffer.asUint8List();

    // Decode the image using the image package
    final img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Unable to decode image');
    }

    // Convert the image to Uint8List (PNG format)
    final Uint8List pngBytes = Uint8List.fromList(img.encodePng(image));
    setState(() {
      _signatureBytes = pngBytes;
    });
    // return pngBytes;
  }

  Future<void> _saveDocumentWithSignature() async {
    if (_signatureBytes == null) {
      Get.defaultDialog(
          title: "Pick Signature", middleText: "Please pick your signature.");
    }
    if (_signaturePosition == const Offset(0, 0)) {
      Get.bottomSheet(const Text(
        "Scroll and click anywhere on the PDF where the signature should be placed.\nOn clicking the pdf, a red dot will be displayed indicating where your signature will be placed.",
        softWrap: true,
      ));
      return;
    }

    try {
      // Load the existing PDF document.
      final PdfDocument inputDocument = PdfDocument(
        inputBytes: File(_document!.path.toString()).readAsBytesSync(),
      );

      // Get the existing PDF page.
      final PdfPage page = inputDocument.pages[pageNumber - 1];

      // You can adjust the position and size of the image as needed
      final image = PdfBitmap(_signatureBytes!);
      page.graphics.drawImage(
        image,
        Rect.fromLTWH(
          _signaturePosition.dx,
          _signaturePosition.dy,
          100, // Width of the image
          50, // Height of the image
        ),
      );

      // Get the directory path
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      // Making doc name unique
      // final time = DateTime.now().toIso8601String().replaceAll('.', '_');
      // final name = 'signature_$time.png';

      final filePath = '${downloadsDirectory!.path}/signed-${_document!.name}';
      final File file = File(filePath);
      file.writeAsBytes(await inputDocument.save());

      print('PDF saved to: ${file.path}');

      inputDocument.dispose();

      // Show success message
      Get.snackbar("Success", "PDF saved to downloads folder!");

      // Clear the document and signature
      setState(() {
        _document = null;
        _signatureBytes = null;
        _signaturePosition = Offset(0, 0);
        _signatureIndicatorPosition = Offset(0, 0);
        showSignature = false;
      });

      // Navigate to the signed PDF preview screen
      Get.to(() => SignedPdfViewerScreen(filePath));
    } catch (e) {
      print('Error saving PDF: $e');
      Get.defaultDialog(title: "Error", middleText: "Failed to save PDF.");
    }
  }

  Future<void> _showDiscardDialog() async {
    Get.defaultDialog(
      title: "Discard Changes?",
      content: Text("You have unsaved changes. Do you want to discard them?"),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
            Navigator.of(context).pop(); // Go back to the previous screen
          },
          child: Text("Discard"),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
            _saveDocumentWithSignature(); // Save the document
          },
          child: Text("Save"),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    if (_signatureBytes != null) {
      await _showDiscardDialog();
      return false; // Prevent immediate pop
    }
    return true; // Allow pop
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool disposition) async {
        if (disposition == true && _signatureBytes != null) {
          await _showDiscardDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign Document'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_signatureBytes != null) {
                await _showDiscardDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await _saveDocumentWithSignature();
              },
              icon: const Icon(
                Icons.save_alt,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: _document != null
            ? Stack(
                children: [
                  SfPdfViewer.file(
                    File(_document!.path.toString()),
                    onTap: (details) {
                      setState(() {
                        pageNumber = details.pageNumber;
                        _signaturePosition = details.pagePosition;
                        _signatureIndicatorPosition = details.position;
                        print('Signature Page Position: $_signaturePosition');
                        print(
                            'Signature StackWidget Position: $_signatureIndicatorPosition');
                        showSignature = true;
                      });
                      Get.defaultDialog(
                        title: 'Draw signature',
                        content: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: SfSignaturePad(
                                key: _signaturePadKey,
                                minimumStrokeWidth: 2,
                                maximumStrokeWidth: 5,
                                strokeColor: Colors.black,
                                onDrawStart: () {
                                  setState(() {
                                    _signatureBytes = null;
                                  });
                                  return false;
                                },
                                onDrawEnd: () async {
                                  await imageToUint8List();
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                _signaturePadKey.currentState!.clear();
                                setState(() {
                                  _signatureBytes = null;
                                });
                              },
                              child: const Text("Clear"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (showSignature)
                    Positioned(
                      left: _signatureIndicatorPosition.dx,
                      top: _signatureIndicatorPosition.dy,
                      child: _signatureBytes != null
                          ? Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(_signatureBytes!)),
                                shape: BoxShape.rectangle,
                              ),
                            )
                          : Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveDocumentWithSignature();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              )
            : Center(
                child: ElevatedButton(
                  onPressed: _pickDocument,
                  child: const Text('Select Document'),
                ),
              ),
      ),
    );
  }
}
