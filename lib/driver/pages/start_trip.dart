import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:truk_fleet/driver/controller/start_ride_document.dart';
import 'package:truk_fleet/helper/emailHelper.dart';
import 'package:truk_fleet/helper/payment_type.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/dialog_file.dart';

class UploadStartTrip extends StatefulWidget {
  final ShipmentModel model;
  UploadStartTrip({this.model});
  @override
  _UploadStartTripState createState() => _UploadStartTripState();
}

class _UploadStartTripState extends State<UploadStartTrip> {
  List<File> images = [null, null, null, null];
  bool isLoading = false;
  Locale locale;
  Future<void> getImage(ImageSource source, int index) async {
    var image = await ImagePicker().pickImage(source: source);
    if (image != null && mounted) {
      setState(() {
        File f = File(image.path);
        images.removeAt(index);
        images.insert(index, f);
      });
    }
  }

  Widget pickImage({String title, void Function() onTap, int index}) {
    var dummyText = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          color: primaryColor,
          size: 30,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          '$title',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        )
      ],
    );
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        radius: Radius.circular(5),
        borderType: BorderType.Rect,
        dashPattern: [5],
        color: Color(0xffBFBFBF),
        strokeWidth: 1,
        child: Container(
          child: Center(
            child: images.length >= index + 1
                ? (images[index] != null
                    ? Image.file(images[index])
                    : dummyText)
                : dummyText,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    isLoading = true;
    Future<QuerySnapshot> re = FirebaseFirestore.instance
        .collection("Quote")
        .where('bookingId', isEqualTo: widget.model.bookingId)
        .get();
    re.then((value) {
      print(value.docs.length);
      if (value.docs.length > 0) {
        setState(() {
          isLoading = false;
        });
        QuoteModel quoteModel = QuoteModel.fromSnapshot(value.docs[0]);
        if (quoteModel.advance > 0.0 &&
            widget.model.paymentStatus == PaymentType.cod &&
            widget.model.amountPaid == null) {
          paymentSuccessful(
            context: context,
            isPayment: true,
            payment: quoteModel.advance.toString(),
            shipmentId: quoteModel.bookingId.toString(),
            onTap: () {
              Fluttertoast.showToast(msg: "Please Collect Advance");
              Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppLocalizations.getLocalizationValue(locale, LocaleKey.upload),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 65,
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      primary: Colors.lightBlue,
                    ),
                    onPressed: () async {
                      final cord = Coords(widget.model.source.latitude,
                          widget.model.source.longitude);
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
                      );
                    },
                    child: Center(
                      child: Text(
                        AppLocalizations.getLocalizationValue(
                            locale, LocaleKey.navigateToPickup),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 65,
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    primary: primaryColor,
                  ),
                  onPressed: () async {
                    if (images.any((element) => element == null)) {
                      Fluttertoast.showToast(msg: 'Please select all images');
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });
                    //print(images.length);
                    await StartRideDocument()
                        .uploadImages(images: images, model: widget.model);
                    setState(() {
                      isLoading = true;
                    });
                    Email().sendShipmentStartMail(widget.model, context);
                  },
                  child: Text(
                    AppLocalizations.getLocalizationValue(
                        locale, LocaleKey.startTrip),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 28,
                crossAxisSpacing: 28),
            children: [
              pickImage(
                title:
                    '${AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupImage)} 1',
                onTap: () async {
                  await getImage(ImageSource.camera, 0);
                  // Platform.isAndroid
                  //     ? showDialog(
                  //         context: context,
                  //         child: CustomImageChooser.makeImageChooser(
                  //           context,
                  //           0,
                  //           (source) async {
                  //             await getImage(source, 0);
                  //           },
                  //         ),
                  //       )
                  //     : showCupertinoDialog(
                  //         context: context,
                  //         builder: (context) => Material(
                  //           color: Colors.transparent,
                  //           child: CustomImageChooser.makeImageChooser(
                  //             context,
                  //             0,
                  //             (source) async {
                  //               await getImage(source, 0);
                  //             },
                  //           ),
                  //         ),
                  //       );
                },
                index: 0,
              ),
              pickImage(
                title:
                    '${AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupImage)} 2',
                index: 1,
                onTap: () async {
                  await getImage(ImageSource.camera, 1);
                  // Platform.isAndroid
                  //     ? showDialog(
                  //         context: context,
                  //         child: CustomImageChooser.makeImageChooser(
                  //           context,
                  //           0,
                  //           (source) async {
                  //             await getImage(source, 1);
                  //           },
                  //         ),
                  //       )
                  //     : showCupertinoDialog(
                  //         context: context,
                  //         builder: (context) => Material(
                  //           color: Colors.transparent,
                  //           child: CustomImageChooser.makeImageChooser(
                  //             context,
                  //             0,
                  //             (source) async {
                  //               await getImage(source, 1);
                  //             },
                  //           ),
                  //         ),
                  //       );
                },
              ),
              pickImage(
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.trukImage),
                index: 2,
                onTap: () async {
                  await getImage(ImageSource.camera, 2);
                  // Platform.isAndroid
                  //     ? showDialog(
                  //         context: context,
                  //         child: CustomImageChooser.makeImageChooser(
                  //           context,
                  //           0,
                  //           (source) async {
                  //             await getImage(source, 2);
                  //           },
                  //         ),
                  //       )
                  //     : showCupertinoDialog(
                  //         context: context,
                  //         builder: (context) => Material(
                  //           color: Colors.transparent,
                  //           child: CustomImageChooser.makeImageChooser(
                  //             context,
                  //             0,
                  //             (source) async {
                  //               await getImage(source, 2);
                  //             },
                  //           ),
                  //         ),
                  //       );
                },
              ),
              pickImage(
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.selfie),
                index: 3,
                onTap: () async {
                  await getImage(ImageSource.camera, 3);
                  // Platform.isAndroid
                  //     ? showDialog(
                  //         context: context,
                  //         child: CustomImageChooser.makeImageChooser(
                  //           context,
                  //           0,
                  //           (source) async {
                  //             await getImage(source, 3);
                  //           },
                  //         ),
                  //       )
                  //     : showCupertinoDialog(
                  //         context: context,
                  //         builder: (context) => Material(
                  //           color: Colors.transparent,
                  //           child: CustomImageChooser.makeImageChooser(
                  //             context,
                  //             0,
                  //             (source) async {
                  //               await getImage(source, 3);
                  //             },
                  //           ),
                  //         ),
                  //       );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
