import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../controllers/signed_pdf_controller.dart';

class SignedPdfListScreen extends StatelessWidget {
  final SignedPdfController _controller = Get.put(SignedPdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signed PDFs'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: _controller.signedPdfs.length,
          itemBuilder: (context, index) {
            final pdfFile = _controller.signedPdfs[index];
            return ListTile(
              shape: Border(
                  bottom: BorderSide(
                color: Colors.black,
              )),
              leading: const Icon(
                size: 30,
                color: Colors.red,
                Icons.picture_as_pdf_outlined,
              ),
              title: Text(path.basename(pdfFile.path)),
              subtitle:
                  Text('Modified: ${_controller.getFormattedDate(pdfFile)}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Share':
                      _controller.sharePdf(pdfFile);
                      break;
                    case 'Delete':
                      _controller.deletePdf(pdfFile);
                      break;
                    case 'View':
                      _controller.viewPdf(pdfFile);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Share', child: Text('Share')),
                  const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                  const PopupMenuItem(value: 'View', child: Text('View')),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
