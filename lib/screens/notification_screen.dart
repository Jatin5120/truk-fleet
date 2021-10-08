import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/company/pages/company_home.dart';
import 'package:truk_fleet/company/pages/my_shipment_screen.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/notification_model.dart';
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/no_data_page.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  final User user = FirebaseAuth.instance.currentUser;
  SharedPref pref = SharedPref();
  String userType = LoginType.driver;
  Locale locale;
  StreamSubscription s;
  @override
  void initState() {
    super.initState();
    pref.getLoginType().then((value) => setState(() => userType = value));
    // final snap = FirebaseHelper().seenNotification();
    // s = snap.listen((element) {
    //   for(QueryDocumentSnapshot d in element.docs){

    //   }
    // });
  }

  Widget notificationWidget({String time, String notification}) {
    return Card(
      elevation: 2.0,
      color: primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$time',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                flex: 0,
                child: InkWell(
                  onTap: (){
                    if(notification.toLowerCase().contains('started')){
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CompanyHomeFragment()));
                    }
                    if(notification.toLowerCase().contains('completed')){
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CompanyHomeFragment()));
                    }
                    if(notification.toLowerCase().contains('accepted')){
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CompanyHome()));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(bottom: 10, left: 5, top: 5),
                    width: width,
                    child: Text(
                      '$notification',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.notification)),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        margin: const EdgeInsets.only(top: 30),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirebaseHelper.notificationCollection)
              .where('uid', isEqualTo: user.uid)
              .orderBy('time', descending: true)
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
                child: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.noData)),
              );
            }
            List<NotificationModel> n = [];
            for (QueryDocumentSnapshot s in snapshot.data.docs) {
              NotificationModel notificationModel = NotificationModel.fromSnap(s);
              if (userType == LoginType.company) {
                if (notificationModel.isVendor) {
                  n.add(NotificationModel.fromSnap(s));
                }
              } else {
                if (notificationModel.isDriver) {
                  n.add(NotificationModel.fromSnap(s));
                }
              }
            }
            if (n.length <= 0) {
              return NoDataPage(
                text: AppLocalizations.getLocalizationValue(locale, LocaleKey.noNotification),
              );
            }
            if (snapshot.data.size <= 0) {
              return NoDataPage(
                text: AppLocalizations.getLocalizationValue(locale, LocaleKey.noNotification),
              );
            }

            int count = snapshot.data.docs.length;
            FirebaseHelper().seenNotification(n);
            return ListView.builder(
              itemCount: count,
              itemBuilder: (context, index) {
                NotificationModel notificationModel = NotificationModel.fromSnap(snapshot.data.docs[index]);
                if (userType == LoginType.company) {
                  if (notificationModel.isVendor) {
                    return Column(
                      children: [
                        notificationWidget(
                          notification: notificationModel.message,
                          time: Helper().getFormattedDate(
                            notificationModel.time,
                          ),
                        ),
                        Divider()
                      ],
                    );
                  } else
                    return Container();
                } else {
                  if (notificationModel.isDriver) {
                    return Column(
                      children: [
                        notificationWidget(
                          notification: notificationModel.message,
                          time: Helper().getFormattedDate(
                            notificationModel.time,
                          ),
                        ),
                        Divider()
                      ],
                    );
                  } else
                    return Container();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
