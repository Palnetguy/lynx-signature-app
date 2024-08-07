import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  PlatformFile? _document;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _document = result.files.first;
      });
      // Upload the document
      // For now, just displaying the document name
      Get.defaultDialog(
        title: 'Document selected',
        middleText: 'Document selected: ${_document!.name}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickDocument,
          child: const Text('Select Document to Upload'),
        ),
      ),
    );
  }
}
