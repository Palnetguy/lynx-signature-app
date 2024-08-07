import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? profileImage;

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  profileImage =
                      await picker.pickImage(source: ImageSource.gallery);
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage != null
                      ? FileImage(File(profileImage!.path))
                      : const AssetImage('assets/profile_placeholder.png')
                          as ImageProvider,
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await authController.signUp(emailController.text,
                      passwordController.text, nameController.text);
                  if (profileImage != null) {
                    String? downloadUrl = await authController
                        .uploadProfilePicture(profileImage!);
                    if (downloadUrl != null) {
                      await authController.updateUserProfile(
                          nameController.text, downloadUrl);
                    }
                  }
                },
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed('/login');
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
