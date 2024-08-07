import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SignatureController extends GetxController {
  var signatures = <Signature>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSignatures();
  }

  Future<void> loadSignatures() async {
    final directory = await getApplicationDocumentsDirectory();
    final signatureDir = Directory('${directory.path}/signatures');
    final files =
        signatureDir.listSync().where((file) => file.path.endsWith('.png'));

    signatures.assignAll(files.map((file) {
      final name = file.path.split('/').last;
      final creationDate = File(file.path).statSync().changed;
      return Signature(name: name, path: file.path, dateCreated: creationDate);
    }).toList());
  }

  void deleteSignature(Signature signature) {
    final file = File(signature.path);
    if (file.existsSync()) {
      file.deleteSync();
      signatures.remove(signature);
    }
  }
}

class Signature {
  final String name;
  final String path;
  final DateTime dateCreated;

  Signature(
      {required this.name, required this.path, required this.dateCreated});
}
