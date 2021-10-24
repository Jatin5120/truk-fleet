import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';

import '../models/material_model.dart';

class QuoteModel {
  String uid;
  String id;
  String mobile;
  LatLng source;
  LatLng destination;
  String price;
  List<MaterialModel> materials;
  String truk;
  String trukModel;
  String pickupDate;
  int bookingId;
  String status;
  int bookingDate;
  bool insured;
  String load;
  String mandate;
  String trukName;
  String agent;
  String paymentStatus;
  double advance;

  QuoteModel({
    this.uid,
    this.id,
    this.mobile,
    this.source,
    this.destination,
    this.price,
    this.materials,
    this.truk,
    this.trukModel,
    this.pickupDate,
    this.bookingId,
    this.status,
    this.bookingDate,
    this.insured,
    this.load,
    this.mandate,
    this.trukName,
    this.agent,
    this.paymentStatus,
    this.advance,
  });

  QuoteModel copyWith({
    String uid,
    String id,
    String mobile,
    LatLng source,
    LatLng destination,
    String price,
    List<MaterialModel> materials,
    String truk,
    String trukModel,
    String pickupDate,
    int bookingId,
    String status,
    int bookingDate,
    bool insured,
    String load,
    String mandate,
    String trukName,
    String agent,
    String paymentStatus,
    double advance,
  }) {
    return QuoteModel(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      price: price ?? this.price,
      materials: materials ?? this.materials,
      truk: truk ?? this.truk,
      trukModel: trukModel ?? this.trukModel,
      pickupDate: pickupDate ?? this.pickupDate,
      bookingId: bookingId ?? this.bookingId,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      insured: insured ?? this.insured,
      load: load ?? this.load,
      mandate: mandate ?? this.mandate,
      trukName: trukName ?? this.trukName,
      agent: agent ?? this.agent,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      advance: advance ?? this.advance,
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
      'materials': materials?.map((x) => x.toMap())?.toList(),
      'truk': truk,
      'trukModel': trukModel,
      'pickupDate': pickupDate,
      'bookingId': bookingId,
      'status': status,
      'bookingDate': bookingDate,
      'insured': insured,
      'load': load,
      'mandate': mandate,
      'trukName': trukName,
      'agent': agent,
      'paymentStatus': paymentStatus,
      'advance': advance,
    };
  }

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      uid: map['uid'],
      id: map['id'],
      mobile: map['mobile'],
      source: Helper.stringToLatlng(map['source']),
      destination: Helper.stringToLatlng(map['destination']),
      price: map['price'],
      materials: List<MaterialModel>.from(
          map['materials']?.map((x) => MaterialModel.fromMap(x))),
      truk: map['truk'],
      trukModel: map['trukModel'],
      pickupDate: map['pickupDate'],
      bookingId: map['bookingId'],
      status: map['status'],
      bookingDate: map['bookingDate'],
      insured: map['insured'],
      load: map['load'],
      mandate: map['mandate'],
      trukName: map['trukName'],
      agent: map['agent'],
      paymentStatus: map['paymentStatus'],
      advance: map['advance'],
    );
  }

  factory QuoteModel.fromSnapshot(QueryDocumentSnapshot map) {
    if (map == null) return null;

    return QuoteModel(
      id: map.id,
      uid: map.get('uid'),
      mobile: map.get('mobile'),
      source: Helper.stringToLatlng(map.get('source')),
      destination: Helper.stringToLatlng(map.get('destination')),
      materials: List<MaterialModel>.from(
          map.get('materials')?.map((x) => MaterialModel.fromMap(x))),
      truk: map.get('truk'),
      pickupDate: map.get('pickupDate'),
      bookingId: map.get('bookingId'),
      bookingDate: map.get('bookingDate'),
      insured: map.get('insured'),
      load: map.get('load'),
      mandate: map.get('mandate'),
      price: map.get('price'),
      trukName: map.get('trukName'),
      trukModel: map.get('trukModel'),
      status: map.get('status'),
      agent: map.get('agent') ?? 'na',
      paymentStatus:
          (map.data() as Map<String, dynamic>).containsKey('paymentStatus')
              ? map.get('paymentStatus')
              : RequestStatus.pending,
      advance: (map.data() as Map<String, dynamic>).containsKey('advance')
          ? double.parse(map.get('advance').toString())
          : 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuoteModel.fromJson(String source) =>
      QuoteModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'QuoteModel(uid: $uid, id: $id, mobile: $mobile, source: $source, destination: $destination, price: $price, materials: $materials, truk: $truk, trukModel: $trukModel, pickupDate: $pickupDate, bookingId: $bookingId, status: $status, bookingDate: $bookingDate, insured: $insured, load: $load, mandate: $mandate, trukName: $trukName, agent: $agent, paymentStatus: $paymentStatus, advance: $advance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuoteModel &&
        other.uid == uid &&
        other.id == id &&
        other.mobile == mobile &&
        other.source == source &&
        other.destination == destination &&
        other.price == price &&
        listEquals(other.materials, materials) &&
        other.truk == truk &&
        other.trukModel == trukModel &&
        other.pickupDate == pickupDate &&
        other.bookingId == bookingId &&
        other.status == status &&
        other.bookingDate == bookingDate &&
        other.insured == insured &&
        other.load == load &&
        other.mandate == mandate &&
        other.trukName == trukName &&
        other.agent == agent &&
        other.paymentStatus == paymentStatus &&
        other.advance == advance;
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
        trukModel.hashCode ^
        pickupDate.hashCode ^
        bookingId.hashCode ^
        status.hashCode ^
        bookingDate.hashCode ^
        insured.hashCode ^
        load.hashCode ^
        mandate.hashCode ^
        trukName.hashCode ^
        agent.hashCode ^
        paymentStatus.hashCode ^
        advance.hashCode;
  }
}
