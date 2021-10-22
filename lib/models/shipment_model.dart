import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  String commission;
  String amountPaid;
  String ewaybill;
  String driverId;

  ShipmentModel({
    @required this.uid,
    this.id,
    @required this.mobile,
    @required this.source,
    @required this.destination,
    @required this.price,
    @required this.materials,
    @required this.truk,
    @required this.pickupDate,
    @required this.bookingId,
    @required this.status,
    @required this.bookingDate,
    @required this.insured,
    @required this.load,
    @required this.mandate,
    @required this.trukName,
    @required this.agent,
    @required this.driver,
    @required this.paymentStatus,
    @required this.commission,
    this.amountPaid,
    @required this.ewaybill,
    @required this.driverId,
  });

  ShipmentModel copyWith({
    String uid,
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
    double commission,
    String amountPaid,
    String ewaybill,
    String driverId,
  }) {
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
      commission: commission ?? this.commission,
      amountPaid: amountPaid ?? this.amountPaid,
      ewaybill: ewaybill ?? this.ewaybill,
      driverId: driverId ?? this.driverId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'id': id,
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
      'commission': commission,
      'amountPaid': amountPaid,
      'ewaybill': ewaybill,
      'driverId': driverId,
    };
  }

  factory ShipmentModel.fromMap(Map<String, dynamic> map) {
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
      commission: map['commission'],
      amountPaid: map['amountPaid'],
      ewaybill: map['ewaybill'],
      driverId: map['driverId'],
    );
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
        commission: map.get('commission'),
        ewaybill: (map.data() as Map<String, dynamic>).containsKey('ewaybill')
            ? map.get('ewaybill')
            : "NA",
        amountPaid: map.get('amountPaid'),
      driverId: map.get('driverId'),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShipmentModel.fromJson(String source) =>
      ShipmentModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ShipmentModel(uid: $uid, id: $id, mobile: $mobile, source: $source, destination: $destination, price: $price, materials: $materials, truk: $truk, pickupDate: $pickupDate, bookingId: $bookingId, status: $status, bookingDate: $bookingDate, insured: $insured, load: $load, mandate: $mandate, trukName: $trukName, agent: $agent, driver: $driver, paymentStatus: $paymentStatus, commission: $commission, amountPaid: $amountPaid, ewaybill: $ewaybill, driverId: $driverId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShipmentModel &&
        other.uid == uid &&
        other.id == id &&
        other.mobile == mobile &&
        other.source == source &&
        other.destination == destination &&
        other.price == price &&
        listEquals(other.materials, materials) &&
        other.truk == truk &&
        other.pickupDate == pickupDate &&
        other.bookingId == bookingId &&
        other.status == status &&
        other.bookingDate == bookingDate &&
        other.insured == insured &&
        other.load == load &&
        other.mandate == mandate &&
        other.trukName == trukName &&
        other.agent == agent &&
        other.driver == driver &&
        other.paymentStatus == paymentStatus &&
        other.commission == commission &&
        other.amountPaid == amountPaid &&
        other.ewaybill == ewaybill &&
        other.driverId == driverId;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        id.hashCode ^
        mobile.hashCode ^
        source.hashCode ^
        destination.hashCode ^
        price.hashCode ^
        materials.hashCode ^
        truk.hashCode ^
        pickupDate.hashCode ^
        bookingId.hashCode ^
        status.hashCode ^
        bookingDate.hashCode ^
        insured.hashCode ^
        load.hashCode ^
        mandate.hashCode ^
        trukName.hashCode ^
        agent.hashCode ^
        driver.hashCode ^
        paymentStatus.hashCode ^
        commission.hashCode ^
        amountPaid.hashCode ^
        ewaybill.hashCode ^
    driverId.hashCode;
  }
}
