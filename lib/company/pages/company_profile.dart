import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/controller/profile_controller.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:truk_fleet/utils/CustomImageChooser.dart';
import 'package:truk_fleet/utils/constants.dart';
import '../../utils/CustomImageChooser.dart';
import '../../helper/email_validator.dart';

class CompanyProfile extends StatefulWidget {
  @override
  _CompanyProfileState createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final ProfileController profileController = ProfileController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController companyNumberController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isUpdating = false;
  File myImage;
  MyUser pUser;
  Locale locale;
  Future getImage(ImageSource source, int index) async {
    var image = await ImagePicker().getImage(source: source);
    if (image != null && mounted) {
      setState(() {
        myImage = File(image.path);
      });
    }
  }

  Widget textFieldWithDetail({
    String hint,
    String text,
    TextEditingController controller,
    bool readOnly,
    String Function(String) validator,
  }) {
    //controller.text = text;
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly ?? false,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(hint),
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    gstController.dispose();
    companyController.dispose();
    companyNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pUser = Provider.of<MyUser>(context, listen: false);
    emailController.text = pUser.user.email;
    phoneController.text = pUser.user.mobile;
    usernameController.text = pUser.user.name;
    gstController.text = pUser.user.gst;
    companyController.text = pUser.user.company;
    companyNumberController.text = pUser.user.regNumber;
    _upiController.text = pUser.user.upiId;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    Widget placeHolder = Text(
      '${pUser.user.name[0]}'.toUpperCase(),
      style: TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.getLocalizationValue(locale, LocaleKey.editProfile),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          height: size.height,
          width: size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Stack(
                    overflow: Overflow.visible,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: size.height * 0.15,
                        width: size.height * 0.15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            size.height * 0.15 * 0.5,
                          ),
                        ),
                        child: ((pUser.user.image == 'na' || pUser.user.image == null) && myImage == null
                            ? CircleAvatar(
                                radius: size.height * 0.15 * 0.5,
                                backgroundColor: primaryColor,
                                child: placeHolder,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  size.height * 0.15 * 0.5,
                                ),
                                child: myImage == null
                                    ? CachedNetworkImage(
                                        imageUrl: pUser.user.image,
                                        fit: BoxFit.cover,
                                        height: size.height * 0.15,
                                        width: size.height * 0.15,
                                      )
                                    : Image.file(
                                        myImage,
                                        height: size.height * 0.15,
                                        width: size.height * 0.15,
                                        fit: BoxFit.cover,
                                      ),
                              )),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            Platform.isAndroid
                                ? showDialog(
                                    context: context,
                                    builder: (_) => CustomImageChooser.makeImageChooser(
                                      context,
                                      0,
                                      (source) => getImage(source, 0),
                                    ),
                                  )
                                : showCupertinoDialog(
                                    context: context,
                                    builder: (_) => Material(
                                      color: Colors.transparent,
                                      child: CustomImageChooser.makeImageChooser(
                                        context,
                                        0,
                                        (source) => getImage(source, 0),
                                      ),
                                    ),
                                  );
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: primaryColor,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),

                textFieldWithDetail(
                  text: pUser.user.name,
                  hint: AppLocalizations.getLocalizationValue(locale, LocaleKey.name),
                  controller: usernameController,
                  validator: (st) {
                    if (st.trim().isEmpty) {
                      return AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText);
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                textFieldWithDetail(
                  text: pUser.user.email,
                  hint: AppLocalizations.getLocalizationValue(locale, LocaleKey.email),
                  controller: emailController,
                  validator: (st) =>
                      st.isValidEmail() ? null : AppLocalizations.getLocalizationValue(locale, LocaleKey.invalidEmail),
                ),
                SizedBox(
                  height: 15,
                ),
                textFieldWithDetail(
                  text: pUser.user.mobile,
                  hint: AppLocalizations.getLocalizationValue(locale, LocaleKey.mobile),
                  controller: phoneController,
                  readOnly: true,
                ),
                SizedBox(
                  height: 15,
                ),
                textFieldWithDetail(
                  text: pUser.user.company,
                  hint: "UPI",
                  controller: _upiController,
                  validator: (st) =>
                      st.isEmpty ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText) : null,
                ),
                SizedBox(
                  height: 15,
                ),
                textFieldWithDetail(
                  text: pUser.user.company,
                  hint: AppLocalizations.getLocalizationValue(locale, LocaleKey.company),
                  controller: companyController,
                  validator: (st) =>
                      st.isEmpty ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText) : null,
                ),
                SizedBox(
                  height: 15,
                ),
                textFieldWithDetail(
                  text: pUser.user.regNumber,
                  hint: AppLocalizations.getLocalizationValue(locale, LocaleKey.companyNo),
                  controller: companyNumberController,
                  validator: (st) =>
                      st.isEmpty ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText) : null,
                ),
                SizedBox(
                  height: 15,
                ),
                textFieldWithDetail(
                  text: pUser.user.gst,
                  hint: AppLocalizations.getLocalizationValue(locale, LocaleKey.gstNo),
                  controller: gstController,
                  validator: (st) =>
                      st.isEmpty ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText) : null,
                ),
                SizedBox(
                  height: 15,
                ),
                //Expanded(child: SizedBox()),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 65,
                  width: size.width,
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: RaisedButton(
                    color: primaryColor,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        String email = emailController.text.trim();
                        String name = usernameController.text.trim();
                        String gst = gstController.text.trim();
                        String company = companyController.text.trim();
                        String regNu = companyNumberController.text.trim();
                        String upiId = _upiController.text.trim();
                        setState(() {
                          isUpdating = true;
                        });
                        await profileController.updateUser(
                            upi: upiId,
                            email: email,
                            name: name,
                            image: myImage,
                            company: company,
                            gst: gst,
                            regNo: regNu);
                        Fluttertoast.showToast(
                          msg: AppLocalizations.getLocalizationValue(locale, LocaleKey.profileUpdated),
                        );
                        setState(() {
                          isUpdating = false;
                        });
                      }
                    },
                    child: isUpdating
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.getLocalizationValue(locale, LocaleKey.update),
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
