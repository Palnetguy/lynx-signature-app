import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class ShareDocumentScreen extends StatefulWidget {
  const ShareDocumentScreen({super.key});

  @override
  _ShareDocumentScreenState createState() => _ShareDocumentScreenState();
}

class _ShareDocumentScreenState extends State<ShareDocumentScreen> {
  PlatformFile? _document;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _document = result.files.first;
      });
      // Display the selected document
      Get.defaultDialog(
        title: 'Document selected',
        middleText: 'Document selected: ${_document!.name}',
      );
    }
  }

  void _shareDocument() {
    if (_document != null) {
      Share.shareXFiles([XFile(_document!.path!)],
          text: 'Here is the document');
    } else {
      Get.snackbar('Error', 'No document selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Document'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickDocument,
              child: const Text('Select Document to Share'),
            ),
            if (_document != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Selected Document: ${_document!.name}'),
              ),
            ElevatedButton(
              onPressed: _shareDocument,
              child: const Text('Share Document'),
            ),
          ],
        ),
      ),
    );
  }
}
