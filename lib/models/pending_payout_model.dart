import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/company/controller/my_shipment_controller.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';

class PendingPayoutModel {
  String uid;
  String agent;
  int bookingId;
  double amount;
  String status;
  int time;
  PendingPayoutModel({
    this.uid,
    this.agent,
    this.bookingId,
    this.amount,
    this.status,
    this.time,
  });

  PendingPayoutModel copyWith({
    String uid,
    String agent,
    int bookingId,
    double amount,
    String status,
    int time,
  }) {
    return PendingPayoutModel(
      uid: uid ?? this.uid,
      agent: agent ?? this.agent,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'agent': agent,
      'bookingId': bookingId,
      'amount': amount,
      'status': status,
      'time': time,
    };
  }

  factory PendingPayoutModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PendingPayoutModel(
      uid: map['uid'],
      agent: map['agent'],
      bookingId: map['bookingId'],
      amount: map['amount'],
      status: map['status'],
      time: map['time'],
    );
  }

  factory PendingPayoutModel.fromSnap(QueryDocumentSnapshot map) {
    if (map == null) return null;

    return PendingPayoutModel(
      uid: map.get('uid'),
      agent: map.get('agent'),
      bookingId: map.get('bookingId'),
      amount: double.parse(map.get('amount').toString()),
      status: map.get('status'),
      time: map.get('time'),
    );
  }
}

class MyPendingPayout extends ChangeNotifier {
  List<PendingPayoutModel> list = [];
  List<PendingPayoutModel> get pendingList => list;
  StreamSubscription streamSubscription;
  getPendingPayouts() async {
    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.payoutCollection);
    final stream = reference.where('agent', isEqualTo: user.uid).orderBy('time', descending: true).snapshots();
    streamSubscription = stream.listen((qSnap) {
      list = [];
      print(qSnap.docs.length);
      for (QueryDocumentSnapshot d in qSnap.docs) {
        PendingPayoutModel m = PendingPayoutModel.fromSnap(d);
        list.add(m);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }
}
