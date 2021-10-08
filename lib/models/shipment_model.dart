import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truk_fleet/helper/helper.dart';

import 'package:truk_fleet/models/material_model.dart';

class ShipmentModel {
  String uid;
  String id;
  String mobile;
  LatLng source;
  LatLng destination;
  String price;
  List<MaterialModel> materials;
  String truk;
  String pickupDate;
  int bookingId;
  String status;
  int bookingDate;
  bool insured;
  String load;
  String mandate;
  String trukName;
  String agent;
  String driver;
  String paymentStatus;
  String eWayBillUrl;
  String amountPaid;
  ShipmentModel(
      {this.uid,
      this.id,
      this.mobile,
      this.source,
      this.destination,
      this.price,
      this.materials,
      this.truk,
      this.pickupDate,
      this.bookingId,
      this.status,
      this.bookingDate,
      this.insured,
      this.load,
      this.mandate,
      this.trukName,
      this.agent,
      this.driver,
      this.paymentStatus,
      this.eWayBillUrl,
      this.amountPaid});

  ShipmentModel copyWith(
      {String uid,
      String id,
      String mobile,
      LatLng source,
      LatLng destination,
      String price,
      List<MaterialModel> materials,
      String truk,
      String pickupDate,
      int bookingId,
      String status,
      int bookingDate,
      bool insured,
      String load,
      String mandate,
      String trukName,
      String agent,
      String driver,
      String paymentStatus,
      String eWayBillUrl,
      String amountPaid}) {
    return ShipmentModel(
        uid: uid ?? this.uid,
        id: id ?? this.id,
        mobile: mobile ?? this.mobile,
        source: source ?? this.source,
        destination: destination ?? this.destination,
        price: price ?? this.price,
        materials: materials ?? this.materials,
        truk: truk ?? this.truk,
        pickupDate: pickupDate ?? this.pickupDate,
        bookingId: bookingId ?? this.bookingId,
        status: status ?? this.status,
        bookingDate: bookingDate ?? this.bookingDate,
        insured: insured ?? this.insured,
        load: load ?? this.load,
        mandate: mandate ?? this.mandate,
        trukName: trukName ?? this.trukName,
        agent: agent ?? this.agent,
        driver: driver ?? this.driver,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        eWayBillUrl: eWayBillUrl ?? this.eWayBillUrl,
        amountPaid: amountPaid ?? this.amountPaid);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'mobile': mobile,
      'source': "${source.latitude},${source.longitude}",
      'destination': "${destination.latitude},${destination.longitude}",
      'price': price,
      'materials': materials?.map((x) => x?.toMap())?.toList(),
      'truk': truk,
      'pickupDate': pickupDate,
      'bookingId': bookingId,
      'status': status,
      'bookingDate': bookingDate,
      'insured': insured,
      'load': load,
      'mandate': mandate,
      'trukName': trukName,
      'agent': agent,
      'driver': driver,
      'paymentStatus': paymentStatus,
      'ewaybill': eWayBillUrl,
      'amountPaid': amountPaid
    };
  }

  factory ShipmentModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ShipmentModel(
        uid: map['uid'],
        id: map['id'],
        mobile: map['mobile'],
        source: Helper.stringToLatlng(map['source']),
        destination: Helper.stringToLatlng(map['destination']),
        price: map['price'],
        materials: List<MaterialModel>.from(
            map['materials']?.map((x) => MaterialModel.fromMap(x))),
        truk: map['truk'],
        pickupDate: map['pickupDate'],
        bookingId: map['bookingId'],
        status: map['status'],
        bookingDate: map['bookingDate'],
        insured: map['insured'],
        load: map['load'],
        mandate: map['mandate'],
        trukName: map['trukName'],
        agent: map['agent'],
        driver: map['driver'],
        paymentStatus: map['paymentStatus'],
        eWayBillUrl: map.containsKey('ewaybill') ? map['ewaybill'] : "NA",
        amountPaid: map['amountPaid']);
  }

  factory ShipmentModel.fromSnapshot(QueryDocumentSnapshot map) {
    if (map == null) return null;

    return ShipmentModel(
        uid: map.get('uid'),
        id: map.id,
        mobile: map.get('mobile'),
        source: Helper.stringToLatlng(map.get('source')),
        destination: Helper.stringToLatlng(map.get('destination')),
        price: map.get('price'),
        materials: List<MaterialModel>.from(
            map.get('materials')?.map((x) => MaterialModel.fromMap(x))),
        truk: map.get('truk'),
        pickupDate: map.get('pickupDate'),
        bookingId: map.get('bookingId'),
        status: map.get('status'),
        bookingDate: map.get('bookingDate'),
        insured: map.get('insured'),
        load: map.get('load'),
        mandate: map.get('mandate'),
        trukName: map.get('trukName'),
        agent: map.get('agent'),
        driver: map.get('driver'),
        paymentStatus: map.get('paymentStatus'),
        eWayBillUrl:
            (map.data() as Map<String, dynamic>).containsKey('ewaybill')
                ? map.get('ewaybill')
                : "NA",
        amountPaid: map.get('amountPaid'));
  }
}
