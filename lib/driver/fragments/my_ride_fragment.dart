import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import '../../utils/no_data_page.dart';

class MyRide extends StatefulWidget {
  final Function onAppbarBack;

  const MyRide({Key key, this.onAppbarBack}) : super(key: key);

  @override
  _MyRideState createState() => _MyRideState();
}

class _MyRideState extends State<MyRide> with AutomaticKeepAliveClientMixin {
  final User user = FirebaseAuth.instance.currentUser;
  Locale locale;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirebaseHelper.shipment)
              .where('driver', isEqualTo: user.uid)
              .where('status', whereIn: [
            RequestStatus.completed,
          ]).snapshots(),
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
                    locale, LocaleKey.noShipment),
              );
            }

            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.data.docs.length)
                  return SizedBox(height: 32);
                ShipmentModel model =
                    ShipmentModel.fromSnapshot(snapshot.data.docs[index]);
                return buildCardRequests(model);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildCardRequests(ShipmentModel model) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 16).copyWith(top: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${model.truk}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16),
                      ),
                      TextSpan(
                        text: " (${model.trukName})",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(model.pickupDate),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${AppLocalizations.getLocalizationValue(locale, LocaleKey.trukNumber)} : ${model.truk}"),
                Text(
                  model.trukName,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FutureBuilder<String>(
                    future: Helper().setLocationText(model.source),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('Source');
                      }
                      return Text(
                        "${snapshot.data.split(",")[2] ?? snapshot.data.split(",")[3]}",
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: primaryColor),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.arrow_right_alt_rounded,
                    color: primaryColor,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<String>(
                    future: Helper().setLocationText(model.destination),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('Destination');
                      }
                      return Text(
                        "${snapshot.data.split(",")[2] ?? snapshot.data.split(",")[3]}",
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: primaryColor),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${AppLocalizations.getLocalizationValue(locale, LocaleKey.payments)}: ${AppLocalizations.getLocalizationValue(locale, model.paymentStatus)}",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 15,
                ),
                // Container(
                //   height: 30,
                //   child: RaisedButton(
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                //     color: primaryColor,
                //     onPressed: () {
                //       //Navigator.push(context, CupertinoPageRoute(builder: (context) => ,));
                //     },
                //     child: Text(
                //       "Show Trip",
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
