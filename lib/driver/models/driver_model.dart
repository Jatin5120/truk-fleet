import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../firebase_helper/firebase_helper.dart';

class DriverModel {
  String uid;
  String name;
  String mobile;
  String email;
  String city;
  String state;
  String company;
  String image;
  int joining;
  String token;
  String agent;
  String driverId;
  bool status;
  bool cstatus;
  bool notification;
  DriverModel(
      {this.uid,
      this.name,
      this.mobile,
      this.email,
      this.city,
      this.state,
      this.company,
      this.joining,
      this.token,
      this.image,
      this.agent,
      this.driverId,
      this.status = true,
      this.notification = true,
      this.cstatus = true});

  DriverModel copyWith(
      {String uid,
      String name,
      String mobile,
      String email,
      String city,
      String state,
      String company,
      int joining,
      String token,
      String agent,
      String driverId,
      String image,
      bool status,
      bool notification,
      bool cstatus}) {
    return DriverModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      city: city ?? this.city,
      state: state ?? this.state,
      company: company ?? this.company,
      joining: joining ?? this.joining,
      image: image ?? this.image,
      token: token ?? this.token,
      agent: agent ?? this.agent,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      notification: notification ?? this.notification,
      cstatus: cstatus ?? this.cstatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'mobile': mobile,
      'email': email,
      'city': city,
      'state': state,
      'company': company,
      'joining': joining,
      'token': token,
      'image': image,
      'agent': agent,
      'driverId': driverId,
      'status': status ?? true,
      'notification': notification ?? true,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return DriverModel(
      uid: map['uid'],
      name: map['name'],
      mobile: map['mobile'],
      email: map['email'],
      city: map['city'],
      state: map['state'],
      company: map['company'],
      token: map['token'],
      image: map['image'],
      joining: map['joining'],
      agent: map['agent'],
      driverId: map['driverId'],
      status: map['status'] ?? true,
      notification: map['notification'] ?? true,
    );
  }

  factory DriverModel.fromSnapshot(DocumentSnapshot map) {
    if (map == null) return null;
    Map<String, dynamic> data = map.data();

    return DriverModel(
      uid: map.get('uid'),
      image: data.containsKey('image') ? map.get('image') ?? 'na' : 'na',
      name: map.get('name'),
      mobile: map.get('mobile'),
      email: map.get('email'),
      city: map.get('city'),
      state: map.get('state'),
      company: map.get('company'),
      joining: map.get('joining'),
      token: data.containsKey('token') ? map.get('token') : 'token',
      agent: map.get('agent'),
      driverId: map.get('driverId'),
      status: data.containsKey('status') ? map.get('status') : true,
      notification:
          data.containsKey('notification') ? map.get('notification') : true,
    );
  }
}

class MyDriverUser extends ChangeNotifier {
  DriverModel driverModel;
  bool isUserLoading = true;
  final User currentUser = FirebaseAuth.instance.currentUser;
  DriverModel get user => driverModel;

  getUserFromDatabase() async {
    isUserLoading = true;

    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.driverCollection);
    final d = reference.doc(currentUser.uid).snapshots();
    // driverModel = DriverModel.fromSnapshot(d);
    d.listen((event) {
      if (event.exists) {
        driverModel = DriverModel.fromSnapshot(event);
      }
      isUserLoading = false;

      notifyListeners();
    });
  }

  updateNotification(bool status) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.driverCollection);
    await reference.doc(currentUser.uid).update({
      "notification": status,
    });
  }
}
