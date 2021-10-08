import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String id;
  String uid;
  String message;
  int time;
  bool isVendor;
  bool isDriver;
  bool isSeen;
  NotificationModel({
    this.id,
    this.uid,
    this.message,
    this.time,
    this.isVendor,
    this.isDriver,
    this.isSeen = false,
  });

  NotificationModel copyWith({
    String uid,
    String message,
    int time,
    bool isVendor,
    bool isDriver,
    String id,
    bool isSeen,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      message: message ?? this.message,
      time: time ?? this.time,
      isVendor: isVendor ?? this.isVendor,
      isDriver: isDriver ?? this.isDriver,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'msg': message,
      'time': time,
      'isVendor': isVendor,
      'isDriver': isDriver,
      'id': id,
      'isSeen': isSeen ?? false,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return NotificationModel(
      id: map['id'],
      uid: map['uid'],
      message: map['msg'],
      time: map['time'],
      isVendor: map['isVendor'],
      isDriver: map['isDriver'],
    );
  }
  factory NotificationModel.fromSnap(QueryDocumentSnapshot snap) {
    if (snap == null) return null;

    return NotificationModel(
      id: snap.id,
      uid: snap.get('uid'),
      message: snap.get('msg'),
      time: snap.get('time'),
      isVendor: snap.get('isVendor'),
      isDriver: (snap.data() as Map<String, dynamic>).containsKey("isDriver")
          ? snap.get('isDriver')
          : false,
      isSeen: (snap.data() as Map<String, dynamic>).containsKey("isSeen")
          ? snap.get('isSeen')
          : false,
    );
  }
}
