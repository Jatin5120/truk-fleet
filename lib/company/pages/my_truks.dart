import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:truk_fleet/company/controller/truk_controller.dart';
import 'package:truk_fleet/company/pages/add_truk_one.dart';
import 'package:truk_fleet/company/pages/add_truk_two.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/models/truk_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/no_data_page.dart';

class MyTrucks extends StatefulWidget {
  @override
  _MyTrucksState createState() => _MyTrucksState();
}

class _MyTrucksState extends State<MyTrucks> {
  final User user = FirebaseAuth.instance.currentUser;
  Locale locale;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.getLocalizationValue(locale, LocaleKey.myTruks)),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 65,
          width: size.width,
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              primary: primaryColor,
            ),
            onPressed: () {
              // Add a different driver
              Navigator.of(context)
                  .push(CupertinoPageRoute(builder: (context) => AddTruck()));
            },
            child: Text(
              AppLocalizations.getLocalizationValue(locale, LocaleKey.addTruk),
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(bottom: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirebaseHelper.trukCollection)
              .where('ownerId', isEqualTo: user.uid)
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
                    locale, LocaleKey.noData),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                TrukModal modal =
                    TrukModal.fromSnapshot(snapshot.data.docs[index]);

                return truckDetail(
                  trukBodyType: modal.trukType,
                  trukID: modal.trukNumber,
                  trukName: modal.trukName,
                  journeyStatus: 'Pending',
                  route: 'Pending',
                  status: 'Pending',
                  trukModal: modal,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget truckDetail(
      {String trukName,
      String trukID,
      String trukBodyType,
      String route,
      String status,
      String journeyStatus,
      TrukModal trukModal}) {
    Widget placeHolder = Image.asset(
      'assets/images/no_data.png',
      fit: BoxFit.contain,
      height: 40,
      width: 40,
    );
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 10),
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
                  builder: (context) => AddTruck(
                    isEdit: true,
                    trukModal: trukModal,
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
                  builder: (context) => MoreTrukDetails(
                    trukNumber: trukModal.trukNumber.toUpperCase(),
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
                    "${AppLocalizations.getLocalizationValue(locale, LocaleKey.deleteConfirm)} - $trukID?",
                context: context,
                onTap: () async {
                  await TrukController().deleteTruk(trukID);
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
                  borderRadius: BorderRadius.circular(40), color: Colors.grey),
              child: Center(
                child: placeHolder,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '$trukName ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text:
                              '(${AppLocalizations.getLocalizationValue(locale, trukBodyType.toLowerCase().contains("opentruk") ? LocaleKey.openTruk : trukBodyType.toLowerCase().contains('trailertruk')? LocaleKey.trailerTruk : LocaleKey.containerTruk)})',
                              // '(${AppLocalizations.getLocalizationValue(locale, trukBodyType.toLowerCase().contains("closed") ? LocaleKey.closedTruk : LocaleKey.openTruk)})',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400)),
                    ]),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${AppLocalizations.getLocalizationValue(locale, LocaleKey.trukNumber)}: $trukID',
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
                        .where('truk', isEqualTo: trukID)
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
                              fontSize: 14,
                            ),
                          ),
                          // Text(
                          //   '$journeyStatus',
                          //   style: TextStyle(color: journeyStatus == 'In Transit' ? Colors.green : Colors.grey, fontSize: 14),
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
}
