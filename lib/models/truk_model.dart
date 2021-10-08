import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/models/material_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';

class TrukModel {
  String trukName;
  String trukType;
  String trukNumber;
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
  TrukModel({
    this.trukName,
    this.trukType,
    this.trukNumber,
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

  TrukModel copyWith({
    String trukName,
    String trukType,
    String trukNumber,
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
    bool available
  }) {
    return TrukModel(
        trukName: trukName ?? this.trukName,
        trukType: trukType ?? this.trukType,
        trukNumber: trukNumber ?? this.trukNumber,
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
        available: available?? true
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trukName': trukName,
      'trukType': trukType,
      'trukNumber': trukNumber,
      'driver': driver ?? 'na',
      'ownerName': ownerName,
      'mobileNumber': mobileNumber,
      'panTin': panTin,
      'grossWeight': grossWeight,
      'length': length,
      'breadth': breadth,
      'height': height,
      'permitType': permitType,
      'ownerId': ownerId,
      'available': available
    };
  }

  factory TrukModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return TrukModel(
      trukName: map['trukName'],
      trukType: map['trukType'],
      trukNumber: map['trukNumber'],
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
      available: map['available']
    );
  }
  factory TrukModel.fromSnapshot(DocumentSnapshot map) {
    if (map == null) return null;

    return TrukModel(
      trukName: map.get('trukName'),
      trukType: map.get('trukType'),
      trukNumber: map.get('trukNumber'),
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
      available: map.get('available')
    );
  }
}

class MyTruksProvider with ChangeNotifier {
  List<TrukModel> trukList = [];
  bool isTrukLoading = true;
  List<TrukModel> get truks => trukList;
  final User user = FirebaseAuth.instance.currentUser;

  getTrukList() async {
    isTrukLoading = true;
    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    final d = reference.where('ownerId', isEqualTo: user.uid).snapshots();
    d.listen((event) {
      for (DocumentSnapshot doc in event.docs) {
        trukList.add(TrukModel.fromSnapshot(doc));
      }
      isTrukLoading = false;
      notifyListeners();
    });
  }
}
class MyATruksProvider{
  List<TrukModel> trukList = [];
  List<TrukModel> trukAList = [];
  List<ShipmentModel> Smodel = [];
  List<ShipmentModel> FSmodel = [];
  List<MaterialModel> Mmodel = [];
  bool isTrukLoading = true;
  double x=0.0;
  final User user = FirebaseAuth.instance.currentUser;

  getATrukList(weight,spin,dpin,type) async {
    isTrukLoading = true;
    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    CollectionReference Sreference = FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    final d = reference.where('ownerId', isEqualTo: user.uid).snapshots();
    final s = Sreference.where('agent', isEqualTo: user.uid).snapshots();
    d.listen((event) {
      for (DocumentSnapshot doc in event.docs) {
        int j=0;
        TrukModel t = TrukModel.fromSnapshot(doc);
        if(t.available && int.parse(t.grossWeight)>=weight){
          trukAList.add(t);
        }
        if(!t.available){
          Sreference.where('truk',isEqualTo: t.trukNumber).get().then((value) {
            for(var f in value.docs){
              if(f.get('status')==RequestStatus.started||f.get('status')==RequestStatus.pending){
                break;
              }else{
                doc.reference.update({
                  'available':true
                });
                trukAList.add(t);
              }
            }
          });
        }
      }
    });
    s.listen((events) async {
      for (DocumentSnapshot docs in events.docs) {
        Smodel.add(ShipmentModel.fromSnapshot(docs));
      }
      for (ShipmentModel ship in Smodel) {
        String a= await Helper().setLocationText(ship.source);
        String b= await Helper().setLocationText(ship.destination);
        x=0.0;
        for(MaterialModel m in ship.materials){
          x+=m.quantity;
        }
        print(a);
        print(b);
        print("$weight");
        print(type.toString().toLowerCase());
        if(a.contains(spin)&&b.contains(dpin)&&type.toString().toLowerCase()=="partialtruk"){

          FSmodel.add(ship);
        }
      }
      for(ShipmentModel sh in FSmodel){
        int i=0;
        await FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection).doc(sh.truk).get().then((value){
          TrukModel tm = TrukModel.fromSnapshot(value);
          if((double.parse(tm.grossWeight)-x)>=weight){
            for(TrukModel t in trukAList)
              {
                if(t.trukNumber==tm.trukNumber){
                  i=1;
                  break;
                }
              }
            if(i==0){
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
