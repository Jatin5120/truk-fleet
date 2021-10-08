import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/models/shipment_model.dart';

final User user = FirebaseAuth.instance.currentUser;

class FleetRideController {}

class FleetRideModel with ChangeNotifier {
  List<ShipmentModel> shipmentList = [];
  bool isShipmentLoading = true;
  List<ShipmentModel> get shipments => shipmentList;

  getAllDriverShipment() async {
    isShipmentLoading = true;
    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    final streamSnaps =
        reference.where('agent', isEqualTo: user.uid).orderBy('bookingId', descending: true).snapshots();
    streamSnaps.listen((event) {
      shipmentList = [];
      for (QueryDocumentSnapshot snaps in event.docs) {
        shipmentList.add(ShipmentModel.fromSnapshot(snaps));
      }
      isShipmentLoading = false;
      notifyListeners();
    });
  }
}
