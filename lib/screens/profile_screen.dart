import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: authController.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData) {
          var userData = snapshot.data?.data() as Map<String, dynamic>;
          nameController.text = userData['name'];
          String? profilePictureUrl = userData['profilePictureUrl'];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        String? downloadUrl =
                            await authController.uploadProfilePicture(image);
                        if (downloadUrl != null) {
                          await authController.updateUserProfile(
                              nameController.text, downloadUrl);
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profilePictureUrl != null &&
                              profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : const AssetImage('assets/profile_placeholder.png')
                              as ImageProvider,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      authController.updateUserProfile(
                          nameController.text, null);
                    },
                    child: const Text('Update Profile'),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('No data available')),
        );
      },
    );
  }
}
