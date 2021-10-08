import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class WalletModel {
  double amount;
  int lastUpdate;
  WalletModel({
    this.amount,
    this.lastUpdate,
  });

  WalletModel copyWith({
    double amount,
    int lastUpdate,
  }) {
    return WalletModel(
      amount: amount ?? this.amount,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'lastUpdate': lastUpdate,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return WalletModel(
      amount: double.parse(map['amount'].toString()),
      lastUpdate: map['lastUpdate'],
    );
  }

  factory WalletModel.fromSnapshot(DocumentSnapshot map) {
    if (map == null) return null;

    return WalletModel(
      amount: double.parse(map.get('amount').toString()),
      lastUpdate: map.get('lastUpdate'),
    );
  }
}

class MyWallet extends ChangeNotifier {
  WalletModel model;
  WalletModel get myWallet => model;
  bool isLoading = false;

  getWalletBalance() async {
    isLoading = true;
    final User user = FirebaseAuth.instance.currentUser;
    CollectionReference reference = FirebaseFirestore.instance.collection('Wallet');
    Stream<DocumentSnapshot> data = reference.doc(user.uid).snapshots();
    data.listen((event) {
      if (event.exists) {
        model = WalletModel.fromSnapshot(event);
      }
      isLoading = false;
      notifyListeners();
    });
    // data.forEach((element) {
    //   if (element.exists) {
    //     model = WalletModel.fromSnapshot(element);
    //   } else {
    //     model = WalletModel(amount: 0, lastUpdate: 0);
    //   }
    // });

    // isLoading = false;
    // notifyListeners();
  }
}
