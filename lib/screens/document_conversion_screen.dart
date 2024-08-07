import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/document_conversion_controller.dart';

class DocumentConversionScreen extends StatelessWidget {
  DocumentConversionScreen({super.key});

  final DocumentConversionController controller =
      Get.put(DocumentConversionController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document Conversion'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Excel to PDF'),
              Tab(text: 'Word to PDF'),
              Tab(text: 'PPTX to PDF'),
              Tab(text: 'PDF to PPTX'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ConversionTab(
              onConvert: () => controller.convertToPdf(),
            ),
            ConversionTab(
              onConvert: () => controller.convertToPdf(),
            ),
            ConversionTab(
              onConvert: () => controller.convertToPdf(),
            ),
            ConversionTab(
              onConvert: () => controller.convertToPptx(),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversionTab extends StatelessWidget {
  final VoidCallback onConvert;

  const ConversionTab({required this.onConvert});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () =>
                Get.find<DocumentConversionController>().pickDocument(),
            child: const Text('Select Document'),
          ),
          // const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: onConvert,
          //   child: const Text('Convert'),
          // ),
        ],
      ),
    );
  }
}

void main() {
  runApp(GetMaterialApp(
    home: DocumentConversionScreen(),
  ));
}
