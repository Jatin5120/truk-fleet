import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/pin_info_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/map_pin_component.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 70;
const double CAMERA_BEARING = 20;

class TrackShipment extends StatefulWidget {
  TrackShipment({this.shipmentModel, this.weight});
  final ShipmentModel shipmentModel;
  final String weight;
  @override
  _TrackShipmentState createState() => _TrackShipmentState();
}

class _TrackShipmentState extends State<TrackShipment> {
  final int currentMonth = DateTime.now().month;

  LatLng myLatLng;
  LatLng source;
  LatLng destination;
  Map<String, Marker> myMarker = {};
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin;
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;
  StreamSubscription<DocumentSnapshot> streamSubscription;

  Locale locale;

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    destination = myLatLng = widget.shipmentModel.destination;
    source = widget.shipmentModel.source;
    currentlySelectedPin = PinInformation(
      locationName: "Start Location",
      location: destination,
      pinPath: "assets/driving_pin.png",
      avatarPath: "assets/images/logo.png",
      labelColor: Colors.blueAccent,
    );
    location = new Location();
    polylinePoints = PolylinePoints();
    String driver = widget.shipmentModel.driver;
    CollectionReference driverWorking = FirebaseFirestore.instance.collection('DriverWorking');
    final stream = driverWorking.doc(driver).snapshots();

    streamSubscription = stream.listen((event) {
      List l = event.get('l');
      LatLng currentPos = LatLng(l[0], l[1]);
      currentLocation = LocationData.fromMap({"latitude": currentPos.latitude, "longitude": currentPos.longitude});
      updatePinOnMap();
    });
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
    //setState(() {});
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png')
        .then((value) => sourceIcon = value);

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png')
        .then((value) => destinationIcon = value);
    setState(() {});
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()

    String driver = widget.shipmentModel.driver;
    CollectionReference driverWorking = FirebaseFirestore.instance.collection('DriverWorking');
    final stream = await driverWorking.doc(driver).snapshots().first;
    List l = stream.get('l');
    LatLng currentPos = LatLng(l[0], l[1]);
    currentLocation = LocationData.fromMap({"latitude": currentPos.latitude, "longitude": currentPos.longitude});

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({"latitude": destination.latitude, "longitude": destination.longitude});
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition = LatLng(destinationLocation.latitude, destinationLocation.longitude);
    // add the initial source location pin
    _markers.add(Marker(markerId: MarkerId('sourcePin'), position: pinPosition, icon: sourceIcon));
    // destination pin
    _markers.add(Marker(markerId: MarkerId('destPin'), position: destPosition, icon: destinationIcon));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    sourcePinInfo = PinInformation(
        locationName: "Start Location",
        location: widget.shipmentModel.source,
        pinPath: "assets/driving_pin.png",
        avatarPath: "assets/images/logo.png",
        labelColor: Colors.blueAccent);

    destinationPinInfo = PinInformation(
        locationName: "End Location",
        location: widget.shipmentModel.destination,
        pinPath: "assets/destination_map_marker.png",
        avatarPath: "assets/images/logo.png",
        labelColor: Colors.purple);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon));
    setPolylines();
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(destinationLocation.latitude, destinationLocation.longitude));
    print(result.points.length);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      //if (mounted) {
      setState(() {
        _polylines.add(Polyline(
          width: 10, // set the width of the polylines
          polylineId: PolylineId("poly"),
          color: Colors.black,
          points: polylineCoordinates,
        ));
      });
      //}
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    source = widget.shipmentModel.source;
    CameraPosition initialCameraPosition =
        CameraPosition(zoom: CAMERA_ZOOM, tilt: CAMERA_TILT, bearing: CAMERA_BEARING, target: source);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.trackShipment)),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  '${AppLocalizations.getLocalizationValue(locale, LocaleKey.shipmentId)}: ${widget.shipmentModel.bookingId}'),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Text(
                                '${AppLocalizations.getLocalizationValue(locale, LocaleKey.quantity)}: ${widget.weight} Kg'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FutureBuilder<String>(
                            future: Helper().setLocationText(widget.shipmentModel.destination),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text('Address...');
                              }
                              return Text(
                                "${AppLocalizations.getLocalizationValue(locale, LocaleKey.destination)}: ${snapshot.data.split(',')[1].trimLeft()}",
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
              child: Stack(
                children: [
                  GoogleMap(
                    myLocationEnabled: true,
                    compassEnabled: true,
                    tiltGesturesEnabled: false,
                    markers: _markers,
                    polylines: _polylines,
                    myLocationButtonEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      //controller.setMapStyle(Utils.mapStyles);
                      _controller.complete(controller);
                      // my map has completed being created;
                      // i'm ready to show the pins on the map
                      showPinsOnMap();
                    },
                    onTap: (ltln) {
                      pinPillPosition = -100;
                    },
                    initialCameraPosition: initialCameraPosition,
                    padding: EdgeInsets.only(
                      top: size.height * 0.4,
                    ),
                    zoomGesturesEnabled: true,
                  ),
                  MapPinPillComponent(pinPillPosition: pinPillPosition, currentlySelectedPin: currentlySelectedPin)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }
}
