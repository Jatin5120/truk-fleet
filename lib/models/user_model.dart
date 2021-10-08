import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../firebase_helper/firebase_helper.dart';

class UserModel {
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
  String gst;
  String regNumber;
  bool notification;
  String upiId;
  UserModel({
    this.uid,
    this.name,
    this.mobile,
    this.email,
    this.city,
    this.state,
    this.company,
    this.joining,
    this.token,
    this.image,
    this.gst,
    this.regNumber,
    this.notification,
    this.upiId,
  });

  UserModel copyWith({
    String uid,
    String name,
    String mobile,
    String email,
    String city,
    String state,
    String company,
    int joining,
    String token,
    String regNumber,
    String gst,
    String image,
    bool notification,
    String upiId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      city: city ?? this.city,
      state: state ?? this.state,
      company: company ?? this.company,
      joining: joining ?? this.joining,
      image: image ?? this.image,
      gst: gst ?? this.gst,
      regNumber: regNumber ?? this.regNumber,
      token: token ?? this.token,
      notification: notification ?? this.notification,
      upiId: upiId ?? this.upiId,
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
      'token': token ?? 'na',
      'image': image ?? 'na',
      'regNumber': regNumber ?? '',
      'gst': gst ?? '',
      'notification': notification ?? true,
      'upiId': upiId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserModel(
      uid: map['uid'],
      name: map['name'],
      mobile: map['mobile'],
      email: map['email'],
      city: map['city'],
      state: map['state'],
      company: map['company'],
      token: map['token'],
      image: map['image'],
      gst: map['gst'],
      regNumber: map['regNumber'],
      joining: map['joining'],
      notification: map['notification'],
      upiId: map['upiId'],
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot map) {
    if (map == null) return null;
    Map<String, dynamic> data = map.data() as Map<String, dynamic>;
    return UserModel(
      uid: map.get('uid'),
      image: data.containsKey('image') ? map.get('image') ?? 'na' : 'na',
      name: map.get('name'),
      mobile: map.get('mobile'),
      email: map.get('email'),
      city: map.get('city'),
      state: map.get('state'),
      regNumber: data.containsKey('regNumber') ? map.get('regNumber') : '',
      gst: data.containsKey('gst') ? map.get('gst') : '',
      company: map.get('company'),
      joining: map.get('joining'),
      token: data.containsKey('token') ? map.get('token') : 'token',
      notification:
          data.containsKey('notification') ? map.get('notification') : true,
      upiId: data.containsKey('upiId') ? map.get('upiId') : "",
    );
  }
}

class MyUser extends ChangeNotifier {
  UserModel userModel;
  bool isUserLoading = true;
  final User currentUser = FirebaseAuth.instance.currentUser;
  UserModel get user => userModel;

  getUserFromDatabase() async {
    isUserLoading = true;
    CollectionReference reference = FirebaseFirestore.instance
        .collection(FirebaseHelper.fleetOwnerCollection);
    final d = reference.doc(currentUser.uid).snapshots();
    d.listen((event) {
      if (event.exists) {
        userModel = UserModel.fromSnapshot(event);
      }
      isUserLoading = false;
      notifyListeners();
    });
  }

  updateNotification(bool status) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection(FirebaseHelper.fleetOwnerCollection);
    await reference.doc(currentUser.uid).update({
      "notification": status,
    });
    notifyListeners();
  }
}
