import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as m;
import 'package:permission_handler/permission_handler.dart';
import 'package:truk_fleet/driver/pages/endTripUploadPicture.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/material_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/utils/constants.dart';

class InRidePage extends StatefulWidget {
  final ShipmentModel model;

  const InRidePage({Key key, this.model}) : super(key: key);

  @override
  _InRidePageState createState() => _InRidePageState();
}

class _InRidePageState extends State<InRidePage> {
  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;
  GoogleMapController mapController;
  LatLng myLatLng;
  Map<String, Marker> myMarker = {};
  Locale locale;
  bool isLoading = true;
  final Permission _permission = Permission.location;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  int distance;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    CameraUpdate c = CameraUpdate.newLatLngZoom(myLatLng, 16);
    mapController.animateCamera(c);
    myMarker.clear();
    CameraUpdate cd = CameraUpdate.newLatLngZoom(widget.model.destination, 16);
    mapController.animateCamera(cd);
    myMarker['destination'] = Marker(
      markerId: MarkerId('destination'),
      position: widget.model.destination,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {});
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

        if (_permissionStatus == PermissionStatus.granted) _getLocation(context);
      }
    });
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("GPS disabled"),
              content: const Text('Please make sure you enable GPS and try again'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    final intent = AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');

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

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  _getLocation(context) async {
    bool s = await _checkGps() ?? false;
    if (!s) {
      Fluttertoast.showToast(msg: "Please enable GPS to proceed");
      return;
    }
    setState(() {
      isLoading = true;
    });
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final lat = pos.latitude;
    final lng = pos.longitude;
    if (pos != null) {
      myLatLng = LatLng(lat, lng);
      //await SharedPref().createLocationData(lat, lng);
    }

    isLoading = false;
    if (mounted) setState(() {});
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
    final Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    double weight = 0;
    for (MaterialModel val in widget.model.materials) {
      weight += val.quantity;
    }
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                height: 65,
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  color: primaryColor,
                  onPressed: () async {
                    final cord = m.Coords(widget.model.destination.latitude, widget.model.destination.longitude);
                    final availableMaps = await m.MapLauncher.installedMaps;
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
                                          title:
                                              AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupLocation),
                                        );
                                      },
                                      title: Text(map.mapName ?? "Google"),
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
                    );
                  },
                  child: Text(
                    AppLocalizations.getLocalizationValue(locale, LocaleKey.navigate),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 65,
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  color: Colors.red,
                  onPressed: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => UploadEndTrip(
                          model: widget.model,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.getLocalizationValue(locale, LocaleKey.endTrip),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.getLocalizationValue(locale, LocaleKey.inTransit),
        ),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Getting Location",
                    ),
                    SizedBox(height: 10),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  Container(
                    width: size.width,
                    padding: EdgeInsets.all(10),
                    child: Card(
                      elevation: 3.5,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              'assets/images/no_data.png',
                              height: 80,
                              width: 80,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  child: Container(
                                    child: Text(
                                        '${AppLocalizations.getLocalizationValue(locale, LocaleKey.shipmentId)} : ${widget.model.bookingId}'),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Text(
                                      '${AppLocalizations.getLocalizationValue(locale, LocaleKey.quantity)}: $weight Kg'),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                FutureBuilder<String>(
                                  future: Helper().setLocationText(widget.model.destination),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                                      return Text('Address...');
                                    }
                                    return Text(
                                      "${AppLocalizations.getLocalizationValue(locale, LocaleKey.destination)}: ${snapshot.data.split(',')[1].trimLeft() ?? snapshot.data.split(',')[2].trimLeft()}",
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GoogleMap(
                      markers: myMarker.values.toSet(),
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: myLatLng,
                        zoom: 11.0,
                      ),
                      padding: EdgeInsets.only(
                        top: height * 0.4,
                      ),
                      zoomGesturesEnabled: true,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
