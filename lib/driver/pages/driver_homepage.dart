import 'dart:async';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:background_location/background_location.dart' as backLoc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/firebase_helper/notification_helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/wallet_model.dart';
import 'package:truk_fleet/screens/notification_screen.dart';
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
import '../fragments/home_map_fragment.dart';
import '../fragments/my_ride_fragment.dart';
import 'package:flutter/material.dart';
import '../utils/drawer_part.dart';
import '../../utils/constants.dart';

class DriverHomeScreen extends StatefulWidget {
  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  int currentIndex, backTaps = 0;
  bool back = false;
  static final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  final User user = FirebaseAuth.instance.currentUser;
  Location location = Location();
  Locale locale;
  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    Provider.of<MyDriverUser>(context, listen: false).getUserFromDatabase();
    Provider.of<MyWallet>(context, listen: false).getWalletBalance();
    NotificationHelper()
        .registerNotification(doc: FirebaseHelper.driverCollection);

    checkPermission();
    // backLoc.BackgroundLocation.getPermissions(
    //   onGranted: () async {
    //     await initiateLocation();
    //   },
    //   onDenied: () {
    //     Fluttertoast.showToast(
    //         msg: 'Please allow background location for live tracking');
    //   },
    // );
  }

  Future checkPermission() async {
    backLoc.BackgroundLocation.startLocationService();
    if (await Permission.location.isGranted) {
      await initiateLocation();
    } else {
      Fluttertoast.showToast(
          msg: 'Please allow background location for live tracking');
    }
  }

  initiateLocation() async {
    bool gps = await _checkGps();
    if (gps) {
      bool isOnline = await SharedPref().isOnline();
      if (isOnline) backLoc.BackgroundLocation.startLocationService();
      CollectionReference inRide =
          FirebaseFirestore.instance.collection('InRide');

      backLoc.BackgroundLocation.getLocationUpdates((locationData) async {
        //print(locationData.latitude);
        final inRideDoc = await inRide.doc(user.uid).get();
        if (locationData != null) {
          String collectionName;
          CollectionReference driverAvaialable =
              FirebaseFirestore.instance.collection('DriverAvailable');
          CollectionReference driverWorking =
              FirebaseFirestore.instance.collection('DriverWorking');
          if (!inRideDoc.exists) {
            collectionName = 'DriverAvailable';
            driverWorking.doc(user.uid).delete();
          } else {
            collectionName = 'DriverWorking';
            driverAvaialable.doc(user.uid).delete();
          }
          CollectionReference reference =
              FirebaseFirestore.instance.collection(collectionName);
          GeoFirestore geoFirestore = GeoFirestore(reference);
          await geoFirestore.setLocation(user.uid,
              GeoPoint(locationData.latitude, locationData.longitude));
        }
      });
    }
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("GPS disabled"),
              content:
                  const Text('Please make sure you enable GPS and try again'),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Ok'),
                  onPressed: () {
                    final intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');

                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      return null;
    }
    return true;
  }

  Future<bool> _onBackPress() async {
    if (_drawerKey.currentState.isDrawerOpen) {
      Navigator.pop(context);
      return false;
    }
    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
      _pageController.jumpToPage(currentIndex);
      return false;
    }
    Fluttertoast.showToast(
      msg: AppLocalizations.getLocalizationValue(locale, LocaleKey.backAgain),
    );
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        backTaps = 0;
      });
    });
    if (backTaps == 0) {
      setState(() {
        backTaps = 1;
      });
      _onBackPress();
    } else {
      return true;
    }
    return false;
  }

  void onTabTap(int value) {
    if (value < 2) {
      setState(() {
        currentIndex = value;
      });
      _pageController.jumpToPage(currentIndex);
    } else {
      _drawerKey.currentState.openDrawer();
    }
  }

  final List<Widget> children = [
    HomepageFragment(),
    MyRide(
      onAppbarBack: () {
        _pageController.jumpToPage(0);
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        key: _drawerKey,
        drawer: Theme(
          data: ThemeData(disabledColor: Colors.black),
          child: Drawer(
            child: DrawerMenu(),
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: Platform.isAndroid,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Container(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/logo.png',
              height: 100,
              width: 100,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => NotificationScreen(),
                  ),
                );
              },
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabTap,
          selectedItemColor: primaryColor,
          selectedFontSize: 17,
          unselectedFontSize: 14,
          elevation: 12,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 25,
              ),
              label:
                  AppLocalizations.getLocalizationValue(locale, LocaleKey.home),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: SvgPicture.asset(
                  'assets/svg/truck_svg.svg',
                  height: 17,
                  width: 22,
                  color: currentIndex == 1 ? primaryColor : Colors.grey,
                ),
              ),
              label: AppLocalizations.getLocalizationValue(
                  locale, LocaleKey.shipments),
            ),
            if (Platform.isIOS)
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 22,
                  ),
                ),
                label: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.more),
              ),
          ],
        ),
        body: PageView.builder(
          onPageChanged: (ind) {
            setState(() {
              currentIndex = ind;
            });
          },
          itemCount: children.length,
          itemBuilder: (context, index) {
            return children[index];
          },
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
