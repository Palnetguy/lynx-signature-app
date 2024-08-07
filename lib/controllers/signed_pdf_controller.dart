import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/signed_pdf_preview_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;

class SignedPdfController extends GetxController {
  var signedPdfs = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSignedPdfs();
  }

  Future<void> _loadSignedPdfs() async {
    Directory? downloadsDirectory;
    if (Platform.isAndroid) {
      downloadsDirectory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    }

    final directory = Directory(downloadsDirectory!.path);
    final pdfFiles = directory
        .listSync()
        .where((file) => file.path.endsWith('.pdf'))
        .map((file) => File(file.path))
        .toList();

    signedPdfs.assignAll(pdfFiles);
  }

  Future<void> sharePdf(File pdfFile) async {
    final xFile = XFile(pdfFile.path);
    Share.shareXFiles([xFile]);
  }

  Future<void> deletePdf(File pdfFile) async {
    await pdfFile.delete();
    signedPdfs.remove(pdfFile);
    Get.snackbar('Success', 'PDF deleted successfully');
  }

  void viewPdf(File pdfFile) {
    Get.to(() => SignedPdfViewerScreen(pdfFile.path));
  }

  String getFormattedDate(File file) {
    final lastModified = file.lastModifiedSync();
    return '${lastModified.day}/${lastModified.month}/${lastModified.year}';
  }

  // Future<Uint8List> generatePdfThumbnail(File pdfFile,
  //     {int width = 200, int height = 200}) async {
  //   // Read the PDF file
  //   final bytes = await pdfFile.readAsBytes();

  //   // Load the PDF document
  //   // final pdf = pw.PdfDocument(PdfParser.parse(bytes));
  //   final pdf = pw.PdfDocument.openData(bytes);

  //   // Get the first page
  //   final page = pdf.page(1);

  //   // Render the page to an image
  //   final pageImage = await page.render(width: width, height: height);

  //   // Convert the rendered image to a format we can manipulate
  //   final image = img.Image(width: pageImage.width, height: pageImage.height);
  //   for (int x = 0; x < pageImage.width; x++) {
  //     for (int y = 0; y < pageImage.height; y++) {
  //       image.setPixel(x, y, pageImage.getPixel(x, y));
  //     }
  //   }

  //   // Encode the image to PNG
  //   final pngBytes = img.encodePng(image);

  //   return Uint8List.fromList(pngBytes);
  // }
}
