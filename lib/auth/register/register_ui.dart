import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:truk_fleet/auth/register/register_interface.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/driver_register_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/screens/tcPage.dart';
import '../../utils/constants.dart';
import '../../helper/email_validator.dart';

class RegisterUI extends StatefulWidget {
  final RegisterInterface registerInterface;
  final String type;

  const RegisterUI({Key key, this.registerInterface, this.type})
      : super(key: key);

  @override
  _RegisterUIState createState() => _RegisterUIState();
}

class _RegisterUIState extends State<RegisterUI> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;
  bool isTC = false;
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return primaryColor;
    }
    return primaryColor;
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  DriverRegisterModel driverRegisterModel;
  Locale locale;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (widget.type == LoginType.driver) {
      FirebaseFirestore.instance
          .collection(FirebaseHelper.driverRegistered)
          .where('mobile', isEqualTo: user.phoneNumber.substring(3))
          .snapshots()
          .first
          .then((value) {
        setState(() {
          isLoading = false;
          driverRegisterModel = DriverRegisterModel.fromSnapshot(value.docs[0]);
          _nameController.text = driverRegisterModel.name;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          height: 65,
          width: width,
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: primaryColor,
            ),
            onPressed: !isTC
                ? null
                : isLoading
                    ? () {}
                    : () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          if (user != null && isTC) {
                            String uid = user.uid;
                            String mobile = user.phoneNumber;
                            String email = _emailController.text.trim();
                            String name = _nameController.text.trim();
                            String city = _cityController.text.trim();
                            String state = _stateController.text.trim();
                            String company = _companyNameController.text.trim();
                            if (widget.type == LoginType.company) {
                              String upi = _upiController.text.trim();
                              UserModel userModel = UserModel(
                                  city: city,
                                  upiId: upi,
                                  company: company,
                                  email: email,
                                  joining:
                                      DateTime.now().millisecondsSinceEpoch,
                                  mobile: mobile,
                                  name: name,
                                  state: state,
                                  token: 'na',
                                  uid: uid,
                                  notification: false);
                              widget.registerInterface.registerAgent(userModel);
                            } else {
                              String trukId = Helper.generateTrukId();
                              DriverModel driverModel = DriverModel(
                                  city: city,
                                  agent: driverRegisterModel.agent,
                                  company: company,
                                  email: email,
                                  driverId: trukId,
                                  joining:
                                      DateTime.now().millisecondsSinceEpoch,
                                  mobile: mobile,
                                  name: name,
                                  state: state,
                                  token: 'na',
                                  uid: uid,
                                  notification: true,
                                  image: 'na');
                              widget.registerInterface
                                  .registerDriver(driverModel);
                            }
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            if (user == null) {
                              Fluttertoast.showToast(
                                  msg: 'Please fill all the fields');
                            } else if (!isTC) {
                              setState(() {
                                isLoading = false;
                              });
                              Fluttertoast.showToast(
                                  msg: 'Please Accept terms and conditions');
                            }
                            // Navigator.pushNamed(context, LoginRoutes.loginRoot, arguments: widget.type);
                          }
                        }
                      },
            child: isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    AppLocalizations.getLocalizationValue(
                        locale, LocaleKey.continueText),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.15,
                  ),
                  Text(
                    AppLocalizations.getLocalizationValue(
                        locale, LocaleKey.registerTitle),
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.getLocalizationValue(
                            locale, LocaleKey.requiredText);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.name),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _emailController,
                    validator: (input) => input.isValidEmail()
                        ? null
                        : AppLocalizations.getLocalizationValue(
                            locale, LocaleKey.invalidEmail),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (widget.type == LoginType.company)
                    TextFormField(
                      controller: _upiController,
                      validator: (input) => input.isEmpty
                          ? AppLocalizations.getLocalizationValue(
                              locale, LocaleKey.requiredText)
                          : null,
                      decoration: InputDecoration(
                        labelText: "UPI",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (widget.type == LoginType.company)
                    SizedBox(
                      height: 15,
                    ),
                  TextFormField(
                    controller: _companyNameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.getLocalizationValue(
                            locale, LocaleKey.requiredText);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.company),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _cityController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.getLocalizationValue(
                            locale, LocaleKey.requiredText);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.city),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.getLocalizationValue(
                            locale, LocaleKey.requiredText);
                      }
                      return null;
                    },
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.state),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    child: Row(
                      children: [
                        Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: isTC,
                            onChanged: (bool value) {
                              setState(() {
                                isTC = value;
                              });
                            }),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${AppLocalizations.getLocalizationValue(locale, LocaleKey.accept)} ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text:
                                      "${AppLocalizations.getLocalizationValue(locale, LocaleKey.insuranceText2)}",
                                  style: TextStyle(
                                      color: primaryColor,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => TCPage(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
