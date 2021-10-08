import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';

class ProfileController {
  final User user = FirebaseAuth.instance.currentUser;
  static String userCollection = FirebaseHelper.fleetOwnerCollection;
  FirebaseStorage storage = FirebaseStorage.instance;

  //updateDriver
  Future<void> updateUser(
      {String name, String email, File image, String gst, String company, String regNo, String upi}) async {
    String uid = user.uid;
    CollectionReference reference = FirebaseFirestore.instance.collection(userCollection);
    Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'gst': gst,
      'company': company,
      'regNumber': regNo,
      'upiId': upi,
    };
    if (image != null) {
      String myImageUrl = await uploadImage(image);
      userData['image'] = myImageUrl;
    }
    await reference.doc(uid).update(userData);
  }

  //uploadImage
  Future<String> uploadImage(File image) async {
    String fileName = "${user.uid}${DateTime.now().millisecondsSinceEpoch}";
    String ext = image.path.split('/').last.split('.').last;
    print('$fileName.$ext');
    TaskSnapshot uploadTask = await storage.ref().child('images/$fileName.$ext').putFile(image);
    return await uploadTask.ref.getDownloadURL();
  }
}

//String extension(String path, [int level = 1]) => extension(path, level);
