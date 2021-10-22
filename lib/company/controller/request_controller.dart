import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/models/notification_model.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/request_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

final User me = FirebaseAuth.instance.currentUser;
final FirebaseStorage storage = FirebaseStorage.instance;

class RequestController {
  Future<void> addQuote(
      QuoteModel quoteModel, RequestModel requestModel) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.quoteCollection);
    CollectionReference referenceRequest =
        FirebaseFirestore.instance.collection(FirebaseHelper.requestCollection);
    CollectionReference notificationRef = FirebaseFirestore.instance
        .collection(FirebaseHelper.notificationCollection);
    await reference.add(quoteModel.toMap());
    await notificationRef.add(NotificationModel(
      isDriver: false,
      isVendor: false,
      message: "You got a new quote on request",
      time: DateTime.now().millisecondsSinceEpoch,
      uid: quoteModel.uid,
    ).toMap());
    return await referenceRequest.doc(requestModel.id).update({
      'status': RequestStatus.quoted,
    });
  }

  Future<void> assignDriver(QuoteModel quoteModel, String driver,
      {File eWayBill}) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.quoteCollection);
    CollectionReference refShipment =
        FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    await reference.doc(quoteModel.id).update({'status': 'assigned'});
    String billUrl =
        await uploadEWayBill(eWayBill, quoteModel.bookingId.toString());
    Map<String, dynamic> m = ShipmentModel(
      agent: quoteModel.agent,
      bookingDate: quoteModel.bookingDate,
      bookingId: quoteModel.bookingId,
      destination: quoteModel.destination,
      source: quoteModel.source,
      driver: driver,
      insured: quoteModel.insured,
      load: quoteModel.load,
      mandate: quoteModel.mandate,
      materials: quoteModel.materials,
      mobile: quoteModel.mobile,
      paymentStatus: quoteModel.paymentStatus,
      pickupDate: quoteModel.pickupDate,
      price: quoteModel.price,
      status: 'pending',
      truk: quoteModel.truk,
      trukName: quoteModel.trukName,
      ewaybill: billUrl,
      uid: quoteModel.uid,
      commission: '5',
        driverId:driver
      //TODO: check for commission
    ).toMap();
    return refShipment.add(m);
  }

  updatePrice(QuoteModel quoteModel, String price) async {
    CollectionReference quoteRef =
        FirebaseFirestore.instance.collection(FirebaseHelper.quoteCollection);
    await quoteRef.doc(quoteModel.id).update({'price': price});
  }

  Future<String> uploadEWayBill(File file, String billNo) async {
    String fileName = "EwayBill - $billNo";
    String ext = file.path.split('/').last.split('.').last;
    print('$fileName.$ext');
    TaskSnapshot uploadTask =
        await storage.ref().child('EWaybill/$fileName.$ext').putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}

class MyRequest with ChangeNotifier {
  List<Map<String, dynamic>> requestList = [];
  List<Map<String, dynamic>> get requests => requestList;
  bool isLoading = true;
  List<QuoteModel> quoteList = [];
  List<QuoteModel> get quotes => quoteList;
  bool isQuoteLoading = true;

  getRequestList() async {
    isLoading = true;
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.requestCollection);
    final requestData =
        reference.orderBy('bookingId', descending: true).snapshots();

    requestData.listen((event) async {
      requestList = [];
      for (QueryDocumentSnapshot snap in event.docs) {
        RequestModel reqModel = RequestModel.fromSnapshot(snap);
        String user = reqModel.uid;
        CollectionReference userRef = FirebaseFirestore.instance
            .collection(FirebaseHelper.userCollection);

        DocumentSnapshot userSnap = await userRef.doc(user).get();
        UserModel model = UserModel.fromSnapshot(userSnap);
        print(reqModel.status);

        requestList.add({
          'user': model,
          'request': reqModel,
        });
      }
      isLoading = false;
      requestList = requestList.distinct();
      notifyListeners();
    });
  }

  getQuoteList() async {
    isQuoteLoading = true;
    CollectionReference quoteRef =
        FirebaseFirestore.instance.collection(FirebaseHelper.quoteCollection);
    Stream<QuerySnapshot> quoteSnap = quoteRef
        .where('agent', isEqualTo: me.uid)
        .orderBy('bookingDate', descending: true)
        .snapshots();
    final test =
        await quoteRef.where('mobile', isEqualTo: '+919664722610').get();
    print('Data is --> ${test.docs.length}');
    quoteSnap.listen((ev) {
      print('Your quotelise is ${ev.docs.length}');
      quoteList = [];
      for (QueryDocumentSnapshot q in ev.docs) {
        QuoteModel model = QuoteModel.fromSnapshot(q);
        //if (model.status != RequestStatus.assigned) {
        quoteList.add(model);
        //}
      }
      quoteList = quoteList.distinct();
      isQuoteLoading = false;
      notifyListeners();
    });
  }
}
