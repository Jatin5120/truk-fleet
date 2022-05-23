import 'dart:async';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/pages/fragments/stats_screen.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/notification_model.dart';
import 'package:truk_fleet/models/pending_payout_model.dart';
import '../../company/controller/add_driver_controller.dart';
import '../../company/controller/chat_controller.dart';
import '../../company/controller/my_shipment_controller.dart';
import '../../company/controller/request_controller.dart';
import '../../company/utils/company_drawer.dart';
import '../../firebase_helper/notification_helper.dart';
import '../../models/truk_model.dart';
import '../../models/user_model.dart';
import '../../screens/notification_screen.dart';
import '../../utils/constants.dart';
import '../../company/pages/fragments/chat_fragment.dart';
import '../../company/pages/fragments/request_fragment.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CompanyHome extends StatefulWidget {
  @override
  _CompanyHomeState createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  int currentIndex, backTaps = 0;
  bool back = false;
  Locale locale;
  StreamSubscription streamSubscription;
  static final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
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
        msg:
            AppLocalizations.getLocalizationValue(locale, LocaleKey.backAgain));
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

  int count = 0;
  @override
  void initState() {
    super.initState();
    Provider.of<MyUser>(context, listen: false).getUserFromDatabase();
    final b = Provider.of<MyRequest>(context, listen: false);
    b.getRequestList();
    b.getQuoteList();
    Provider.of<MyTruksProvider>(context, listen: false).getTrukList();
    Provider.of<MyDrivers>(context, listen: false).getAllDrivers();
    Provider.of<AvailableDrivers>(context, listen: false).getAvailableDrivers();
    Provider.of<FleetRideModel>(context, listen: false).getAllDriverShipment();
    Provider.of<ChatController>(context, listen: false).getAllMessages();
    Provider.of<MyPendingPayout>(context, listen: false).getPendingPayouts();
    NotificationHelper().configLocalNotification();
    NotificationHelper().registerNotification(doc: FirebaseHelper.fleetOwnerCollection);
    currentIndex = 0;

    streamSubscription = FirebaseHelper().getNotificationCount();
    streamSubscription.onData((d) {
      count = 0;
      for (QueryDocumentSnapshot s in d.docs) {
        NotificationModel m = NotificationModel.fromSnap(s);
        if (!m.isSeen) {
          count++;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  void onTabTap(int value) {
    if (value < 3) {
      setState(() {
        currentIndex = value;
      });
      _pageController.jumpToPage(currentIndex);
    } else {
      _drawerKey.currentState.openDrawer();
    }
  }

  final List<Widget> children = [
    StatsScreen(),
    RequestFragment(),
    ChatFragment()
  ];

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Colors.white,
        drawer: Drawer(
          child: CompanyDrawerMenu(),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: Platform.isAndroid,
          title: Image.asset(
            'assets/images/logo.png',
            height: 100,
            width: 100,
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Badge(
                child: Icon(Icons.notifications),
                padding: EdgeInsets.all(count == 0 ? 0 : 5),
                position: BadgePosition.topEnd(end: -5),
                badgeContent: Text(
                  count == 0 ? "" : "$count",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
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
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Icons.dashboard,
                  color: currentIndex == 0 ? primaryColor : Colors.grey,
                  size: 22,
                ),
              ),
              label: AppLocalizations.getLocalizationValue(
                  locale, LocaleKey.myStats),
            ),
            // BottomNavigationBarItem(
            //   icon: Padding(
            //     padding: const EdgeInsets.only(bottom: 5),
            //     child: Icon(
            //       Icons.home,
            //       color: currentIndex == 1 ? primaryColor : Colors.grey,
            //       size: 22,
            //     ),
            //   ),
            //   label: AppLocalizations.getLocalizationValue(locale, LocaleKey.shipments),
            // ),
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
                  locale, LocaleKey.requestButton),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Icons.chat,
                  color: currentIndex == 2 ? primaryColor : Colors.grey,
                  size: 22,
                ),
              ),
              label:
                  AppLocalizations.getLocalizationValue(locale, LocaleKey.chat),
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
