import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  User? get user => auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    auth.authStateChanges().listen((User? user) {
      isLoggedIn.value = user != null;
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'profilePictureUrl': '',
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<DocumentSnapshot> getUserProfile() async {
    return await firestore.collection('users').doc(user?.uid).get();
  }

  Future<void> updateUserProfile(String name, String? profilePictureUrl) async {
    Map<String, dynamic> data = {'name': name};
    if (profilePictureUrl != null) {
      data['profilePictureUrl'] = profilePictureUrl;
    }
    await firestore.collection('users').doc(user?.uid).update(data);
  }

  Future<String?> uploadProfilePicture(XFile image) async {
    try {
      Reference ref = storage.ref().child('profile_pictures/${user?.uid}');
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: oldPassword);

      // Reauthenticate the user
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(newPassword);
      Get.snackbar('Success', 'Password changed successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void updateProfile(String username, String email) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      await user.updateDisplayName(username);
      await user.updateEmail(email);
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
