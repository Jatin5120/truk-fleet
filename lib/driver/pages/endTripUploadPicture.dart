import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:truk_fleet/driver/controller/start_ride_document.dart';
import 'package:truk_fleet/driver/pages/driver_homepage.dart';
import 'package:truk_fleet/driver/pages/final_payment_screen.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/shipment_model.dart';

import 'package:truk_fleet/utils/constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UploadEndTrip extends StatefulWidget {
  final ShipmentModel model;
  UploadEndTrip({this.model});
  @override
  _UploadEndTripState createState() => _UploadEndTripState();
}

class _UploadEndTripState extends State<UploadEndTrip> {
  List<File> images = [null, null, null, null];
  bool isLoading = false;
  Locale locale;
  Future<void> getImage(ImageSource source, int index) async {
    var image = await ImagePicker().getImage(source: source);
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
                ? (images[index] != null ? Image.file(images[index],fit: BoxFit.fill,) : dummyText)
                : dummyText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
          child: Container(
            height: 65,
            width: size.width,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: primaryColor,
              onPressed: () async {
                if (images.any((element) => element == null)) {
                  Fluttertoast.showToast(msg: 'Please select all images');
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                //print(images.length);
                await StartRideDocument().uploadImages(images: images, model: widget.model, isEnd: true);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinalPaymentScreen(model: widget.model),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                AppLocalizations.getLocalizationValue(locale, LocaleKey.endTrip),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.0, mainAxisSpacing: 28, crossAxisSpacing: 28),
            children: [
              pickImage(
                title: '${AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupImage)} 1',
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
                title: '${AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupImage)} 2',
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
                title: AppLocalizations.getLocalizationValue(locale, LocaleKey.trukImage),
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
                title: AppLocalizations.getLocalizationValue(locale, LocaleKey.selfie),
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
