import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/models/truk_model.dart';

import 'material_model.dart';

class RideStatus {
  static const String accept = 'ACCEPTED';
  static const String pending = 'PENDING';
  static const String reject = 'REJECTED';
}

class TripStatus {
  static const String started = 'STARTED';
  static const String complete = 'COMPLETED';
  static const String pending = 'PENDING';
}

class RideModel {
  String uid;
  String mobile;
  LatLng source;
  LatLng destination;
  String price;
  List<MaterialModel> materials;
  String truk;
  String pickupDate;
  int bookingId;
  String rideStatus;
  int bookingDate;
  bool insured;
  String load;
  String mandate;
  String trukName;
  String paymentType;
  String tripStatus;
  String driver;
  TrukModal trukModal;
  RideModel(
      {this.uid,
      this.mobile,
      this.source,
      this.destination,
      this.price,
      this.materials,
      this.truk,
      this.pickupDate,
      this.bookingId,
      this.rideStatus,
      this.bookingDate,
      this.insured,
      this.load,
      this.mandate,
      this.trukName,
      this.paymentType,
      this.tripStatus,
      this.driver,
      this.trukModal});

  RideModel copyWith(
      {String uid,
      String mobile,
      LatLng source,
      LatLng destination,
      String price,
      List<MaterialModel> materials,
      String truk,
      String pickupDate,
      int bookingId,
      String rideStatus,
      int bookingDate,
      bool insured,
      String load,
      String mandate,
      String trukName,
      String paymentType,
      String tripStatus,
      String driver,
      TrukModal trukModal}) {
    return RideModel(
        uid: uid ?? this.uid,
        mobile: mobile ?? this.mobile,
        source: source ?? this.source,
        destination: destination ?? this.destination,
        price: price ?? this.price,
        materials: materials ?? this.materials,
        truk: truk ?? this.truk,
        pickupDate: pickupDate ?? this.pickupDate,
        bookingId: bookingId ?? this.bookingId,
        rideStatus: rideStatus ?? this.rideStatus,
        bookingDate: bookingDate ?? this.bookingDate,
        insured: insured ?? this.insured,
        load: load ?? this.load,
        mandate: mandate ?? this.mandate,
        trukName: trukName ?? this.trukName,
        paymentType: paymentType ?? this.paymentType,
        tripStatus: tripStatus ?? this.tripStatus,
        driver: driver ?? this.driver,
        trukModal: trukModal ?? this.trukModal);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'mobile': mobile,
      'source': Helper.stringToLatlng(source.toString()),
      'destination': Helper.stringToLatlng(destination.toString()),
      'price': price,
      'materials': materials?.map((x) => x?.toMap())?.toList(),
      'truk': truk,
      'pickupDate': pickupDate,
      'bookingId': bookingId,
      'rideStatus': rideStatus,
      'bookingDate': bookingDate,
      'insured': insured,
      'load': load,
      'mandate': mandate,
      'trukName': trukName,
      'paymentType': paymentType,
      'tripStatus': tripStatus,
      'driver': driver,
      'trukDetails': trukModal.toMap()
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return RideModel(
        uid: map['uid'],
        mobile: map['mobile'],
        source: Helper.stringToLatlng(map['source']),
        destination: Helper.stringToLatlng(map['destination']),
        price: map['price'],
        materials: List<MaterialModel>.from(
            map['materials']?.map((x) => MaterialModel.fromMap(x))),
        truk: map['truk'],
        pickupDate: map['pickupDate'],
        bookingId: map['bookingId'],
        rideStatus: map['rideStatus'],
        bookingDate: map['bookingDate'],
        insured: map['insured'],
        load: map['load'],
        mandate: map['mandate'],
        trukName: map['trukName'],
        paymentType: map['paymentType'],
        tripStatus: map['tripStatus'],
        driver: map['driver'],
        trukModal: TrukModal.fromMap(map['trukDetails']));
  }

  factory RideModel.fromSnapshot(QueryDocumentSnapshot map) {
    if (map == null) return null;

    return RideModel(
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
        rideStatus: map.get('rideStatus'),
        paymentType: map.get('paymentType'),
        tripStatus: map.get('tripStatus'),
        driver: map.get('driver'),
        trukModal: TrukModal.fromMap(map.get('trukDetails')));
  }
}
