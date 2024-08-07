import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SignedPdfViewerScreen extends StatelessWidget {
  final String filePath;

  const SignedPdfViewerScreen(this.filePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signed PDF Viewer'),
      ),
      body: SfPdfViewer.file(
        File(filePath),
      ),
      // PDFView(
      //   filePath: filePath,
      // ),
    );
  }
}
