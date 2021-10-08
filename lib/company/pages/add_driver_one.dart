import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:truk_fleet/company/controller/add_driver_controller.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/driver_register_model.dart';
import 'package:truk_fleet/utils/constants.dart';

class DriverDetails extends StatefulWidget {
  @override
  _DriverDetailsState createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final User user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _adhaarController = TextEditingController();
  final _dlController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  Locale locale;

  Widget detailTextField({String labelText, bool enable=true,TextEditingController controller, String Function(String) validator}) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        enabled: enable,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(labelText: labelText, border: OutlineInputBorder()),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseExpiryController.dispose();
    _dlController.dispose();
    _adhaarController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.driverDetails)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 20, left: 20),
                        child: Text(
                          AppLocalizations.getLocalizationValue(locale, LocaleKey.registerDriver),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      detailTextField(
                        labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.name),
                        controller: _nameController,
                        validator: (value) => value.isEmpty
                            ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText)
                            : null,
                      ),
                      detailTextField(
                        labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.mobile),
                        controller: _mobileController,
                        validator: (value) => value.isEmpty
                            ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText)
                            : (value.length != 10 ? 'Invalid number' : null),
                      ),
                      detailTextField(
                        labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.adharPan),
                        controller: _adhaarController,
                        validator: (value) => value.isEmpty
                            ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText)
                            : null,
                      ),
                      detailTextField(
                        labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.licenseNo),
                        controller: _dlController,
                        validator: (value) => value.isEmpty
                            ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText)
                            : null,
                      ),
                      InkWell(
                        onTap: (){
                          showMonthPicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year - 1, 5),
                            lastDate: DateTime(DateTime.now().year + 20, 9),
                            initialDate: DateTime.now(),
                            locale: Locale("en"),
                          ).then((date) {
                            if (date != null) {
                              setState(() {
                                _licenseExpiryController.text = "${date.month}/${date.year.toString().split("")[2]}${date.year.toString().split("")[3]}";
                              });
                            }
                          });
                        },
                        child: detailTextField(
                          labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.licenseExpiry),
                          controller: _licenseExpiryController,
                          enable: false,
                          validator: (value) => value.isEmpty
                              ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText)
                              : null,
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 65,
                        width: size.width,
                        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: primaryColor,
                          onPressed: isLoading
                              ? () {}
                              : () async {
                                  if (_formKey.currentState.validate()) {
                                    String mobile = _mobileController.text;
                                    String name = _nameController.text;
                                    String dl = _dlController.text;
                                    String adhaar = _adhaarController.text;
                                    String expiry = _licenseExpiryController.text;
                                    DriverRegisterModel model = DriverRegisterModel(
                                        adhaar: adhaar,
                                        agent: user.uid,
                                        dl: dl,
                                        licenseExpiryDate: expiry,
                                        mobile: mobile,
                                        name: name,
                                        pan: 'adhaar',
                                        cstatus: true
                                    );
                                    setState(() {
                                      isLoading = true;
                                    });
                                    bool b = await AddDriverController().addDriver(model);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (!b) {
                                      Fluttertoast.showToast(
                                          msg: AppLocalizations.getLocalizationValue(
                                              locale, LocaleKey.driverAlreadyExists));
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: AppLocalizations.getLocalizationValue(
                                        locale,
                                        LocaleKey.driverRegistered,
                                      ));
                                      Navigator.pop(context);
                                    }
                                    // Navigator.of(context)
                                    //     .push(MaterialPageRoute(builder: (context) => DriverDocumentScreen()));
                                  }
                                },
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.getLocalizationValue(locale, LocaleKey.continueText),
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
