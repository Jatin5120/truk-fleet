import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'date_extension.dart';

class Helper {
  Future<String> setLocationText(LatLng value) async {
    LatLng latLng = value;
    final coordinates = Coordinates(latLng.latitude, latLng.longitude);
    try {
      var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      String street = address.first.featureName;
      String area = address.first.subLocality;
      String pincode = address.first.postalCode;
      String city = address.first.subAdminArea;
      String state = address.first.adminArea;
      return '$street, $area, $city, $state, $pincode';
    } catch (e) {
      return 'Error';
    }
  }

  Future<String> getPin(LatLng value) async {
    LatLng latLng = value;
    final coordinates = Coordinates(latLng.latitude, latLng.longitude);
    try {
      var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      String street = address.first.featureName;
      String area = address.first.subLocality;
      String pincode = address.first.postalCode;
      String city = address.first.subAdminArea;
      String state = address.first.adminArea;
      return '$pincode';
    } catch (e) {
      return 'Error';
    }
  }

  static LatLng stringToLatlng(String coordindates) {
    List<String> splitted = coordindates.split(',');
    return LatLng(double.parse(splitted[0]), double.parse(splitted[1]));
  }

  String getFormattedDate(int milliseconds) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    bool isToday = date.isSameDate(DateTime.now());
    DateFormat formatter = DateFormat(isToday ? "hh:mm a" : "dd MMM, yy hh:mm a");
    return formatter.format(date);
  }

  static String generateTrukId() {
    String s = '';
    Random random = Random();
    for (var i = 0; i < 6; i++) {
      s += random.nextInt(10).toString();
    }
    return 'TruK$s';
  }

  void showConfirmationDialog({BuildContext context, String title, String subTitle, Function onTap}) {
    final locale = AppLocalizations.of(context).locale;
    Platform.isAndroid
        ? showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('$title'),
              content: Text('$subTitle'),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onTap();
                  },
                  child: Center(
                    child: Text(
                      AppLocalizations.getLocalizationValue(locale, LocaleKey.yes),
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                RaisedButton(
                  color: primaryColor,
                  onPressed: () => Navigator.pop(context),
                  child: Center(
                    child: Text(
                      AppLocalizations.getLocalizationValue(locale, LocaleKey.no),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        : showCupertinoDialog(
            context: context,
            builder: (context) => Material(
              color: Colors.transparent,
              child: CupertinoAlertDialog(
                title: Text('$title'),
                content: Text('$subTitle'),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onTap();
                    },
                    child: Center(
                      child: Text(
                        AppLocalizations.getLocalizationValue(locale, LocaleKey.yes),
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        AppLocalizations.getLocalizationValue(locale, LocaleKey.no),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
