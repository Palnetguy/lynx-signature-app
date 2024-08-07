import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants/firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';

import 'screens/auto_signature_screen.dart';
import 'screens/document_conversion_screen.dart';
import 'screens/draw_signature_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_signature_screen.dart';
import 'screens/scan_signature_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/share_document_screen.dart';
import 'screens/sign_document_screen.dart';
import 'screens/signed_pdfs_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/upload_document_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final ThemeController themeController = Get.put(ThemeController());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeController.isDarkMode.value
            ? ThemeData.dark()
            : ThemeData.light(),
        // theme: ThemeData.light(),
        // darkTheme: ThemeData.dark(),
        // themeMode: ThemeMode.system,
        // home: authController.isLoggedIn.value ? HomeScreen() : LoginScreen(),
        // initialRoute: '/',
        home: HomeScreen(),
        getPages: [
          GetPage(
              name: '/',
              page: () => authController.isLoggedIn.value
                  ? HomeScreen()
                  : LoginScreen()),
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/signup', page: () => SignUpScreen()),
          GetPage(name: '/home', page: () => HomeScreen()),
          GetPage(name: '/profile', page: () => ProfileScreen()),
          GetPage(
              name: '/auto-signature', page: () => const AutoSignatureScreen()),
          GetPage(name: '/draw-signature', page: () => DrawSignatureScreen()),
          GetPage(
              name: '/scan-signature', page: () => const ScanSignatureScreen()),
          GetPage(
              name: '/sign-document', page: () => const SignDocumentScreen()),
          GetPage(name: '/saved-signature', page: () => SavedSignatureScreen()),
          GetPage(
              name: '/document-conversion',
              page: () => DocumentConversionScreen()),
          GetPage(
              name: '/upload-document',
              page: () => const UploadDocumentScreen()),
          GetPage(
              name: '/share-document', page: () => const ShareDocumentScreen()),
          GetPage(name: '/settings', page: () => SettingsScreen()),
          GetPage(name: '/signed-documents', page: () => SignedPdfListScreen()),
        ],
      );
    });
  }
}
