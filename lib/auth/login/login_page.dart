import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:truk_fleet/auth/argument_class.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'login_interface.dart';
import 'login_ui.dart';
import '../verification/otp_page.dart';

class LoginPage extends StatefulWidget {
  final String type;
  LoginPage(this.type);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements LoginInterface {
  Locale locale;

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return LoginUI(this);
  }

  @override
  Future<void> loginWithMobile(String mobileNumber) async {
    if (widget.type == LoginType.driver) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(FirebaseHelper.driverRegistered)
          .where('mobile', isEqualTo: mobileNumber)
          .snapshots()
          .first;
      if (snapshot.size <= 0) {
        Fluttertoast.showToast(msg: AppLocalizations.getLocalizationValue(locale, LocaleKey.notRegistered));
        return;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpPage(
          args: OtpArguments(mobileNumber: '+91$mobileNumber', type: widget.type),
        ),
      ),
    );
  }
}
