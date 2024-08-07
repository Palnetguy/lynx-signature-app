import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/signature_controller.dart';

class SavedSignatureScreen extends StatelessWidget {
  final SignatureController controller = Get.put(SignatureController());

  SavedSignatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Signatures'),
      ),
      body: Obx(() {
        if (controller.signatures.isEmpty) {
          return const Center(child: Text('No signatures found'));
        }

        return ListView.builder(
          itemCount: controller.signatures.length,
          itemBuilder: (context, index) {
            final signature = controller.signatures[index];
            return ListTile(
              shape: const Border(
                  bottom: BorderSide(
                width: 1,
                color: Colors.black,
              )),
              leading: Image.file(File(signature.path), width: 60, height: 50),
              title: Text(signature.name),
              subtitle: Text(
                  'Created: ${DateFormat.yMMMd().format(signature.dateCreated)}'),
              onTap: () {
                Get.defaultDialog(
                  title: 'Selected',
                  middleText: 'Selected: ${signature.name}',
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Delete Signature',
                    middleText:
                        'Are you sure you want to delete ${signature.name}?',
                    textConfirm: 'Yes',
                    textCancel: 'No',
                    onConfirm: () {
                      controller.deleteSignature(signature);
                      Get.back();
                    },
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
