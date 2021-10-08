import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/auth/register/register_page.dart';
import 'package:truk_fleet/company/pages/company_home.dart';
import 'package:truk_fleet/driver/pages/driver_homepage.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
import '../argument_class.dart';
import 'otp_interface.dart';
import 'otp_screen.dart';

class OtpPage extends StatefulWidget {
  final OtpArguments args;
  final Function(User user) otpCallBack;
  OtpPage({this.args, this.otpCallBack(user)});
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> implements OtpInterface {
  @override
  Widget build(BuildContext context) {
    return OTP(
      args: widget.args,
      otpInterface: this,
    );
  }

  @override
  void matchOtp(User user) async {
    UserModel userModel = await FirebaseHelper().getCurrentUser(uid: user.uid, type: widget.args.type);

    if (userModel == null) {
      //new user
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPage(widget.args.type),
          ));
    } else {
      //existing user
      Widget screen = widget.args.type == LoginType.driver ? DriverHomeScreen() : CompanyHome();
      await SharedPref()
          .createSession(userModel.uid, userModel.name, userModel.email, userModel.mobile, widget.args.type);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => screen,
          ),
          (route) => false);
    }
  }
}
