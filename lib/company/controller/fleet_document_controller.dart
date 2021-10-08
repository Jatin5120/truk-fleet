import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';

class FleetDocumentType {
  static const String adhaar = 'adhaar';
  static const String dl = 'driving_license';
  static const String panCard = 'pan_card';
  static const String selfie = 'selfie';
  static const String company_registration = 'company_registration';
  static const String gst_registration = 'gst_registration';
  static const String bank_proof = 'bank_proof';
}

class FleetDocumentController {
  final User user = FirebaseAuth.instance.currentUser;
  static String docCollection = FirebaseHelper.fleetDocument;
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
      FleetDocumentType.adhaar: [m.containsKey(FleetDocumentType.adhaar), m[FleetDocumentType.adhaar]],
      FleetDocumentType.dl: [m.containsKey(FleetDocumentType.dl), m[FleetDocumentType.dl]],
      FleetDocumentType.panCard: [m.containsKey(FleetDocumentType.panCard), m[FleetDocumentType.panCard]],
      FleetDocumentType.selfie: [m.containsKey(FleetDocumentType.selfie), m[FleetDocumentType.selfie]],
      FleetDocumentType.company_registration: [m.containsKey(FleetDocumentType.company_registration), m[FleetDocumentType.company_registration]],
      FleetDocumentType.gst_registration: [m.containsKey(FleetDocumentType.gst_registration),m[FleetDocumentType.gst_registration]],
      FleetDocumentType.bank_proof: [m.containsKey(FleetDocumentType.bank_proof),m[FleetDocumentType.bank_proof]]
    };
  }

  //uploadDocument
  Future<String> uploadDocument(String type, File file) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}_$type";
    String ext = file.path.split('/').last.split('.').last;
    print('$fileName.$ext');
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
