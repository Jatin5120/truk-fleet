import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/models/truk_model.dart';

class TrukController {
  final User user = FirebaseAuth.instance.currentUser;
  Future<void> addTruk(TrukModel trukModel) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    String id = trukModel.trukNumber;
    await reference.doc(id).set(trukModel.toMap());
  }

  Future<void> updateTruk(TrukModel trukModel) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    String id = trukModel.trukNumber;
    await reference.doc(id).update(trukModel.toMap());
  }

  //delete Truk
  Future<void> deleteTruk(String trukNumber) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    await reference.doc(trukNumber.toUpperCase()).delete();
  }
}

class TrukDocumentType {
  static const String insurance = 'insurance';
  static const String fitness = 'fitness';
  static const String permit = 'permit';
  static const String rc = 'rc';
}

class TrukDocumentController {
  final User user = FirebaseAuth.instance.currentUser;
  static String docCollection = FirebaseHelper.trukDocumentCollection;
  final FirebaseStorage storage = FirebaseStorage.instance;
  Future<bool> getMasterUploadStatus({String id}) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(docCollection);
    DocumentSnapshot snapshot = await reference.doc(id).get();
    return snapshot.exists;
  }

  Future<Map<String, dynamic>> getPerticularUploadStatus({String id}) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(docCollection);
    DocumentSnapshot snapshot = await reference.doc(id).get();
    Map<String, dynamic> m = snapshot.data();
    return {
      TrukDocumentType.insurance: [m.containsKey(TrukDocumentType.insurance), m[TrukDocumentType.insurance]],
      TrukDocumentType.rc: [m.containsKey(TrukDocumentType.rc), m[TrukDocumentType.rc]],
      TrukDocumentType.permit: [m.containsKey(TrukDocumentType.permit), m[TrukDocumentType.permit]],
      TrukDocumentType.fitness: [m.containsKey(TrukDocumentType.fitness), m[TrukDocumentType.fitness]],
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
