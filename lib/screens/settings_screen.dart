import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

import '../controllers/theme_controller.dart';
import 'change_password_screen.dart';

import 'update_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Change Password'),
              onTap: () {
                Get.to(() => ChangePasswordScreen());
              },
            ),
            ListTile(
              title: const Text('Update Profile'),
              onTap: () {
                Get.to(() => UpdateProfileScreen());
              },
            ),
            Obx(() {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeController.isDarkMode.value,
                onChanged: (value) {
                  themeController.toggleTheme();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
