import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/driver/pages/fleetUpload_screen.dart';
import 'package:truk_fleet/driver/pages/support_screen.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/screens/about.dart';
import 'package:truk_fleet/screens/fleetSelection_screen.dart';
import 'package:truk_fleet/driver/pages/settings.dart';
//import '../../helper/background_location.dart' as backLoc;
import 'package:background_location/background_location.dart' as backLoc;
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
import '../pages/profile_screen.dart';
import '../../utils/constants.dart';

class DrawerMenu extends StatefulWidget {
  @override
  DrawerMenuState createState() => DrawerMenuState();
}

class DrawerMenuState extends State<DrawerMenu> {
  bool driverOnline = false;
  final User user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    SharedPref()
        .isOnline()
        .then((value) => setState(() => driverOnline = value));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).locale;
    final pUser = Provider.of<MyDriverUser>(context);
    double width = MediaQuery.of(context).size.width;
    Widget placeHolder = Text(
        pUser.isUserLoading ? '...' : '${pUser.user.name[0]}'.toUpperCase(),
        style: TextStyle(
            fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold));
    return ListView(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: pUser.isUserLoading
                    ? CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryColor,
                        child: placeHolder,
                      )
                    : (pUser.user.image == 'na' || pUser.user.image == null
                        ? CircleAvatar(
                            radius: 40,
                            backgroundColor: primaryColor,
                            child: placeHolder,
                          )
                        : Container(
                            height: 80,
                            width: 80,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: CachedNetworkImage(
                                imageUrl: pUser.user.image,
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                              ),
                            ),
                          )),
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  pUser.isUserLoading ? 'Loading...' : '${pUser.user.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  pUser.isUserLoading ? 'Loading...' : '${pUser.user.mobile}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) => Profile()));
                  },
                  child: Text(
                      AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.edit),
                      style: TextStyle(color: Colors.blue, fontSize: 18)),
                ),
              ),
              SizedBox(height: 5),
              Divider(height: 2),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        SwitchListTile(
          secondary: Icon(
            Icons.switch_camera,
            color: Colors.black,
          ),
          value: driverOnline,
          onChanged: (b) async {
            CollectionReference inRide =
                FirebaseFirestore.instance.collection('InRide');
            final inRideDoc = await inRide.doc(user.uid).get();
            if (inRideDoc.exists) {
              Fluttertoast.showToast(
                  msg: 'Cannot go offline during ride! Complete the ride');
              return;
            }
            await SharedPref().setOnlineStatus(b);
            bool s = await SharedPref().isOnline();
            print(s);
            if (!b) {
              backLoc.BackgroundLocation.stopLocationService();
              CollectionReference driverAvaialable =
                  FirebaseFirestore.instance.collection('DriverAvailable');
              driverAvaialable.doc(user.uid).delete();
            } else
              backLoc.BackgroundLocation.startLocationService();
            setState(() {
              driverOnline = b;
            });
          },
          activeColor: primaryColor,
          title: Text(
            AppLocalizations.getLocalizationValue(
                locale,
                driverOnline
                    ? LocaleKey.driverOnline
                    : LocaleKey.driverOffline),
            style: TextStyle(
              color: driverOnline ? primaryColor : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        myListTile(
            title: AppLocalizations.getLocalizationValue(
                locale, LocaleKey.documents),
            leading: Icon(
              Icons.dock,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => DriverDocumentScreen(),
              ));
            }),
        myListTile(
          title:
              AppLocalizations.getLocalizationValue(locale, LocaleKey.support),
          leading: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(
              Icons.contact_support,
              color: Colors.black,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SupportScreen(),
              ),
            );
          },
        ),
        myListTile(
          title: AppLocalizations.getLocalizationValue(locale, LocaleKey.about),
          leading: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(
              Icons.info_outlined,
              color: Colors.black,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AboutUs(),
              ),
            );
          },
        ),
        myListTile(
          title:
              AppLocalizations.getLocalizationValue(locale, LocaleKey.settings),
          leading: Icon(
            Icons.settings,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          },
        ),
        SizedBox(height: 50),
        Container(
          height: 50,
          width: width,
          alignment: Alignment.center,
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app,
                    color: Color.fromRGBO(255, 113, 1, 100)),
                SizedBox(width: 10),
                Text(
                  AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.logout),
                  style: TextStyle(fontSize: 20, color: primaryColor),
                )
              ],
            ),
            onTap: () {
              Helper().showConfirmationDialog(
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.logout),
                subTitle: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.logoutConfirm),
                context: context,
                onTap: () {
                  Navigator.pop(context);
                  SharedPref().logoutUser();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FleetSelection(),
                    ),
                    (route) => false,
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget myListTile({String title, void Function() onTap, Widget leading}) {
    return ListTile(
      leading: leading,
      title: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
      onTap: onTap,
    );
  }
}
