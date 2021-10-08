import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';

class DocumentType {
  static const String adhaar = 'adhaar';
  static const String dl = 'driving_license';
  static const String panCard = 'pan_card';
  static const String selfie = 'selfie';
}

class DocumentController {
  final User user = FirebaseAuth.instance.currentUser;
  static String docCollection = FirebaseHelper.driverDocumentCollection;
  final FirebaseStorage storage = FirebaseStorage.instance;
  Future<bool> getMasterUploadStatus({String id}) async {
    if (id == null) {
      id = user.uid;
    }
    print(id);
    CollectionReference reference = FirebaseFirestore.instance.collection(docCollection);
    DocumentSnapshot snapshot = await reference.doc(id).get();
    return snapshot.exists;
  }

  Future<Map<String, dynamic>> getPerticularUploadStatus({String id}) async {
    if (id == null) {
      id = user.uid;
    }
    CollectionReference reference = FirebaseFirestore.instance.collection(docCollection);
    DocumentSnapshot snapshot = await reference.doc(id).get();
    Map<String, dynamic> m = snapshot.data();
    return {
      DocumentType.adhaar: [m.containsKey(DocumentType.adhaar), m[DocumentType.adhaar]],
      DocumentType.dl: [m.containsKey(DocumentType.dl), m[DocumentType.dl]],
      DocumentType.panCard: [m.containsKey(DocumentType.panCard), m[DocumentType.panCard]],
      DocumentType.selfie: [m.containsKey(DocumentType.selfie), m[DocumentType.selfie]],
    };
  }

  //uploadDocument
  Future<String> uploadDocument(String type, File file) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}_$type";
    String ext = file.path.split('/').last.split('.').last;
    TaskSnapshot uploadTask = await storage.ref().child('documents/$fileName.$ext').putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  //update document status
  Future<void> updateDocumentStatus(String type, File file, {String id}) async {
    if (id == null) {
      id = user.uid;
    }
    CollectionReference reference = FirebaseFirestore.instance.collection(docCollection);
    String url = await uploadDocument(type, file);
    Map<String, dynamic> m = {type: url};
    DocumentSnapshot sn = await reference.doc(id).get();
    if (sn.exists) {
      await reference.doc(id).update(m);
    } else {
      await reference.doc(id).set(m);
    }
  }
}
