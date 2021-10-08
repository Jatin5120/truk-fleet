import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truk_fleet/helper/payment_type.dart';
import 'package:truk_fleet/helper/request_status.dart';

import '../models/material_model.dart';

class RequestModel {
  String id;
  String uid;
  String mobile;
  LatLng source;
  LatLng destination;
  List<MaterialModel> materials;
  String truk;
  String pickupDate;
  int bookingId;
  int bookingDate;
  bool insured;
  String load;
  String mandate;
  String paymentStatus;
  String status;
  RequestModel({
    this.uid,
    this.id,
    this.mobile,
    this.source,
    this.destination,
    this.materials,
    this.truk,
    this.pickupDate,
    this.bookingId,
    this.bookingDate,
    this.insured,
    this.load,
    this.mandate,
    this.status,
    this.paymentStatus,
  });

  RequestModel copyWith({
    String uid,
    String mobile,
    LatLng source,
    LatLng destination,
    List<MaterialModel> materials,
    String truk,
    String pickupDate,
    int bookingId,
    int bookingDate,
    bool insured,
    String load,
    String mandate,
    String status,
    String id,
  }) {
    return RequestModel(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      materials: materials ?? this.materials,
      truk: truk ?? this.truk,
      pickupDate: pickupDate ?? this.pickupDate,
      bookingId: bookingId ?? this.bookingId,
      bookingDate: bookingDate ?? this.bookingDate,
      insured: insured ?? this.insured,
      load: load ?? this.load,
      mandate: mandate ?? this.mandate,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'mobile': mobile,
      'source': "${source.latitude},${source.longitude}",
      'destination': "${destination.latitude},${destination.longitude}",
      'materials': materials?.map((x) => x?.toMap())?.toList(),
      'truk': truk,
      'pickupDate': pickupDate,
      'bookingId': bookingId,
      'bookingDate': bookingDate,
      'insured': insured,
      'load': load,
      'mandate': mandate,
      'status': status ?? RequestStatus.pending,
      'paymentStatus': paymentStatus ?? PaymentType.cod,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return RequestModel(
        uid: map['uid'],
        mobile: map['mobile'],
        source: stringToLatlng(map['source']),
        destination: stringToLatlng(map['destination']),
        materials: List<MaterialModel>.from(
            map['materials']?.map((x) => MaterialModel.fromMap(x))),
        truk: map['truk'],
        pickupDate: map['pickupDate'],
        bookingId: map['bookingId'],
        bookingDate: map['bookingDate'],
        insured: map['insured'],
        load: map['load'],
        mandate: map['mandate'],
        status: map['status'],
        paymentStatus: map['paymentStatus'] ?? PaymentType.cod);
  }

  factory RequestModel.fromSnapshot(QueryDocumentSnapshot map) {
    if (map == null) return null;

    return RequestModel(
        id: map.id,
        uid: map.get('uid'),
        mobile: map.get('mobile'),
        source: stringToLatlng(map.get('source')),
        destination: stringToLatlng(map.get('destination')),
        materials: List<MaterialModel>.from(
            map.get('materials')?.map((x) => MaterialModel.fromMap(x))),
        truk: map.get('truk'),
        pickupDate: map.get('pickupDate'),
        bookingId: map.get('bookingId'),
        bookingDate: map.get('bookingDate'),
        insured: map.get('insured'),
        load: map.get('load'),
        mandate: map.get('mandate'),
        status: (map.data() as Map<String, dynamic>).containsKey('status')
            ? map.get('status')
            : RequestStatus.pending,
        paymentStatus:
            (map.data() as Map<String, dynamic>).containsKey('paymentStatus')
                ? map.get('paymentStatus')
                : PaymentType.cod);
  }

  static LatLng stringToLatlng(String coordindates) {
    List<String> splitted = coordindates.split(',');
    return LatLng(double.parse(splitted[0]), double.parse(splitted[1]));
  }
}
