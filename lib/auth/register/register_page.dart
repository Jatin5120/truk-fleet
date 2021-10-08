import 'package:flutter/material.dart';
import 'package:truk_fleet/Routes/routes.dart';
import 'package:truk_fleet/auth/register/register_interface.dart';
import 'package:truk_fleet/auth/register/register_ui.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/models/user_model.dart';

class RegisterPage extends StatefulWidget {
  final String type;

  const RegisterPage(this.type);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> implements RegisterInterface {
  @override
  Widget build(BuildContext context) {
    return RegisterUI(
      registerInterface: this,
      type: widget.type,
    );
  }

  @override
  void registerUser(DriverModel driverModel) async {
    // if (widget.type == LoginType.driver) {
    //   this.registerAgent(model)
    // }
  }

  @override
  void registerAgent(UserModel model) async {
    String homeRoute = PageRoutes.companyHome;
    await FirebaseHelper().insertAgent(model, widget.type);
    Navigator.pushNamedAndRemoveUntil(context, homeRoute, (route) => false);
  }

  @override
  Future<void> registerDriver(DriverModel model) async {
    String homeRoute = PageRoutes.driverHome;
    await FirebaseHelper().insertUser(model, widget.type);
    Navigator.pushNamedAndRemoveUntil(context, homeRoute, (route) => false);
  }
}
