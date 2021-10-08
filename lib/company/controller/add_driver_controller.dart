import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/models/driver_register_model.dart';

class AddDriverController {
  String collectionRef = FirebaseHelper.driverRegistered;

  Future<bool> addDriver(DriverRegisterModel model) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(collectionRef);
    final doc = await reference.where('mobile', isEqualTo: model.mobile).snapshots().first;
    if (doc.size > 0) {
      return false;
    }
    await reference.add(model.toMap());
    return true;
  }

  Future<void> removeDriver(String id) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(collectionRef);
    return await reference.doc(id).delete();
  }

  Future<bool> checkDriverLogin(DriverRegisterModel model) async {
    CollectionReference reference = FirebaseFirestore.instance.collection(collectionRef);
    final doc = await reference.where('mobile', isEqualTo: model.mobile).snapshots().first;
    if (doc.size > 0) {
      return true;
    }
    return false;
  }

  update(DriverRegisterModel model, String id) async {
    DocumentReference reference = FirebaseFirestore.instance.collection(collectionRef).doc(model.id);
    await reference.update(model.toMap());
  }
}

class MyDrivers with ChangeNotifier {
  List<DriverModel> driverList = [];
  List<DriverModel> get drivers => driverList;
  final User user = FirebaseAuth.instance.currentUser;
  getAllDrivers() async {
    CollectionReference driverRequest = FirebaseFirestore.instance.collection(FirebaseHelper.driverRegistered);
    CollectionReference driver = FirebaseFirestore.instance.collection(FirebaseHelper.driverCollection);
    final snapShot = driver.where('agent', isEqualTo: user.uid).snapshots();
    snapShot.listen((event) {
      for (QueryDocumentSnapshot d in event.docs) {
        driverList.add(DriverModel.fromSnapshot(d));
      }
      notifyListeners();
    });
  }
}

class AvailableDrivers with ChangeNotifier {
  List<DriverModel> driverAList = [];
  List<DriverModel> get drivers => driverAList;
  final User user = FirebaseAuth.instance.currentUser;
  getAvailableDrivers() async {
    CollectionReference driverRequest = FirebaseFirestore.instance.collection(FirebaseHelper.driverRegistered);
    CollectionReference driver = FirebaseFirestore.instance.collection(FirebaseHelper.driverCollection);
    final snapShot = driver.where('agent', isEqualTo: user.uid).snapshots();
    CollectionReference driverA = FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    snapShot.listen( (event) {
      for (QueryDocumentSnapshot d in event.docs) {
        DriverModel dd=DriverModel.fromSnapshot(d);
        driverA.where('driver',isEqualTo:  dd.uid).get().then((value){
          int c=0;
          print("dlen:${value.docs.length}");
          if(value.docs.isEmpty){
            c=1;
          }
          for(var d in value.docs){
            if(d.get('driver')!=dd.uid){
              c=1;
            }
          }
          if(c==1){
            driverAList.add(dd);
          }
        });
      }
      notifyListeners();
    });
  }
}
