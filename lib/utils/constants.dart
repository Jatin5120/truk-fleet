import 'package:flutter/material.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:intl/intl.dart';

class Utils {
  static formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';
  static formatDate(DateTime date) => DateFormat.yMd().format(date);
}

final Color primaryColor = Color(0xffFF7101);
final Color secondaryColor = Color(0xffFFE8D7);
final String testApiKey = 'rzp_test_mJh9QWD7lZ8ToY';
final Color greenButtonColor = Color(0xff499B0B);
const kGoogleApiKey = "AIzaSyD2i2ei-OODxzCSPvki5CaqxAtbKCJXlsM";

List<String> materialTypes = [
  "Auto parts",
  "Bardana jute or plastic",
  "Building material",
  "Cement",
  "Chemicals",
  "Coal and ash",
  "Container",
  "Cotton seed",
  "Electronic consumer durables",
  "Fertilizer",
  "Fruits & vegetables",
  "Furniture & wood products",
  "Household goods",
  "Industrial equipment",
  "Iron sheets or bars or scraps",
  "Liquids in drums",
  "Liquids/Oil",
  "Machinery new or old",
  "Medicals",
  "Metals",
  "Mill jute oil",
  "Packed food",
  "Plastic pipes",
  "Powder bags",
  "Printed books or paper rolls",
  "Refrigerated goods",
  "Rice or wheat or agricultural products",
  "Scrap",
  "Spices",
  "Textiles",
  "Tires or rubber products",
  "Vehicles or car",
  "Others",
];

class Constants {
  final Locale locale;
  Constants(this.locale);

  List<Map<String, dynamic>> get walkthroughList => [
        {
          'title': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.walkThroughTitle1),
          'subtitle': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.walkThroughSubTitle1),
          'image': AssetImage('assets/images/walk_1.png')
        },
        {
          'title': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.walkThroughTitle2),
          'subtitle': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.walkThroughSubTitle2),
          'image': AssetImage('assets/images/walk_2.png')
        },
        {
          'title': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.walkThroughTitle3),
          'subtitle': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.walkThroughSubTitle3),
          'image': AssetImage('assets/images/walk_3.png')
        },
      ];
  List<Map<String, String>> get mandateType => [
        {
          'key': LocaleKey.onDemand,
          'value': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.onDemand)
        },
        // {'key': LocaleKey.lease, 'value': AppLocalizations.getLocalizationValue(this.locale, LocaleKey.lease)},
      ];
  List<Map<String, String>> get loadType => [
        {
          'key': LocaleKey.partialLoad,
          'value': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.partialLoad)
        },
        {
          'key': LocaleKey.fullLoad,
          'value': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.fullLoad)
        }
      ];
  List<Map<String, String>> get trukType => [
        {
          'key': LocaleKey.openTruk,
          'value': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.openTruk)
        },
        {
          'key': LocaleKey.closedTruk,
          'value': AppLocalizations.getLocalizationValue(
              this.locale, LocaleKey.closedTruk)
        }
      ];
}
