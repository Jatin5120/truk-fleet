import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:truk_fleet/driver/pages/inride_page.dart';
import 'package:truk_fleet/driver/pages/start_trip.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/no_data_page.dart';
import '../../utils/constants.dart';
import '../alertbox.dart';

class HomepageFragment extends StatefulWidget {
  final Function onAppbarBack;

  const HomepageFragment({Key key, this.onAppbarBack}) : super(key: key);

  @override
  HomepageFragmentState createState() => HomepageFragmentState();
}

class HomepageFragmentState extends State<HomepageFragment>
    with AutomaticKeepAliveClientMixin {
  final User user = FirebaseAuth.instance.currentUser;
  bool driverStatus = true;
  final Permission _permission = Permission.location;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  Locale locale;
  TextEditingController amount = new TextEditingController();
  bool iss = false;
  var advance = 0.0;
  var a = 0.0;
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return primaryColor;
    }
    return primaryColor;
  }

  @override
  void initState() {
    super.initState();

    _checkGps().then((value) async {
      if (value) {
        _listenForPermissionStatus();
        if (_permissionStatus != PermissionStatus.granted) {
          await requestPermission(_permission);
        }
      }
    });
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext _) {
            locale = AppLocalizations.of(_).locale;
            return AlertDialog(
              title: Text(AppLocalizations.getLocalizationValue(
                  locale, LocaleKey.gpsDisabled)),
              content: Text(AppLocalizations.getLocalizationValue(
                  locale, LocaleKey.gpsDisableMsg)),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('OK'),
                  onPressed: () {
                    final intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');

                    intent.launch();
                    Navigator.of(_, rootNavigator: true).pop();
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

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  _getLocation(context, ShipmentModel model) async {
    bool s = await _checkGps() ?? false;
    if (!s) {
      Fluttertoast.showToast(
          msg: AppLocalizations.getLocalizationValue(
              locale, LocaleKey.gpsDisableError));
      return;
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    final lat = pos.latitude;
    final lng = pos.longitude;
    FirebaseFirestore.instance
        .collection(FirebaseHelper.driverCollection)
        .doc(user.uid)
        .get()
        .then((value) async {
      print('your id is ${model.id}');
      var r = await value.reference.collection(model.id).get();
      int x = r.docs.length;
      await value.reference
          .collection(model.id)
          .doc(x.toString())
          .set({'position': '$lat,$lng', 'time': DateTime.now().toString()});
    });
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    locale = AppLocalizations.of(context).locale;
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirebaseHelper.shipment)
              .where('driver', isEqualTo: user.uid)
              .where('status', whereIn: [
            RequestStatus.pending,
            RequestStatus.started,
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
                child: Text(
                  AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.noData),
                ),
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
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                ShipmentModel model =
                    ShipmentModel.fromSnapshot(snapshot.data.docs[index]);
                FirebaseFirestore.instance
                    .collection(FirebaseHelper.quoteCollection)
                    .where('bookingId', isEqualTo: model.bookingId)
                    .get()
                    .then((value) {
                  print("Hi");
                  print(value.docs.length);
                  for (var d in value.docs) {
                    a = double.parse(d.get('advance').toString());
                    print(a);
                  }
                });
                return buildCardRequests(model,snapshot.data.docs[index].id);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildCardRequests(ShipmentModel model,String shipmentId) {
    print(
        "pending:${model.status == RequestStatus.pending}  cod::${model.paymentStatus.toString().toLowerCase() == "cod"}  ap::${model.amountPaid == null}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 12,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10.0, right: 10, top: 20, bottom: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "${model.truk}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 17)),
                          TextSpan(
                            text: "  (${model.trukName})",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
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
                    style: TextStyle(color: primaryColor),
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
                            return Text('Address...');
                          }
                          return Text(
                              "${AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupLocation)}: ${snapshot.data.split(",")[2] ?? snapshot.data.split(",")[3]}");
                        }),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  FutureBuilder<String>(
                      future: Helper().setLocationText(model.destination),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text('Address...');
                        }
                        return Text(
                          "${AppLocalizations.getLocalizationValue(locale, LocaleKey.destination)}: ${snapshot.data.split(",")[2] ?? snapshot.data.split(",")[3]}",
                        );
                      }),
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
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        primary: primaryColor,
                      ),
                      onPressed: model.status == RequestStatus.started
                          ? () {
                        Utils.currentShipmentId = shipmentId;
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => InRidePage(
                                    model: model,
                                  ),
                                ),
                              );
                            }
                          : model.status == 'toBeAcceptedByDriver'
                              ? _rejectShipment(model)
                              : () async {
                        Utils.currentShipmentId = shipmentId;
                        bool isOnline = await SharedPref().isOnline();
                                  if (!isOnline) {
                                    Fluttertoast.showToast(
                                      msg: 'Please enable your online status',
                                      gravity: ToastGravity.TOP,
                                      backgroundColor: primaryColor,
                                      textColor: Colors.white,
                                      fontSize: 18,
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => UploadStartTrip(
                                        model: model,
                                      ),
                                    ),
                                  );
                                },
                      child: Text(
                        model.status == RequestStatus.started
                            ? AppLocalizations.getLocalizationValue(
                                locale, LocaleKey.showTrip)
                            : model.status == 'toBeAcceptedByDriver'
                                ? AppLocalizations.getLocalizationValue(
                                    locale, LocaleKey.reject)
                                : AppLocalizations.getLocalizationValue(
                                    locale, LocaleKey.startTrip),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    onPressed: () async {
                      String fileUrl = model.ewaybill;
                      if (await canLaunch(fileUrl)) {
                        launch(fileUrl);
                      } else {
                        Fluttertoast.showToast(msg: "Cannot find Eway Bill");
                      }
                    },
                    child: Text(
                      "Show Eway Bill",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _getLocation(context, model);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: primaryColor,
                    ),
                    child: Text(AppLocalizations.getLocalizationValue(
                        locale, LocaleKey.updateLocation)),
                  )
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Visibility(
                    visible: model.status == RequestStatus.pending &&
                            model.paymentStatus.toString().toLowerCase() ==
                                "cod" &&
                            model.amountPaid == null
                        ? true
                        : false,
                    child: ElevatedButton(
                      onPressed: () {
                        print(model.truk);
                        print(a);
                        setState(() {
                          advance = a;
                        });
                        showDialog(
                            context: context,
                            builder: (context) => AB(model: model));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: primaryColor,
                      ),
                      child: Text(AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.receivePayment)),
                    ),
                  ),
                  Visibility(
                    visible: model.status == RequestStatus.pending &&
                        model.paymentStatus.toString().toLowerCase() ==
                            "cod" &&
                        model.amountPaid == null
                        ? true
                        : false,
                    // visible: model.status == RequestStatus.started ? false : true,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        primary: primaryColor,
                      ),
                      onPressed: model.status == RequestStatus.started
                          ? null
                          : () => _rejectShipment(model),
                      child: Text(
                        model.status == RequestStatus.started
                            ? AppLocalizations.getLocalizationValue(
                                locale, LocaleKey.showTrip)
                            : model.status == 'toBeAcceptedByDriver'
                                ? AppLocalizations.getLocalizationValue(
                                    locale, LocaleKey.reject)
                                : AppLocalizations.getLocalizationValue(
                                    locale, LocaleKey.reject),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                visible: model.status == RequestStatus.pending &&
                    model.paymentStatus.toString().toLowerCase() ==
                        "cod" &&
                    model.amountPaid == null
                    ? true
                    : false,
                child: SizedBox(
                  height: 10.0,
                ),
              ),
              ElevatedButton(
                onPressed: () async{
                  final cord = Coords(model.source.latitude,
                      model.source.longitude);
                  final availableMaps = await MapLauncher.installedMaps;
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: SingleChildScrollView(
                          child: Container(
                            child: Wrap(
                              children: <Widget>[
                                for (var map in availableMaps)
                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      map.showMarker(
                                        coords: cord,
                                        title: AppLocalizations
                                            .getLocalizationValue(locale,
                                            LocaleKey.pickupLocation),
                                      );
                                    },
                                    title: Text(map.mapName),
                                    leading: SvgPicture.asset(
                                      map.icon,
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );                },
                style: ElevatedButton.styleFrom(
                  primary: primaryColor,
                ),
                child: Text(AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.navigateToPickup)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  _pay(ShipmentModel model, a) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text("Processing...."), CircularProgressIndicator()],
          ),
        ),
      ),
    );
    if (double.parse(amount.text) <= a ||
        int.parse(amount.text) > int.parse(model.price)) {
      Fluttertoast.showToast(msg: "Please Enter Valid Amount received amount");
      Navigator.pop(context);
    } else {
      FirebaseFirestore.instance
          .collection(FirebaseHelper.shipment)
          .doc(model.id)
          .get()
          .then((value) {
        value.reference.update({'amountPaid': amount.text});
      });
      Fluttertoast.showToast(msg: "Amount received : ${amount.text}");
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  _rejectShipment(ShipmentModel model) async {
    await FirebaseFirestore.instance
        .collection(FirebaseHelper.quoteCollection)
        .where('bookingId', isEqualTo: model.bookingId)
        .get()
        .then((value) {
      for (var d in value.docs) {
        d.reference.update({'status': 'accepted'});
      }
    });
    await FirebaseFirestore.instance
        .collection(FirebaseHelper.shipment)
        .where('bookingId', isEqualTo: model.bookingId)
        .get()
        .then((value) {
      for (var e in value.docs) {
        e.reference.delete();
      }
    });
  }

  getAdvance(ShipmentModel model) {
    var b = 0.0;
    FirebaseFirestore.instance
        .collection(FirebaseHelper.quoteCollection)
        .where('bookingId', isEqualTo: model.bookingId)
        .get()
        .then((value) {
      print("Hi");
      print(value.docs.length);
      for (var d in value.docs) {
        setState(() {
          b = double.parse(d.get('advance').toString());
          print(b);
        });
      }
    });
    return b;
  }
}
