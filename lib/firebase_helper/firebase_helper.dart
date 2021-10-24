import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/models/notification_model.dart';
import '../models/material_model.dart';
import '../models/user_model.dart';
import '../sessionmanagement/session_manager.dart';

class FirebaseHelper {
  static const String walletCollection = 'Wallet';
  static const String walletTranscationCollection = 'WalletTransaction';
  static const String userCollection = 'Users';
  static const String transactionCollection = 'Transaction';
  static const String requestCollection = 'Request';
  static const String quoteCollection = 'Quote';
  static const String driverCollection = 'Drivers';
  static const String fleetOwnerCollection = 'FleetOwners';
  static const String driverDocumentCollection = 'DriverDocument';
  static const String rideCollection = 'Rides';
  static const String driverRegistered = 'RegisteredDriver';
  static const String trukCollection = 'Truks';
  static const String fleetDocument = 'FleetDocument';
  static const String shipment = 'Shipment';
  static const String chatListCollection = 'ChatList';
  static const String chatCollection = 'Chats';
  static const String shipmentImageCollection = 'ShipmentImages';
  static const String shipmentEndImageCollection = 'ShipmentEndImages';
  static const String notificationCollection = "Notifications";
  static const String trukDocumentCollection = "TrukDocument";
  static const String payoutCollection = "PendingPayout";
  static const String invoiceCollection = "invoice";
  static const String insuranceCollection = "Insurance";

  static FirebaseAuth _auth = FirebaseAuth.instance;
  User user = _auth.currentUser;
  Future<UserModel> getCurrentUser({String uid, String type}) async {
    String u = uid;
    if (uid == null) {
      u = user.uid;
    }
    String collectionName = driverCollection;
    if (type == LoginType.company) collectionName = fleetOwnerCollection;
    CollectionReference reference =
        FirebaseFirestore.instance.collection(collectionName);

    final d = await reference.doc(u).get();
    if (d.exists) {
      return UserModel.fromSnapshot(d);
    }
    return null;
  }

  Future insertUser(DriverModel model, String type) async {
    String collectionName = driverCollection;
    if (type == LoginType.company) collectionName = fleetOwnerCollection;
    CollectionReference reference =
        FirebaseFirestore.instance.collection(collectionName);

    await reference.doc(model.uid).set(model.toMap());
    await SharedPref()
        .createSession(model.uid, model.name, model.email, model.mobile, type);
  }

  Future<void> updateUser({String name, String email, String company}) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(driverCollection);
    Map<String, dynamic> userData = {
      'uid': user.uid,
      'name': name,
      'email': email,
      'company': company,
    };
    await reference.doc(user.uid).update(userData);
  }

  Future insertAgent(UserModel model, String type) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(fleetOwnerCollection);
    await reference.doc(model.uid).set(model.toMap());
    await SharedPref()
        .createSession(model.uid, model.name, model.email, model.mobile, type);
  }

  Future<String> insertRequest({
    @required String pickupDate,
    @required List<MaterialModel> materials,
    @required LatLng source,
    @required LatLng destination,
    @required String trukType,
    @required String loadType,
    @required String mandateType,
    @required bool isInsured,
  }) async {
    User user = FirebaseAuth.instance.currentUser;
    String phoneNumber = user.phoneNumber;
    String uid = user.uid;
    final int bookingDate = DateTime.now().millisecondsSinceEpoch;
    CollectionReference reference =
        FirebaseFirestore.instance.collection("Request");
    List<Map<String, dynamic>> materialMap = [];
    for (MaterialModel m in materials) {
      materialMap.add(m.toMap());
    }
    await reference.add({
      'bookingId': bookingDate,
      'uid': uid,
      'bookingDate': bookingDate,
      'mobile': phoneNumber,
      'materials': materialMap,
      'pickupDate': pickupDate,
      'source': "${source.latitude},${source.longitude}",
      'destination': "${destination.latitude},${destination.longitude}",
      'insured': isInsured,
      'mandate': mandateType,
      'load': loadType,
      'truk': trukType,
    });
    return bookingDate.toString();
  }

  Future updateQuoteStatus(String id, String status) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(quoteCollection);
    await reference.doc(id).update({
      'status': status,
    });
  }

  Future deleteRequest(String id) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(requestCollection);
    await reference.doc(id).delete();
  }

  Future<void> updateWallet(String tid, double amount, int type) async {
    //type is  0 = debit and 1 = credit

    final currentTimeMilli = DateTime.now().millisecondsSinceEpoch;
    CollectionReference reference =
        FirebaseFirestore.instance.collection(walletCollection);
    final snapWallet = await reference.doc(user.uid).get();
    await transaction(
        tid, amount, type, currentTimeMilli, walletTranscationCollection);
    await transaction(
        tid, amount, type, currentTimeMilli, transactionCollection);
    if (snapWallet.exists) {
      double amt = type == 1
          ? snapWallet.get("amount") + amount
          : snapWallet.get("amount") - amount;
      reference.doc(user.uid).update({
        'amount': amt,
        'lastUpdate': currentTimeMilli,
      });
    } else {
      await reference.doc(user.uid).set({
        'amount': amount,
        'lastUpdate': currentTimeMilli,
      });
    }
  }

  Future transaction(String transactionId, double amount, int type, int time,
      String collection) async {
    //type is  0 = debit and 1 = credit

    CollectionReference reference =
        FirebaseFirestore.instance.collection(collection);

    await reference.add({
      'tid': transactionId,
      'amount': amount,
      'type': type == 1 ? "Credit" : "Debit",
      'uid': user.uid,
      'time': time,
    });
  }

  StreamSubscription getNotificationCount() {
    CollectionReference ref = FirebaseFirestore.instance
        .collection(FirebaseHelper.notificationCollection);
    final stream = ref.where('uid', isEqualTo: user.uid).snapshots();

    StreamSubscription s = stream.listen((element) {});
    return s;
  }

  Future seenNotification(List<NotificationModel> notifications) async {
    CollectionReference ref = FirebaseFirestore.instance
        .collection(FirebaseHelper.notificationCollection);
    for (NotificationModel m in notifications) {
      await ref.doc(m.id).update({
        'isSeen': true,
      });
    }
  }

  Future<String> getCompanyInsurance() async {
    final ref = await FirebaseFirestore.instance
        .collection(FirebaseHelper.insuranceCollection)
        .doc('truk_company')
        .get();
    var data = ref.get('insurance');
    return data;
  }
}
