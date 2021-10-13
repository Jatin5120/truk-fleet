import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/controller/add_driver_controller.dart';
import 'package:truk_fleet/company/controller/request_controller.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/emailHelper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/material_model.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/request_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/models/truk_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:truk_fleet/utils/constants.dart';

import 'add_driver_one.dart';
import 'add_truk_one.dart';

class SendQuote extends StatefulWidget {
  final RequestModel requestModel;
  final QuoteModel quoteModel;
  final UserModel requestUser;
  final String keyTitle;
  SendQuote(
      {this.requestModel,
      this.quoteModel,
      this.requestUser,
      this.keyTitle = 'quote'});

  @override
  _SendQuoteState createState() => _SendQuoteState();
}

class _SendQuoteState extends State<SendQuote> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RequestModel requestModel;
  QuoteModel quoteModel;
  UserModel requestUser;
  String sourceAddress = '';
  String destinationAddress = '';
  bool isLoading = false;
  bool istruckLoading = true;
  TrukModel trukModel;
  DriverModel driverModel;
  final User user = FirebaseAuth.instance.currentUser;
  Locale locale;
  double totalWeight = 0.0;
  var x = 0.0;
  String spin;
  String dpin;
  List<TrukModel> trucks = [];

  List<TrukModel> trucksA = [];

  List<ShipmentModel> sModel = [];
  List<QuoteModel> qmodel = [];
  List<ShipmentModel> fsModel = [];
  List<QuoteModel> qSmodel = [];
  List<DriverModel> dm = [];
  List<DriverModel> driverAList = [];
  getPin() async {
    if (widget.keyTitle == 'assign') {
      CollectionReference driverRequest = FirebaseFirestore.instance
          .collection(FirebaseHelper.driverRegistered);
      CollectionReference driverCollectionRef = FirebaseFirestore.instance
          .collection(FirebaseHelper.driverCollection);
      CollectionReference shipmentCollectionRef =
          FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
      final driverSnapShot =
          driverCollectionRef.where('agent', isEqualTo: user.uid).snapshots();
      log("QuoteModal-->${widget.quoteModel}");
      print("truk: ${widget.quoteModel.truk}");
      //CollectionReference qqt = FirebaseFirestore.instance.collection(FirebaseHelper.quoteCollection);
      //final qShot = driver.where('bookingId', isEqualTo: widget.).snapshots();
      await shipmentCollectionRef
          .where('truk', isEqualTo: widget.quoteModel.truk)
          .get()
          .then(
        (value) async {
          for (var h in value.docs) {
            ShipmentModel sm = ShipmentModel.fromSnapshot(h);
            print("Hi");
            if (sm.status == RequestStatus.pending) {
              await FirebaseFirestore.instance
                  .collection(FirebaseHelper.driverCollection)
                  .doc(sm.driver)
                  .get()
                  .then((value) {
                DriverModel dmm = DriverModel.fromSnapshot(value);
                setState(() {
                  dm.add(dmm);
                  //istruckLoading=false;
                });

                print('DM is --> $dm');
              });
            }
          }
        },
      );
      // snapShot.listen((event) {
      //   for (QueryDocumentSnapshot d in event.docs) {
      //     DriverModel dd = DriverModel.fromSnapshot(d);
      //     driverA.where('driver', isEqualTo: dd.uid).get().then((value) {});
      //   }
      // });
      driverSnapShot.listen((event) {
        for (QueryDocumentSnapshot d in event.docs) {
          DriverModel dd = DriverModel.fromSnapshot(d);
          shipmentCollectionRef
              .where('driver', isEqualTo: dd.uid)
              .get()
              .then((value) {
            int c = 0;
            print("dlen:${value.docs.length}");
            if (value.docs.isEmpty) {
              c = 1;
            }
            for (var d in value.docs) {
              if (d.get('driver') != dd.uid) {
                c = 1;
              }
            }
            if (c == 1) {
              setState(() {
                driverAList.add(dd);
              });
            }
          });
        }
      });
    }
    for (MaterialModel m in widget.requestModel.materials) {
      setState(() {
        totalWeight += m.quantity;
      });
    }
    String ss = await Helper().getPin(widget.requestModel.source);
    String dd = await Helper().getPin(widget.requestModel.destination);
    setState(() {
      spin = ss;
      print(spin);
      dpin = dd;
      print(dpin);
    });
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
    CollectionReference sReference =
        FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
    CollectionReference qreference =
        FirebaseFirestore.instance.collection(FirebaseHelper.quoteCollection);
    final d = reference.where('ownerId', isEqualTo: user.uid).snapshots();
    final s = sReference.where('agent', isEqualTo: user.uid).snapshots();
    final q = qreference.where('agent', isEqualTo: user.uid).snapshots();
    d.listen((event) {
      for (DocumentSnapshot doc in event.docs) {
        TrukModel t = TrukModel.fromSnapshot(doc);
        if (t.available && int.parse(t.grossWeight) >= totalWeight) {
          setState(() {
            trucksA.add(t);
          });
        }
        if (!t.available) {
          sReference.where('truk', isEqualTo: t.trukNumber).get().then((value) {
            for (var f in value.docs) {
              if (f.get('status') == RequestStatus.started ||
                  f.get('status') == RequestStatus.pending) {
                break;
              } else {
                doc.reference.update({'available': true});
                setState(() {
                  trucksA.add(t);
                });
              }
            }
          });
        }
      }
    });
    s.listen((events) async {
      for (DocumentSnapshot docs in events.docs) {
        sModel.add(ShipmentModel.fromSnapshot(docs));
      }
      x = 0.0;
      for (ShipmentModel ship in sModel) {
        for (MaterialModel m in ship.materials) {
          x += m.quantity;
        }
      }
      for (ShipmentModel ship in sModel) {
        String a = await Helper().setLocationText(ship.source);
        String b = await Helper().setLocationText(ship.destination);
        print(a);
        print(b);
        print("$totalWeight");
        print(widget.requestModel.load.toString().toLowerCase());
        if (a.contains(spin) &&
            b.contains(dpin) &&
            widget.requestModel.load.toString().toLowerCase() ==
                "partialtruk") {
          fsModel.add(ship);
          print("s: $ship");
        }
      }
      for (ShipmentModel sh in fsModel) {
        int i = 0;
        await FirebaseFirestore.instance
            .collection(FirebaseHelper.trukCollection)
            .doc(sh.truk)
            .get()
            .then((value) {
          TrukModel tm = TrukModel.fromSnapshot(value);
          if ((double.parse(tm.grossWeight) - x) >= totalWeight) {
            for (TrukModel t in trucksA) {
              if (t.trukNumber == tm.trukNumber) {
                i = 1;
                break;
              }
            }
            if (i == 0) {
              setState(() {
                trucksA.add(tm);
              });
            }
          }
        });
      }
    });
    q.listen((events) async {
      print("in quotes");
      print(events.docs.length);
      for (DocumentSnapshot docs in events.docs) {
        qmodel.add(QuoteModel.fromSnapshot(docs));
      }
      x = 0.0;
      for (QuoteModel ship in qmodel) {
        for (MaterialModel m in ship.materials) {
          setState(() {
            x += m.quantity;
          });
        }
      }
      for (QuoteModel ship in qmodel) {
        String a = await Helper().setLocationText(ship.source);
        String b = await Helper().setLocationText(ship.destination);
        print(a);
        print(b);
        print("$totalWeight");
        print(x);
        print(widget.requestModel.load.toString().toLowerCase());
        if (a.contains(spin) &&
            b.contains(dpin) &&
            widget.requestModel.load.toString().toLowerCase() ==
                "partialtruk") {
          qSmodel.add(ship);
          print("hi: $ship");
        }
        print(a.contains(spin));
        print(b.contains(dpin));
      }
      for (QuoteModel sh in qSmodel) {
        int i = 0;
        await FirebaseFirestore.instance
            .collection(FirebaseHelper.trukCollection)
            .doc(sh.truk)
            .get()
            .then((value) {
          TrukModel tm = TrukModel.fromSnapshot(value);
          if ((double.parse(tm.grossWeight) - x) >= totalWeight) {
            for (TrukModel t in trucksA) {
              if (t.trukNumber == tm.trukNumber) {
                i = 1;
                print("Hi");
              }
            }
            if (i == 0) {
              setState(() {
                print("$tm");
                trucksA.add(tm);
              });
            }
          }
        });
      }
      setState(() {
        print(istruckLoading);
      });
      setTruckLoadingEvent();
    });
    print("Pppppppppppppppp");
    setState(() {
      trucks = trucksA;
      print("Loading done building UI");
      print(istruckLoading);
    });
  }

  @override
  void initState() {
    super.initState();
    requestModel = widget.requestModel;
    quoteModel = widget.quoteModel;
    requestUser = widget.requestUser;
    if (requestModel.status == RequestStatus.pending) {
      quoteModel = null;
    }
    Helper()
        .setLocationText(requestModel.source)
        .then((value) => setState(() => sourceAddress = value));
    Helper()
        .setLocationText(requestModel.destination)
        .then((value) => setState(() => destinationAddress = value));
    getPin();
    setState(() {
      print(istruckLoading);
    });
  }

  setTruckLoadingEvent() {
    setState(() {
      istruckLoading = false;
    });
    print("ist:$istruckLoading");
  }

  @override
  void dispose() {
    _priceController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  sendQuote() async {
    if (_formKey.currentState.validate()) {
      if (trukModel == null) {
        Fluttertoast.showToast(msg: 'Please select truk');
        return;
      }
      setState(() {
        isLoading = true;
      });
      LatLng s =
          LatLng(requestModel.source.latitude, requestModel.source.longitude);
      LatLng d = LatLng(requestModel.destination.latitude,
          requestModel.destination.longitude);
      double advance = 0.0;
      if (_advanceController.text.trim().isNotEmpty) {
        advance = double.parse(_advanceController.text);
      }
      QuoteModel qt = QuoteModel(
        agent: user.uid,
        bookingDate: requestModel.bookingDate,
        bookingId: requestModel.bookingId,
        destination: d,
        insured: requestModel.insured,
        load: requestModel.load,
        mandate: requestModel.mandate,
        materials: requestModel.materials,
        mobile: requestModel.mobile,
        pickupDate: requestModel.pickupDate,
        price: _priceController.text.trim(),
        source: s,
        status: RequestStatus.quoted,
        truk: trukModel.trukNumber,
        trukName: trukModel.trukName,
        uid: requestModel.uid,
        advance: advance,
      );
      //print(advance);
      await RequestController().addQuote(qt, requestModel);
      await FirebaseFirestore.instance
          .collection(FirebaseHelper.trukCollection)
          .where('trukNumber', isEqualTo: trukModel.trukNumber)
          .get()
          .then((value) {
        for (var d in value.docs) {
          d.reference.update({'available': false});
        }
      });
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Quote Sent');
      Navigator.pop(context);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final EdgeInsetsGeometry padding =
        EdgeInsets.only(left: 16, right: 16, top: 20);
    final TextStyle style =
        TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    final pDrivers = Provider.of<AvailableDrivers>(context);
    locale = AppLocalizations.of(context).locale;
    print("ppp:: ${driverAList.length}");
    print("dd:: $dm");
    return Form(
      key: _formKey,
      child: LoadingOverlay(
        isLoading: isLoading,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text('${requestUser.name}'),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              height: 60,
              width: size.width,
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: primaryColor,
                ),
                onPressed: () async {
                  if (quoteModel == null) {
                    await sendQuote();
                  } else {
                    if (driverModel == null) {
                      Fluttertoast.showToast(
                          msg: AppLocalizations.getLocalizationValue(
                              locale, LocaleKey.selectDriver));
                      return;
                    }
                    Fluttertoast.showToast(msg: "Please select EWay-Bill");
                    FilePickerResult result = await FilePicker.platform
                        .pickFiles(
                            type: FileType.custom, allowedExtensions: ['pdf']);
                    if (result == null) {
                      Fluttertoast.showToast(msg: "Please select EWay-Bill");
                      return;
                    }
                    File ff = File(result.files.single.path);
                    if (ff == null) {
                      Fluttertoast.showToast(msg: "Please select EWay-Bill");
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });

                    await RequestController().assignDriver(
                        quoteModel, driverModel.uid,
                        eWayBill: ff);
                    setState(() {
                      isLoading = false;
                    });
                    Fluttertoast.showToast(
                        msg: AppLocalizations.getLocalizationValue(
                            locale, LocaleKey.driverAssigned));
                    Navigator.pop(context);
                    Email().sendDriverAssignedMail(
                        driverModel, context, user.email, quoteModel);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  AppLocalizations.getLocalizationValue(
                      locale,
                      quoteModel == null
                          ? LocaleKey.sendQuote
                          : LocaleKey.assignDriver),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          body: istruckLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: primaryColor,
                ))
              : Container(
                  child: ListView(
                    children: [
                      Container(
                        padding: padding,
                        child: Text(
                            AppLocalizations.getLocalizationValue(
                                locale, LocaleKey.shipmentDetails),
                            style: style),
                      ),
                      buildMaterialContainer(size),
                      buildTypes(size),
                      Container(
                        padding: padding,
                        child: Text(
                            AppLocalizations.getLocalizationValue(
                                locale, LocaleKey.pickupLocation),
                            style: style),
                      ),
                      createLocationBlock(size, 0),
                      Container(
                        padding: padding,
                        child: Text(
                            AppLocalizations.getLocalizationValue(
                                locale, LocaleKey.dropLocation),
                            style: style),
                      ),
                      createLocationBlock(size, 1),
                      SizedBox(
                        height: 20,
                      ),
                      if (widget.keyTitle == 'quote')
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            child: Text(
                              AppLocalizations.getLocalizationValue(
                                  locale,
                                  requestModel.insured
                                      ? LocaleKey.withInsurance
                                      : LocaleKey.withOutInsurance),
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ),
                      if (widget.keyTitle == 'quote')
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: trucksA.length == 0
                              ? Container(
                                  width: size.width * 0.4,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.getLocalizationValue(
                                        locale,
                                        LocaleKey.addTruk,
                                      ),
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => AddTruck(),
                                        ),
                                      ).then((value) {
                                        CollectionReference reference =
                                        FirebaseFirestore.instance.collection(FirebaseHelper.trukCollection);
                                        CollectionReference sReference =
                                        FirebaseFirestore.instance.collection(FirebaseHelper.shipment);
                                        final d = reference.where('ownerId', isEqualTo: user.uid).snapshots();
                                        d.listen((event) {
                                          for (DocumentSnapshot doc in event.docs) {
                                            TrukModel t = TrukModel.fromSnapshot(doc);
                                            if (t.available && int.parse(t.grossWeight) >= totalWeight) {
                                                trucksA.add(t);
                                            }
                                            if (!t.available) {
                                              sReference.where('truk', isEqualTo: t.trukNumber).get().then((value) {
                                                for (var f in value.docs) {
                                                  if (f.get('status') == RequestStatus.started ||
                                                      f.get('status') == RequestStatus.pending) {
                                                    break;
                                                  } else {
                                                    doc.reference.update({'available': true});
                                                      trucksA.add(t);
                                                  }
                                                }
                                              });
                                            }
                                          }
                                        });                                      });
                                    },
                                  ),
                                )
                              : DropdownButtonFormField<TrukModel>(
                                  onChanged: (value) {
                                    print(value);
                                    setState(() {
                                      trukModel = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return AppLocalizations
                                          .getLocalizationValue(
                                              locale, LocaleKey.selectTrukType);
                                    }
                                    return null;
                                  },
                                  hint: Text(
                                      AppLocalizations.getLocalizationValue(
                                          locale, LocaleKey.selectTrukType)),
                                  isExpanded: true,
                                  items: trucksA
                                      .map(
                                        (e) => DropdownMenuItem<TrukModel>(
                                          value: e,
                                          child: Text(
                                              "${e.trukNumber} - ${AppLocalizations.getLocalizationValue(locale, e.trukType.toLowerCase().contains('closed') ? LocaleKey.closedTruk : LocaleKey.openTruk)}"),
                                        ),
                                      )
                                      .toList(),
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder()),
                                ),
                        ),
                      if (quoteModel == null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: TextFormField(
                            validator: (String value) {
                              if (value.trim().isEmpty ||
                                  int.parse(value) <= 0) {
                                return AppLocalizations.getLocalizationValue(
                                    locale, LocaleKey.requiredText);
                              }
                              return null;
                            },
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '₹ Price'),
                          ),
                        ),
                      if (quoteModel == null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: TextFormField(
                            controller: _advanceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Advance Price(if any)'),
                          ),
                        ),
                      if (quoteModel != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Text(
                            "${AppLocalizations.getLocalizationValue(locale, widget.quoteModel.paymentStatus)} - \u20B9${widget.quoteModel.price}",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: const Color(0xff76b448),
                              fontWeight: FontWeight.w500,
                              height: 2.142857142857143,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      if (quoteModel != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Text(
                            "Advance - \u20B9${widget.quoteModel.advance}",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: const Color(0xff76b448),
                              fontWeight: FontWeight.w500,
                              height: 2.142857142857143,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      if (quoteModel != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: const Color(0xfff8f8f8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${quoteModel.trukName} - ${quoteModel.truk}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      //if(quoteModel != null)
                      if (quoteModel != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: driverAList.isEmpty && dm.isEmpty
                              ? Container(
                                  width: size.width * 0.4,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.getLocalizationValue(
                                          locale, LocaleKey.addDriver),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => DriverDetails(),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : DropdownButtonFormField<DriverModel>(
                                  onChanged: (value) {
                                    setState(() {
                                      driverModel = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return AppLocalizations
                                          .getLocalizationValue(
                                              locale, LocaleKey.selectDriver);
                                    }
                                    return null;
                                  },
                                  isExpanded: true,
                                  hint: Text(
                                      AppLocalizations.getLocalizationValue(
                                          locale, LocaleKey.assignDriver)),
                                  items: dm.isEmpty
                                      ? driverAList
                                          .toSet()
                                          .toList()
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                '${e.driverId} - ${e.name}',
                                              ),
                                            ),
                                          )
                                          .toList()
                                      : dm
                                          .toSet()
                                          .toList()
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                '${e.driverId} - ${e.name}',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildMaterialContainer(Size size) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xfff8f8f8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: requestModel.materials.length,
        itemBuilder: (context, index) {
          MaterialModel m = requestModel.materials[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '${index + 1}. ',
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Text(
                    '${m.materialName}',
                    style: TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '${m.quantity} KG',
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTypes(Size size) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xfff8f8f8),
      ),
      child: Column(
        children: [
          createTypes(
              AppLocalizations.getLocalizationValue(
                  this.locale, LocaleKey.mandateType),
              AppLocalizations.getLocalizationValue(
                  this.locale,
                  widget.requestModel.mandate.toLowerCase().contains('ondemand')
                      ? LocaleKey.onDemand
                      : LocaleKey.lease)),
          SizedBox(
            height: 10,
          ),
          createTypes(
              AppLocalizations.getLocalizationValue(
                  this.locale, LocaleKey.loadType),
              AppLocalizations.getLocalizationValue(
                  this.locale,
                  widget.requestModel.load.toLowerCase().contains('partial')
                      ? LocaleKey.partialTruk
                      : LocaleKey.fullTruk)),
          SizedBox(
            height: 10,
          ),
          createTypes(
              AppLocalizations.getLocalizationValue(
                  this.locale, LocaleKey.trukType),
              AppLocalizations.getLocalizationValue(
                  this.locale,
                  widget.requestModel.truk.toLowerCase().contains('closed')
                      ? LocaleKey.closedTruk
                      : LocaleKey.openTruk)),
        ],
      ),
    );
  }

  Widget createTypes(String heading, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$heading',
            style: TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          '$value',
          style: TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget createLocationBlock(Size size, int type) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xfff8f8f8),
      ),
      child: Text(
        type == 0 ? sourceAddress : destinationAddress,
      ),
    );
  }
}
