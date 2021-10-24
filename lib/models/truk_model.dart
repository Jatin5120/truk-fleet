import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/models/material_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';

class TrukModal {
  String trukName;
  String trukType;
  String trukNumber;
  String trukModel;
  String driver;
  String ownerName;
  String mobileNumber;
  String panTin;
  String grossWeight;
  String length;
  String breadth;
  String height;
  String permitType;
  String ownerId;
  bool available;

  TrukModal({
    this.trukName,
    this.trukType,
    this.trukNumber,
    this.trukModel,
    this.driver,
    this.ownerName,
    this.mobileNumber,
    this.panTin,
    this.grossWeight,
    this.length,
    this.breadth,
    this.height,
    this.permitType,
    this.ownerId,
    this.available,
  });

  TrukModal copyWith({
    String trukName,
    String trukType,
    String trukNumber,
    String trukModel,
    String driver,
    String ownerName,
    String mobileNumber,
    String panTin,
    String grossWeight,
    String length,
    String breadth,
    String height,
    String permitType,
    String ownerId,
    bool available,
  }) {
    return TrukModal(
      trukName: trukName ?? this.trukName,
      trukType: trukType ?? this.trukType,
      trukNumber: trukNumber ?? this.trukNumber,
      trukModel: trukModel ?? this.trukModel,
      driver: driver ?? this.driver,
      ownerName: ownerName ?? this.ownerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      panTin: panTin ?? this.panTin,
      grossWeight: grossWeight ?? this.grossWeight,
      length: length ?? this.length,
      breadth: breadth ?? this.breadth,
      height: height ?? this.height,
      permitType: permitType ?? this.permitType,
      ownerId: ownerId ?? this.ownerId,
      available: available ?? this.available,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trukName': trukName,
      'trukType': trukType,
      'trukNumber': trukNumber,
      'trukModel': trukModel,
      'driver': driver,
      'ownerName': ownerName,
      'mobileNumber': mobileNumber,
      'panTin': panTin,
      'grossWeight': grossWeight,
      'length': length,
      'breadth': breadth,
      'height': height,
      'permitType': permitType,
      'ownerId': ownerId,
      'available': available,
    };
  }

  factory TrukModal.fromMap(Map<String, dynamic> map) {
    return TrukModal(
      trukName: map['trukName'],
      trukType: map['trukType'],
      trukNumber: map['trukNumber'],
      trukModel: map['trukModel'],
      driver: map['driver'],
      ownerName: map['ownerName'],
      mobileNumber: map['mobileNumber'],
      panTin: map['panTin'],
      grossWeight: map['grossWeight'],
      length: map['length'],
      breadth: map['breadth'],
      height: map['height'],
      permitType: map['permitType'],
      ownerId: map['ownerId'],
      available: map['available'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TrukModal.fromJson(String source) =>
      TrukModal.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TrukModal(trukName: $trukName, trukType: $trukType, trukNumber: $trukNumber, trukModel: $trukModel, driver: $driver, ownerName: $ownerName, mobileNumber: $mobileNumber, panTin: $panTin, grossWeight: $grossWeight, length: $length, breadth: $breadth, height: $height, permitType: $permitType, ownerId: $ownerId, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrukModal &&
        other.trukName == trukName &&
        other.trukType == trukType &&
        other.trukNumber == trukNumber &&
        other.trukModel == trukModel &&
        other.driver == driver &&
        other.ownerName == ownerName &&
        other.mobileNumber == mobileNumber &&
        other.panTin == panTin &&
        other.grossWeight == grossWeight &&
        other.length == length &&
        other.breadth == breadth &&
        other.height == height &&
        other.permitType == permitType &&
        other.ownerId == ownerId &&
        other.available == available;
  }

  @override
  int get hashCode {
    return trukName.hashCode ^
        trukType.hashCode ^
        trukNumber.hashCode ^
        trukModel.hashCode ^
        driver.hashCode ^
        ownerName.hashCode ^
        mobileNumber.hashCode ^
        panTin.hashCode ^
        grossWeight.hashCode ^
        length.hashCode ^
        breadth.hashCode ^
        height.hashCode ^
        permitType.hashCode ^
        ownerId.hashCode ^
        available.hashCode;
  }

  factory TrukModal.fromSnapshot(DocumentSnapshot map) {
    if (map == null) return null;

    return TrukModal(
      trukName: map.get('trukName'),
      trukType: map.get('trukType'),
      trukNumber: map.get('trukNumber'),
      //TODO: Uncomment fromsnapshot
      // trukModel: map.get('trukModel'),
      driver: map.get('driver'),
      ownerName: map.get('ownerName'),
      mobileNumber: map.get('mobileNumber'),
      panTin: map.get('panTin'),
      grossWeight: map.get('grossWeight'),
      length: map.get('length'),
      breadth: map.get('breadth'),
      height: map.get('height'),
      permitType: map.get('permitType'),
      ownerId: map.get('ownerId'),
      available: map.get('available'),
    );
  }
}

class MyTruksProvider with ChangeNotifier {
  List<TrukModal> trukList = [];
  bool isTrukLoading = true;
  List<TrukModal> get truks => trukList;
  final User user = FirebaseAuth.instance.currentUser;

  getTrukList() async {
    isTrukLoading = true;
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    final d = reference.where('ownerId', isEqualTo: user.uid).snapshots();
    d.listen((event) {
      for (DocumentSnapshot doc in event.docs) {
        trukList.add(TrukModal.fromSnapshot(doc));
      }
      isTrukLoading = false;
      notifyListeners();
    });
  }
}

class MyATruksProvider {
  List<TrukModal> trukList = [];
  List<TrukModal> trukAList = [];
  List<ShipmentModel> sModel = [];
  List<ShipmentModel> fsModel = [];
  List<MaterialModel> mModel = [];
  bool isTrukLoading = true;
  double x = 0.0;
  final User user = FirebaseAuth.instance.currentUser;

  getATrukList(weight, spin, dpin, type) async {
    isTrukLoading = true;
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    CollectionReference sReference =
        FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    final d = reference.where('ownerId', isEqualTo: user.uid).snapshots();
    final s = sReference.where('agent', isEqualTo: user.uid).snapshots();
    d.listen((event) {
      for (DocumentSnapshot doc in event.docs) {
        TrukModal t = TrukModal.fromSnapshot(doc);
        if (t.available && int.parse(t.grossWeight) >= weight) {
          trukAList.add(t);
        }
        if (!t.available) {
          sReference.where('truk', isEqualTo: t.trukNumber).get().then((value) {
            for (var f in value.docs) {
              if (f.get('status') == RequestStatus.started ||
                  f.get('status') == RequestStatus.pending) {
                break;
              } else {
                doc.reference.update({'available': true});
                trukAList.add(t);
              }
            }
          });
        }
      }
    });
    s.listen((events) async {
      for (DocumentSnapshot docs in events.docs) {
        sModel.add(ShipmentModel.fromSnapshot(docs));
      }
      for (ShipmentModel ship in sModel) {
        String a = await Helper().setLocationText(ship.source);
        String b = await Helper().setLocationText(ship.destination);
        x = 0.0;
        for (MaterialModel m in ship.materials) {
          x += m.quantity;
        }
        print(a);
        print(b);
        print("$weight");
        print(type.toString().toLowerCase());
        if (a.contains(spin) &&
            b.contains(dpin) &&
            type.toString().toLowerCase() == "partialtruk") {
          fsModel.add(ship);
        }
      }
      for (ShipmentModel sh in fsModel) {
        int i = 0;
        await FirebaseFirestore.instance
            .collection(FirebaseHelper.trukCollection)
            .doc(sh.truk)
            .get()
            .then((value) {
          TrukModal tm = TrukModal.fromSnapshot(value);
          if ((double.parse(tm.grossWeight) - x) >= weight) {
            for (TrukModal t in trukAList) {
              if (t.trukNumber == tm.trukNumber) {
                i = 1;
                break;
              }
            }
            if (i == 0) {
              trukAList.add(tm);
            }
          }
        });
      }
      isTrukLoading = false;
    });
    return trukAList;
  }
}
