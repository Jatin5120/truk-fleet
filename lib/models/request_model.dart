import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truk_fleet/helper/helper.dart';

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
  String trukModel;
  String pickupDate;
  int bookingId;
  int bookingDate;
  bool insured;
  String load;
  String mandate;
  String paymentStatus;
  String status;
  String destinationString;
  String sourceString;

  RequestModel({
    this.id,
    this.uid,
    this.mobile,
    this.source,
    this.destination,
    this.materials,
    this.truk,
    this.trukModel,
    this.pickupDate,
    this.bookingId,
    this.bookingDate,
    this.insured,
    this.load,
    this.mandate,
    this.paymentStatus,
    this.status,
    this.destinationString,
    this.sourceString,
  });

  RequestModel copyWith({
    String id,
    String uid,
    String mobile,
    LatLng source,
    LatLng destination,
    List<MaterialModel> materials,
    String truk,
    String trukModel,
    String pickupDate,
    int bookingId,
    int bookingDate,
    bool insured,
    String load,
    String mandate,
    String paymentStatus,
    String status,
    String destinationString,
    String sourceString,
  }) {
    return RequestModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      mobile: mobile ?? this.mobile,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      materials: materials ?? this.materials,
      truk: truk ?? this.truk,
      trukModel: trukModel ?? this.trukModel,
      pickupDate: pickupDate ?? this.pickupDate,
      bookingId: bookingId ?? this.bookingId,
      bookingDate: bookingDate ?? this.bookingDate,
      insured: insured ?? this.insured,
      load: load ?? this.load,
      mandate: mandate ?? this.mandate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      destinationString: destinationString ?? this.destinationString,
      sourceString: sourceString ?? this.sourceString,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'mobile': mobile,
      'source': "${source.latitude},${source.longitude}",
      'destination': "${destination.latitude},${destination.longitude}",
      'materials': materials?.map((x) => x.toMap())?.toList(),
      'truk': truk,
      'trukModel': trukModel,
      'pickupDate': pickupDate,
      'bookingId': bookingId,
      'bookingDate': bookingDate,
      'insured': insured,
      'load': load,
      'mandate': mandate,
      'paymentStatus': paymentStatus,
      'status': status,
      'destinationString': destinationString,
      'sourceString': sourceString,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'],
      uid: map['uid'],
      mobile: map['mobile'],
      source: Helper.stringToLatlng(map['source']),
      destination: Helper.stringToLatlng(map['destination']),
      materials: List<MaterialModel>.from(
          map['materials']?.map((x) => MaterialModel.fromMap(x))),
      truk: map['truk'],
      trukModel: map['trukModel'],
      pickupDate: map['pickupDate'],
      bookingId: map['bookingId'],
      bookingDate: map['bookingDate'],
      insured: map['insured'],
      load: map['load'],
      mandate: map['mandate'],
      paymentStatus: map['paymentStatus'],
      status: map['status'],
      destinationString: map['destinationString'],
      sourceString: map['sourceString'],
    );
  }

  factory RequestModel.fromSnapshot(QueryDocumentSnapshot map) {
    if (map == null) return null;

    return RequestModel(
      id: map.id,
      uid: map.get('uid'),
      mobile: map.get('mobile'),
      source: Helper.stringToLatlng(map.get('source')),
      destination: Helper.stringToLatlng(map.get('destination')),
      materials: List<MaterialModel>.from(
          map.get('materials')?.map((x) => MaterialModel.fromMap(x))),
      truk: map.get('truk'),
      //TODO: uncomment from snapshot
      // trukModel: map.get('trukModel'),
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
              : PaymentType.cod,
      destinationString: map.get('destinationString'),
      sourceString: map.get('sourceString'),
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestModel.fromJson(String source) =>
      RequestModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'RequestModel(id: $id, uid: $uid, mobile: $mobile, source: $source, destination: $destination, materials: $materials, truk: $truk, trukModel: $trukModel, pickupDate: $pickupDate, bookingId: $bookingId, bookingDate: $bookingDate, insured: $insured, load: $load, mandate: $mandate, paymentStatus: $paymentStatus, status: $status, destinationString: $destinationString, sourceString: $sourceString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RequestModel &&
        other.id == id &&
        other.uid == uid &&
        other.mobile == mobile &&
        other.source == source &&
        other.destination == destination &&
        listEquals(other.materials, materials) &&
        other.truk == truk &&
        other.trukModel == trukModel &&
        other.pickupDate == pickupDate &&
        other.bookingId == bookingId &&
        other.bookingDate == bookingDate &&
        other.insured == insured &&
        other.load == load &&
        other.mandate == mandate &&
        other.paymentStatus == paymentStatus &&
        other.status == status &&
        other.destinationString == destinationString &&
        other.sourceString == sourceString;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        mobile.hashCode ^
        source.hashCode ^
        destination.hashCode ^
        materials.hashCode ^
        truk.hashCode ^
        trukModel.hashCode ^
        pickupDate.hashCode ^
        bookingId.hashCode ^
        bookingDate.hashCode ^
        insured.hashCode ^
        load.hashCode ^
        mandate.hashCode ^
        paymentStatus.hashCode ^
        status.hashCode ^
        destinationString.hashCode ^
        sourceString.hashCode;
  }
}
