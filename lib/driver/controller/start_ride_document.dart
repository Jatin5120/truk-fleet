import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:uuid/uuid.dart';

class StartRideDocument {
  final User user = FirebaseAuth.instance.currentUser;
  static String docCollection;
  final FirebaseStorage storage = FirebaseStorage.instance;
  int x = 0;
  List<String> labels = ['pickupImage1', 'pickupImage2', 'trukImage', 'selfie'];
  List<Map<String, String>> urls = [];

  Future<void> uploadImages(
      {@required List<File> images,
      @required ShipmentModel model,
      bool isEnd = false}) async {
    x = 0;
    docCollection = isEnd
        ? FirebaseHelper.shipmentEndImageCollection
        : FirebaseHelper.shipmentImageCollection;
    CollectionReference reference =
        FirebaseFirestore.instance.collection(docCollection);
    for (File image in images) {
      String label = labels[x];
      x++;
      String ext = image.path.split('/').last.split('.').last;
      String fileName = Uuid().v4();
      TaskSnapshot uploadTask = await storage
          .ref()
          .child('shipmentImages/$fileName.$ext')
          .putFile(image);
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      final d = await reference.doc(model.bookingId.toString()).get();
      if (d.exists) {
        await reference.doc(model.bookingId.toString()).update({
          label: downloadUrl,
        });
      } else {
        await reference.doc(model.bookingId.toString()).set({
          label: downloadUrl,
        });
      }
    }
    CollectionReference inRide =
        FirebaseFirestore.instance.collection('InRide');
    CollectionReference driverAvaialable =
        FirebaseFirestore.instance.collection('DriverAvailable');
    CollectionReference driverWorking =
        FirebaseFirestore.instance.collection('DriverWorking');
    if (isEnd) {
      inRide.doc(user.uid).delete();
      driverWorking.doc(user.uid).delete();
    } else {
      driverAvaialable.doc(user.uid).delete();
      inRide.doc(user.uid).set({'inRide': true});
    }
<<<<<<< HEAD
    CollectionReference rr =
        FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    await rr.doc(model.id).update({
      'status': isEnd ? RequestStatus.completed : RequestStatus.started
    }).then((value) async {
      if (isEnd) {
=======
    CollectionReference rr = FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    await rr.doc(model.id).update({'status': isEnd ? RequestStatus.completed : RequestStatus.started}).then((value) async {
      if(isEnd) {
        await rr.doc(model.id).update({'driverId':null});
>>>>>>> b93dcb153a835d65e7d5e34ddf74ae6d4494bcb6
        List<ShipmentModel> sm = [];
        await FirebaseFirestore.instance
            .collection(FirebaseHelper.shipment)
            .where('truk', isEqualTo: model.truk)
            .get()
            .then((value) {
          for (var data in value.docs) {
            if (data.get('status') == RequestStatus.pending ||
                data.get('status') == RequestStatus.started) {
              ShipmentModel sd = ShipmentModel.fromSnapshot(data);
              sm.add(sd);
            }
          }
        });
        if (sm.isEmpty) {
          await FirebaseFirestore.instance
              .collection(FirebaseHelper.trukCollection)
              .where('trukNumber', isEqualTo: model.truk)
              .get()
              .then((value) {
            for (var data in value.docs) {
              data.reference.update({'available': true});
            }
          });
        }
      }
    });
  }
}
