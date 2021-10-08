import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:truk_fleet/company/pages/add_driver_two.dart';
import 'package:truk_fleet/company/pages/pending_drivers.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/company/pages/add_driver_one.dart';
import 'package:truk_fleet/utils/no_data_page.dart';

import 'edit_driver.dart';

class MyDrivers extends StatefulWidget {
  @override
  _MyDriversState createState() => _MyDriversState();
}

class _MyDriversState extends State<MyDrivers> {
  final User user = FirebaseAuth.instance.currentUser;
  Locale locale;
  Future<String> getDriverStatus(String driverId) async {
    print(driverId);
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    final stream = reference.where('driver', isEqualTo: driverId).snapshots();
    //print(stream.size);
    String status;
    stream.forEach((element) {
      for (QueryDocumentSnapshot snap in element.docs) {
        status = snap.get('status') ?? "Not Assinged";
      }
    });

    // if (stream.size > 0) {
    //   String status = stream.docs[0].get('status');
    //   print(status);
    //   return status;
    // }
    return status;
  }

  Widget driverDetail(
      {String driverUid,
      String name,
      String driverID,
      String route,
      String status,
      String journeyStatus,
      String image,
      String contact}) {
    Widget placeHolder = Text(
      '${name[0]}',
      style: TextStyle(
        fontSize: 26,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
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
            title: Text(
                AppLocalizations.getLocalizationValue(locale, LocaleKey.edit)),
            trailingIcon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => EditDriverDetails(
                    mobile: contact,
                  ),
                ),
              );
            },
          ),
          FocusedMenuItem(
            title: Text(AppLocalizations.getLocalizationValue(
                locale, LocaleKey.documents)),
            trailingIcon: Icon(Icons.dock),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => MoreDriverDetails(
                    uid: driverUid,
                  ),
                ),
              );
            },
          ),
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
                Fluttertoast.showToast(msg: "Cannot delete Assigned driver");
                return;
              }
              if (status == LocaleKey.inTransit) {
                Fluttertoast.showToast(msg: "Cannot delete in transit driver");
                return;
              }
              Helper().showConfirmationDialog(
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.delete),
                subTitle:
                    "${AppLocalizations.getLocalizationValue(locale, LocaleKey.deleteConfirm)} - $driverID?",
                context: context,
                onTap: () async {
                  CollectionReference reference = FirebaseFirestore.instance
                      .collection(FirebaseHelper.driverCollection);
                  await reference.doc(driverUid).delete();
                },
              );
            },
          ),
        ],
        child: Card(
          elevation: 3.5,
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: primaryColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: image == 'na'
                    ? Center(child: placeHolder)
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
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
                    'ID: $driverID',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // Text(
                  //   journeyStatus == 'Pending' ? 'From location - To location' : '$route',
                  //   style: TextStyle(fontSize: 14, color: journeyStatus == 'Pending' ? Colors.grey : Colors.black),
                  // ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(FirebaseHelper.shipment)
                        .where('driver', isEqualTo: driverUid)
                        .where('agent', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          AppLocalizations.getLocalizationValue(
                            locale,
                            status == LocaleKey.assigned
                                ? LocaleKey.assigned
                                : status == LocaleKey.inTransit
                                    ? LocaleKey.inTransit
                                    : LocaleKey.available,
                          ),
                        );
                      }

                      List<ShipmentModel> m = [];
                      for (QueryDocumentSnapshot s in snapshot.data.docs) {
                        ShipmentModel model = ShipmentModel.fromSnapshot(s);
                        m.add(model);
                      }
                      if (m.any((element) =>
                          element.status == RequestStatus.started)) {
                        status = LocaleKey.inTransit;
                      } else if (m.any((element) =>
                          element.status == RequestStatus.assigned)) {
                        status = LocaleKey.assigned;
                      } else
                        status = LocaleKey.available;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.getLocalizationValue(
                                locale, status),
                            style: TextStyle(
                                color: status == LocaleKey.assigned
                                    ? primaryColor
                                    : Colors.blue,
                                fontSize: 14),
                          ),
                          // Text(
                          //   '$journeyStatus',
                          //   style: TextStyle(
                          //       color: journeyStatus == 'In Transit' ? Colors.green : Colors.grey, fontSize: 14),
                          // )
                        ],
                      );
                    },
                  )
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
            AppLocalizations.getLocalizationValue(locale, LocaleKey.myDriver)),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PendingDriver(),
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8, left: 8),
              child: Center(
                child: Text(
                  AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.pending),
                  style: TextStyle(color: primaryColor, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 65,
          width: size.width,
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: primaryColor,
            onPressed: () {
              // Add a different driver
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => DriverDetails()));
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirebaseHelper.driverCollection)
              .where('agent', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.noData)),
              );
            }
            if (snapshot.data.size <= 0) {
              return NoDataPage(
                text: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.noDriver),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DriverModel model =
                    DriverModel.fromSnapshot(snapshot.data.docs[index]);

                return driverDetail(
                    driverUid: model.uid,
                    driverID: model.driverId,
                    image: model.image,
                    name: model.name,
                    journeyStatus: 'Pending',
                    route: 'Pending',
                    status: 'Pending',
                    contact: model.mobile);
              },
            );
          },
        ),
      ),
    );
  }
}
