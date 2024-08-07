import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:libre_doc_converter/libre_doc_converter.dart';

class DocumentConversionController extends GetxController {
  var selectedDocument = Rxn<PlatformFile>();

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      selectedDocument.value = result.files.first;
      Get.defaultDialog(
        title: 'Document selected',
        middleText: 'Document selected: ${selectedDocument.value!.name}',
        onConfirm: () {
          convertToPdf(); // This is where the conversion happens
        },
        onCancel: () {},
      );
    }
  }

  Future<void> convertToPdf() async {
    if (selectedDocument.value == null) {
      Get.snackbar('Error', 'Please select a document first.');
      return;
    }

    try {
      final converter = LibreDocConverter(
        inputFile: File(selectedDocument.value!.path!),
      );
      final pdfFile = await converter.toPdf();

      Get.defaultDialog(
        title: 'Conversion Successful',
        middleText: 'Document converted to PDF: ${pdfFile.path}',
      );
    } catch (e) {
      Get.defaultDialog(
        title: 'Conversion Failed',
        middleText: 'Failed to convert document to PDF: $e',
      );
    }
  }

  Future<void> convertToPptx() async {
    if (selectedDocument.value == null) {
      Get.snackbar('Error', 'Please select a document first.');
      return;
    }

    //   try {
    //     final converter = LibreDocConverter(
    //       inputFile: File(selectedDocument.value!.path!),
    //     );
    //     final pptxFile = await converter.toPptx();

    //     Get.defaultDialog(
    //       title: 'Conversion Successful',
    //       middleText: 'Document converted to PPTX: ${pptxFile.path}',
    //     );
    //   } catch (e) {
    //     Get.defaultDialog(
    //       title: 'Conversion Failed',
    //       middleText: 'Failed to convert document to PPTX: $e',
    //     );
    //   }
  }
}
