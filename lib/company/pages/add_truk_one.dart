import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:truk_fleet/company/controller/truk_controller.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/truk_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/company/pages/add_truk_two.dart';

class AddTruck extends StatefulWidget {
  final bool isEdit;
  final TrukModal trukModal;
  AddTruck({this.trukModal, this.isEdit = false});
  @override
  _AddTruckState createState() => _AddTruckState();
}

class _AddTruckState extends State<AddTruck> {
  final User user = FirebaseAuth.instance.currentUser;
  final TextEditingController trukOwnerNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController panTinController = TextEditingController();
  final TextEditingController trukModelController = TextEditingController();
  final TextEditingController axelTypeController = TextEditingController();
  final TextEditingController grossWeightController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController trukNumberController = TextEditingController();
  final TextEditingController permitTypeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String trukBodyType = LocaleKey.closedTruk;

  bool isLoading = false;
  Locale locale;
  List<String> axelTypeList = [
    "Single Axle",
    "Double Axle",
    "Triple Axle",
    "Multi Axle"
  ];

  Widget detailTextField({
    String labelText,
    TextEditingController controller,
    String Function(String) validator,
    bool isNumber = false,
    bool isDone = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        maxLength: isNumber ? 10 : null,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        textInputAction: isDone ? TextInputAction.done : TextInputAction.next,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      trukOwnerNameController.text = widget.trukModal.ownerName;
      mobileNumberController.text = widget.trukModal.mobileNumber;
      axelTypeController.text = widget.trukModal.trukName;
      trukModelController.text = widget.trukModal.trukModel;
      panTinController.text = widget.trukModal.panTin;
      grossWeightController.text =
          '${(int.parse(widget.trukModal.grossWeight) ~/ 1000)}';
      lengthController.text = widget.trukModal.length;
      breadthController.text = widget.trukModal.breadth;
      heightController.text = widget.trukModal.height;
      trukNumberController.text = widget.trukModal.trukNumber;
      permitTypeController.text = widget.trukModal.permitType;
      trukBodyType = widget.trukModal.trukType.toLowerCase().contains('closed')
          ? LocaleKey.closedTruk
          : LocaleKey.openTruk;
      setState(() {});
    }
  }

  @override
  void dispose() {
    trukOwnerNameController.dispose();
    mobileNumberController.dispose();
    panTinController.dispose();
    grossWeightController.dispose();
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
    trukNumberController.dispose();
    permitTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.getLocalizationValue(
              locale,
              LocaleKey.trukDetails,
            ),
          ),
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  child: Text(
                    AppLocalizations.getLocalizationValue(
                        locale, LocaleKey.addTruk),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                detailTextField(
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.ownerName),
                  controller: trukOwnerNameController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                detailTextField(
                  labelText: AppLocalizations.getLocalizationValue(
                    locale,
                    LocaleKey.mobile,
                  ),
                  isNumber: true,
                  controller: mobileNumberController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : (value.length != 10 ? 'Invalid number' : null),
                ),
                detailTextField(
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.panTin),
                  controller: panTinController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: DropdownButtonFormField<String>(
                    hint: Text(
                      AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.trukModel),
                    ),
                    onChanged: (value) {
                      setState(() => trukModelController.text = value);
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: trukModels
                        .map(
                          (e) => DropdownMenuItem<String>(
                            child: Text(
                              e,
                            ),
                            value: e,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: DropdownButtonFormField<String>(
                    hint: Text(
                      AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.axleType),
                    ),
                    onChanged: (value) {
                      setState(() => axelTypeController.text = value);
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: axelTypeList
                        .map(
                          (e) => DropdownMenuItem<String>(
                            child: Text(
                              e,
                            ),
                            value: e,
                          ),
                        )
                        .toList(),
                  ),
                ),
                // detailTextField(
                //   labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.trukModel),
                //   controller: trukModelController,
                //   validator: (value) =>
                //       value.isEmpty ? AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText) : null,
                // ),
                detailTextField(
                  isNumber: true,
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.grossWeight),
                  controller: grossWeightController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: DropdownButtonFormField(
                    hint: Text(
                      AppLocalizations.getLocalizationValue(
                        locale,
                        LocaleKey.trukType,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => trukBodyType = value);
                      FocusScope.of(context).unfocus();
                      FocusScope.of(context).nextFocus();
                    },
                    value: trukBodyType ?? LocaleKey.closedTruk,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.selectTrukType),
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.getLocalizationValue(
                              locale, LocaleKey.closedTruk),
                        ),
                        value: LocaleKey.closedTruk,
                      ),
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.getLocalizationValue(
                              locale, LocaleKey.openTruk),
                        ),
                        value: LocaleKey.openTruk,
                      ),
                    ],
                  ),
                ),
                detailTextField(
                  isNumber: true,
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.lengthInFeet),
                  controller: lengthController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                detailTextField(
                  isNumber: true,
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.breadthInFeet),
                  controller: breadthController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                detailTextField(
                  isNumber: true,
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.heightInFeet),
                  controller: heightController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                detailTextField(
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.trukNumber),
                  controller: trukNumberController,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                detailTextField(
                  labelText: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.permitType),
                  controller: permitTypeController,
                  isDone: true,
                  validator: (value) => value.isEmpty
                      ? AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.requiredText)
                      : null,
                ),
                SizedBox(height: 48),
                Container(
                  height: 65,
                  width: size.width,
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      primary: primaryColor,
                    ),
                    onPressed: isLoading
                        ? () {}
                        : () async {
                            if (_formKey.currentState.validate()) {
                              if (axelTypeController.text.trim().isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "Select Truk Model");
                                return;
                              }

                              String mobile = mobileNumberController.text;
                              String ownerName = trukOwnerNameController.text;
                              String trukNumber =
                                  trukNumberController.text.toUpperCase();
                              String height = heightController.text;
                              String grossWeigth =
                                  (int.parse(grossWeightController.text) * 1000)
                                      .toString();
                              String breadth = breadthController.text;
                              String length = lengthController.text;
                              String permitType = permitTypeController.text;
                              String panTin = panTinController.text;
                              String trukName = axelTypeController.text;
                              String trukModel = trukModelController.text;

                              TrukModal truk = TrukModal(
                                breadth: breadth,
                                driver: 'na',
                                ownerId: user.uid,
                                grossWeight: grossWeigth,
                                height: height,
                                length: length,
                                mobileNumber: mobile,
                                ownerName: ownerName,
                                panTin: panTin,
                                permitType: permitType,
                                trukName: trukName,
                                trukNumber: trukNumber,
                                trukType: trukBodyType,
                                trukModel: trukModel,
                                available: true,
                              );
                              setState(() {
                                isLoading = true;
                              });

                              widget.isEdit
                                  ? await TrukController().updateTruk(truk)
                                  : await TrukController().addTruk(truk);
                              setState(() {
                                isLoading = false;
                              });
                              if (!widget.isEdit) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MoreTrukDetails(
                                      trukNumber: trukNumber,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            }
                          },
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.isEdit
                                ? AppLocalizations.getLocalizationValue(
                                    locale, LocaleKey.update)
                                : AppLocalizations.getLocalizationValue(
                                    locale, LocaleKey.continueText),
                            style: TextStyle(fontSize: 18, color: Colors.white),
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
