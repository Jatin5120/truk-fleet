import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';

class ChattingModel {
  String sender;
  String receiver;
  String message;
  int time;
  bool isSeen;
  int bookingId;
  bool isVendor;
  ChattingModel({
    this.sender,
    this.receiver,
    this.message,
    this.time,
    this.isSeen,
    this.bookingId,
    this.isVendor = false,
  });

  factory ChattingModel.fromSnap(QueryDocumentSnapshot snap) {
    if (snap == null) return null;

    return ChattingModel(
        sender: snap.get('sender'),
        receiver: snap.get('receiver'),
        message: snap.get('message'),
        time: snap.get('time'),
        isSeen: snap.get('isSeen'),
        bookingId: snap.get('bookingId'),
        isVendor: (snap.data() as Map<String, dynamic>).containsKey('isVendor')
            ? snap.get('isVendor')
            : false);
  }

  ChattingModel copyWith({
    String sender,
    String receiver,
    String message,
    int time,
    bool isSeen,
    int bookingId,
    bool isVendor,
  }) {
    return ChattingModel(
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      message: message ?? this.message,
      time: time ?? this.time,
      isSeen: isSeen ?? this.isSeen,
      bookingId: bookingId ?? this.bookingId,
      isVendor: isVendor ?? this.isVendor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'time': time,
      'isSeen': isSeen,
      'bookingId': bookingId,
      'isVendor': isVendor,
    };
  }

  factory ChattingModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ChattingModel(
      sender: map['sender'],
      receiver: map['receiver'],
      message: map['message'],
      time: map['time'],
      isSeen: map['isSeen'],
      bookingId: map['bookingId'],
      isVendor: map['isVendor'],
    );
  }
}

class MyChatting with ChangeNotifier {
  final User user = FirebaseAuth.instance.currentUser;
  bool isChatLoading = true;
  List<ChattingModel> chattings = [];
  List<ChattingModel> get chats => chattings;
  getAllMessages(String vendor, int bookingId) async {
    isChatLoading = true;
    Stream<QuerySnapshot> snap = FirebaseFirestore.instance
        .collection(FirebaseHelper.chatCollection)
        .orderBy('time', descending: true)
        .snapshots();
    List<QueryDocumentSnapshot> d = [];
    await snap.forEach((element) {
      d.addAll(element.docs);
    });
    if (d.length <= 0) {
      chattings = [];
    } else {
      d.forEach((element) {
        ChattingModel model = ChattingModel.fromSnap(element);
        if (model.receiver == vendor || model.receiver == user.uid) {
          if (model.sender == vendor || model.sender == user.uid) {
            if (model.bookingId == bookingId) {
              chattings.add(model);
            }
          }
        }
      });
    }
    notifyListeners();
  }
}
