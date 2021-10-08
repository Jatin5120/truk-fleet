import 'package:flutter/cupertino.dart';
import 'package:truk_fleet/auth/login/login_interface.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import '../../utils/constants.dart';

class LoginUI extends StatefulWidget {
  final LoginInterface loginInterface;
  LoginUI(this.loginInterface);
  @override
  LoginUIState createState() => LoginUIState();
}

class LoginUIState extends State<LoginUI> {
  final TextEditingController _mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  Locale locale;
  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider image = AssetImage('assets/images/india.png');
    final size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Container(
            height: size.height,
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  height: 60,
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.15,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    AppLocalizations.getLocalizationValue(locale, LocaleKey.enterMobile),
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 15),
                  child: TextFormField(
                    autofocus: false,
                    validator: (st) {
                      if (st.isEmpty) {
                        return AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText);
                      }
                      if (st.trim().length < 10) {
                        return '*Invalid mobile number';
                      }
                      return null;
                    },
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    controller: _mobileController,
                    decoration: InputDecoration(
                      prefixIcon: Image(
                        height: 18,
                        image: image,
                      ),
                      counterText: "",
                      labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.mobile),
                      hintText: 'e.g., 1234567890',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 65,
                  width: size.width,
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: RaisedButton(
                    color: primaryColor,
                    onPressed: isLoading
                        ? () {}
                        : () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              await widget.loginInterface.loginWithMobile(_mobileController.text.trim());
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.getLocalizationValue(locale, LocaleKey.generateOtp),
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
}
