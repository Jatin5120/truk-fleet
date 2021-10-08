import 'package:cloud_firestore/cloud_firestore.dart';
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
  QuoteModel(
      {this.uid,
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
      this.price,
      this.agent,
      this.id,
      this.paymentStatus,
      this.status = RequestStatus.pending,
      this.trukName = 'Eicher',
      this.advance = 0.0});

  QuoteModel copyWith({
    String uid,
    String mobile,
    String paymentStatus,
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
    String trukName,
    String price,
    String agent,
    String id,
    double advance,
  }) {
    return QuoteModel(
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
      status: status ?? this.source,
      trukName: trukName ?? this.trukName,
      price: price ?? this.price,
      agent: agent ?? this.agent,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      advance: advance ?? this.advance,
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
      'price': price,
      'status': status ?? RequestStatus.pending,
      'trukName': trukName,
      'agent': agent ?? 'na',
      'paymentStatus': paymentStatus ?? RequestStatus.pending,
      'advance': advance ?? 0.0,
    };
  }

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return QuoteModel(
      uid: map['uid'],
      mobile: map['mobile'],
      source: Helper.stringToLatlng(map['source']),
      destination: Helper.stringToLatlng(map['destination']),
      materials: List<MaterialModel>.from(
          map['materials']?.map((x) => MaterialModel.fromMap(x))),
      truk: map['truk'],
      pickupDate: map['pickupDate'],
      bookingId: map['bookingId'],
      bookingDate: map['bookingDate'],
      insured: map['insured'],
      load: map['load'],
      mandate: map['mandate'],
      price: map['price'],
      trukName: map['trukName'],
      status: map['status'] ?? RequestStatus.pending,
      agent: map['agent'] ?? 'na',
      paymentStatus: map['paymentStatus'] ?? RequestStatus.pending,
      advance: map['advance'] ?? 0.0,
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
}
