import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SharedPref {
  SharedPreferences pref;

  static const THEME_STATUS = "THEMESTATUS";

  //driverOnline
  static const String IS_ONLINE = "isonline";

  //location
  static const String STREET = "street";
  static const String PIN = "pincode";
  static const String AREA = "area";
  static const String CITY = "city";
  static const String STATE = "state";
  static const String LATLNG = "latlng";
  static const String LOC = "islocation";

  //login
  static const String KEY_EMAIL = "email";
  static const String KEY_NAME = "name";
  static const String KEY_MOBILE = "mobile";
  static const String KEY_THEME = "theme";
  static const String KEY_ISLOGIN = "islogin";
  static const String KEY_UID = "uid";
  static const String KEY_TYPE = 'login_type';

  //localization
  static const String KEY_LANG = "lang";
  static const Locale en = Locale('en', 'US');
  static const Locale hi = Locale('hi', 'IN');
  static const Locale te = Locale('te', 'IN');

  Future<bool> setOnlineStatus(bool status) async {
    pref = await SharedPreferences.getInstance();
    return pref.setBool(IS_ONLINE, status ?? false) ?? false;
  }

  Future<bool> isOnline() async {
    pref = await SharedPreferences.getInstance();
    return pref.getBool(IS_ONLINE) ?? true;
  }

  Future<bool> isOld() async {
    pref = await SharedPreferences.getInstance();
    return pref.getBool("isold") ?? false;
  }

  Future<bool> setOld() async {
    pref = await SharedPreferences.getInstance();
    return pref.setBool("isold", true) ?? false;
  }

  setDarkTheme(bool value) async {
    pref = await SharedPreferences.getInstance();
    pref.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    pref = await SharedPreferences.getInstance();
    return pref.getBool(THEME_STATUS) ?? false;
  }

  Future<String> getLoginType() async {
    pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_TYPE);
  }

  createSession(uid, name, email, mobile, type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(SharedPref.KEY_UID, uid);
    pref.setString(SharedPref.KEY_NAME, name);
    pref.setString(SharedPref.KEY_EMAIL, email);
    pref.setString(SharedPref.KEY_MOBILE, mobile);
    pref.setString(KEY_TYPE, type);
    pref.setBool(SharedPref.KEY_ISLOGIN, true);
  }

  logoutUser() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(SharedPref.KEY_ISLOGIN, false);
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.get(SharedPref.KEY_ISLOGIN) ?? false;
  }

  Future<void> createLocationData(double lat, double lng, {bool isAllowed = false}) async {
    bool b = await isLocation();
    if (!b || isAllowed) {
      String street, area, pincode, city, state;
      final coordinates = Coordinates(lat, lng);
      var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      street = address.first.featureName;
      area = address.first.subLocality;
      pincode = address.first.postalCode;
      city = address.first.subAdminArea;
      state = address.first.adminArea;
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString(SharedPref.STREET, street);
      await pref.setString(SharedPref.STATE, state);
      await pref.setString(SharedPref.CITY, city);
      await pref.setString(SharedPref.AREA, area);
      await pref.setString(SharedPref.PIN, pincode);
      await pref.setBool(SharedPref.LOC, true);
      await pref.setString(SharedPref.LATLNG, "$lat,$lng");
    }
  }

  Future<bool> isLocation() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.get(SharedPref.LOC) ?? false;
  }

//setLocale
  Future<void> setLocale(String locale) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(KEY_LANG, locale);
  }

  //getLocale
  Future<Locale> getLocale() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String localeString = pref.getString(KEY_LANG) ?? 'en';
    Locale locale = en;
    switch (localeString) {
      case 'en':
        locale = en;
        break;
      case 'hi':
        locale = hi;
        break;
      case 'te':
        locale = te;
        break;
    }
    return locale;
  }
  // Future<bool> logout() async {
  //   FirebaseAuth.instance.signOut();
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   return await pref.clear();
  // }
}
