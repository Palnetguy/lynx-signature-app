import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class HomeScreenWidget extends StatelessWidget {
  HomeScreenWidget({super.key});
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Martin Rhine'),
        // centerTitle: true,
        // leading: const Icon(Icons.menu),
        actions: [
          GestureDetector(
            onTap: () {
              Get.toNamed('/profile');
            },
            child: const CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/profile_picture.png'), // Add your profile image
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.signOut();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // _buildGridItem('Auto Signature', Icons.auto_mode, Colors.green,
            //     '/auto-signature'),
            _buildGridItem(
                'Draw Signature', Icons.edit, Colors.purple, '/draw-signature'),
            _buildGridItem('Scan Signature', Icons.document_scanner,
                Colors.lightBlue, '/scan-signature'),
            _buildGridItem('Sign Document', Icons.assignment_turned_in,
                Colors.lightGreen, '/sign-document'),
            _buildGridItem('Saved Signature', Icons.image, Colors.orange,
                '/saved-signature'),
            _buildGridItem('Document Conversion', Icons.transform, Colors.red,
                '/document-conversion'),
            // _buildGridItem('Upload Document', Icons.upload_file,
            //     Colors.blueGrey, '/upload-document'),
            _buildGridItem('Share Document', Icons.share, Colors.deepPurple,
                '/share-document'),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
      String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 50),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
