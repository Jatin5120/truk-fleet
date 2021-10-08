import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/driver_register_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/company/pages/add_driver_one.dart';
import 'package:truk_fleet/utils/no_data_page.dart';

class PendingDriver extends StatefulWidget {
  @override
  _PendingDriverState createState() => _PendingDriverState();
}

class _PendingDriverState extends State<PendingDriver> {
  final User user = FirebaseAuth.instance.currentUser;
  List<DriverRegisterModel> list = [];
  bool isLoading = true;
  List<DriverModel> temp = [];
  StreamSubscription<QuerySnapshot> streamSubscription;
  Locale locale;

  Future<void> getPendingDrivers() async {
    CollectionReference driverRequest =
        FirebaseFirestore.instance.collection(FirebaseHelper.driverRegistered);
    final snap = driverRequest.where('agent', isEqualTo: user.uid).snapshots();

    streamSubscription = snap.listen((element) {
      list = [];
      for (DocumentSnapshot d in element.docs) {
        DriverRegisterModel registerModel = DriverRegisterModel.fromSnapshot(d);
        list.add(registerModel);
      }
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getPendingDrivers();
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  Widget driverDetail(String key,
      {String name,
      String driverID,
      String route,
      String status,
      String journeyStatus,
      String image}) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: FocusedMenuHolder(
        openWithTap: true,
        onPressed: () {},
        menuOffset: 5,
        bottomOffsetHeight: 10,
        menuWidth: MediaQuery.of(context).size.width - 32,
        menuItems: [
          FocusedMenuItem(
            title: Text(AppLocalizations.getLocalizationValue(
                locale, LocaleKey.delete)),
            trailingIcon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              //print(status);
              if (status == LocaleKey.assigned) {
                Fluttertoast.showToast(msg: "Cannot delete Assigned truk");
                return;
              }
              if (status == LocaleKey.inTransit) {
                Fluttertoast.showToast(msg: "Cannot delete in transit truk");
                return;
              }
              Helper().showConfirmationDialog(
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.delete),
                subTitle:
                    "${AppLocalizations.getLocalizationValue(locale, LocaleKey.deleteConfirm)} - $name?",
                context: context,
                onTap: () async {
                  CollectionReference reference = FirebaseFirestore.instance
                      .collection(FirebaseHelper.driverRegistered);
                  await reference.doc(key).delete();
                },
              );
            },
          ),
        ],
        child: Card(
          elevation: 3.5,
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${AppLocalizations.getLocalizationValue(locale, LocaleKey.mobile)}: $driverID',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.getLocalizationValue(locale, LocaleKey.pending)),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 65,
          width: size.width,
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              primary: primaryColor,
            ),
            onPressed: () {
              // Add a different driver
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DriverDetails()));
            },
            child: Text(
              AppLocalizations.getLocalizationValue(
                  locale, LocaleKey.addDriver),
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 20),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : (list.length == 0
                ? NoDataPage(
                    text: AppLocalizations.getLocalizationValue(
                        locale, LocaleKey.noDriver),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(FirebaseHelper.driverCollection)
                        .where('agent', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        );
                      }
                      for (QueryDocumentSnapshot d in snapshot.data.docs) {
                        temp.add(DriverModel.fromSnapshot(d));
                      }
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          DriverRegisterModel registerModel = list[index];
                          if (temp.any((element) =>
                              element.mobile == "+91${registerModel.mobile}")) {
                            return Container();
                          }
                          return driverDetail(registerModel.id,
                              driverID: registerModel.mobile,
                              image: 'NA',
                              name: registerModel.name);
                        },
                      );
                    },
                  )),
      ),
    );
  }
}
