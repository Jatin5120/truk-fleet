import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../locale/app_localization.dart';
import '../locale/locale_keys.dart';
import '../utils/constants.dart';

void paymentSuccessful(
    {String shipmentId, BuildContext context, bool isPayment = true, Function onTap, String payment, String text}) {
  final locale = AppLocalizations.of(context).locale;
  Platform.isAndroid
      ? showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: isPayment ? 2 : 30,
                  ),
                  Center(
                    child: Text(
                      isPayment
                          ? "\u20b9$payment"
                          : AppLocalizations.getLocalizationValue(locale, LocaleKey.bookingRequested),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: isPayment ? 2 : 30,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/${isPayment ? "check_icon" : "request_success"}.png',
                      height: isPayment ? 60 : 113,
                      width: isPayment ? 60 : 155,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(
                    height: isPayment ? 15 : 50,
                  ),
                  shipmentId == null
                      ? Container()
                      : Text(
                          'Advance payment required for ${AppLocalizations.getLocalizationValue(locale, LocaleKey.shipmentId)}: $shipmentId',
                          style: TextStyle(fontSize: 18),
                        )
                ],
              ),
              actions: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: RaisedButton(
                    color: primaryColor,
                    onPressed: onTap,
                    child: Text(
                      AppLocalizations.getLocalizationValue(locale, LocaleKey.done),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                )
              ],
            );
          },
        )
      : showCupertinoDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return Material(
              color: Colors.transparent,
              child: CupertinoAlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: isPayment ? 2 : 30,
                    ),
                    Center(
                      child: Text(
                        isPayment
                            ? "\u20b9$payment"
                            : AppLocalizations.getLocalizationValue(locale, LocaleKey.bookingRequested),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: isPayment ? 2 : 30,
                    ),
                    Center(
                      child: Image.asset(
                        'assets/images/${isPayment ? "check_icon" : "request_success"}.png',
                        height: isPayment ? 60 : 113,
                        width: isPayment ? 60 : 155,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      height: isPayment ? 15 : 50,
                    ),
                    shipmentId == null
                        ? Container()
                        : Text(
                            'Advance payment required for ${AppLocalizations.getLocalizationValue(locale, LocaleKey.shipmentId)}: $shipmentId \n Please collect and try again',
                            style: TextStyle(fontSize: 18),
                          )
                  ],
                ),
                actions: [
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: RaisedButton(
                      color: primaryColor,
                      onPressed: onTap,
                      child: Text(
                        AppLocalizations.getLocalizationValue(locale, LocaleKey.done),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
}

void showConfirmationDialog({BuildContext context, String title, String subTitle, Function onTap, Function onNoTap}) {
  if (onNoTap == null) {
    onNoTap = () {
      Navigator.pop(context);
    };
  }
  final locale = AppLocalizations.of(context).locale;
  Platform.isAndroid
      ? showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$title'),
            content: Text('$subTitle'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  onTap();
                },
                child: Center(
                  child: Text(
                    AppLocalizations.getLocalizationValue(locale, LocaleKey.yes),
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              RaisedButton(
                color: primaryColor,
                onPressed: () => Navigator.pop(context),
                child: Center(
                  child: Text(
                    AppLocalizations.getLocalizationValue(locale, LocaleKey.no),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )
      : showCupertinoDialog(
          context: context,
          builder: (context) => Material(
            color: Colors.transparent,
            child: CupertinoAlertDialog(
              title: Text('$title'),
              content: Text('$subTitle'),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onTap();
                  },
                  child: Center(
                    child: Text(
                      AppLocalizations.getLocalizationValue(locale, LocaleKey.yes),
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: onNoTap,
                  child: Center(
                    child: Text(
                      AppLocalizations.getLocalizationValue(locale, LocaleKey.no),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
}

// void reasonDialog({BuildContext context, String title, Function(String) onTap}) {
//   final TextEditingController textEditingController = TextEditingController();
//   final locale = AppLocalizations.of(context).locale;
//   Platform.isAndroid
//       ? showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('$title'),
//             content: TextFormField(
//               keyboardType: TextInputType.multiline,
//               minLines: null,
//               controller: textEditingController,
//               maxLines: 3,
//               decoration: InputDecoration(border: OutlineInputBorder()),
//             ),
//             actions: [
//               FlatButton(
//                 onPressed: () {
//                   if (textEditingController.text.trim().isEmpty) {
//                     Fluttertoast.showToast(msg: "Please specify reason");
//                     return;
//                   }
//                   Navigator.pop(context);
//                   onTap(textEditingController.text.trim());
//                 },
//                 child: Center(
//                   child: Text(
//                     AppLocalizations.getLocalizationValue(locale, LocaleKey.continueText),
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//               ),
//               RaisedButton(
//                 color: primaryColor,
//                 onPressed: () => Navigator.pop(context),
//                 child: Center(
//                   child: Text(
//                     AppLocalizations.getLocalizationValue(locale, LocaleKey.cancel),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       : showCupertinoDialog(
//           context: context,
//           builder: (context) => Material(
//             color: Colors.transparent,
//             child: CupertinoAlertDialog(
//               title: Text('$title'),
//               content: TextFormField(
//                 keyboardType: TextInputType.multiline,
//                 controller: textEditingController,
//                 minLines: null,
//                 maxLines: null,
//                 expands: true,
//               ),
//               actions: [
//                 FlatButton(
//                   onPressed: () {
//                     if (textEditingController.text.trim().isEmpty) {
//                       Fluttertoast.showToast(msg: "Please specify reason");
//                       return;
//                     }
//                     Navigator.pop(context);
//                     onTap(textEditingController.text.trim());
//                   },
//                   child: Center(
//                     child: Text(
//                       AppLocalizations.getLocalizationValue(locale, LocaleKey.yes),
//                       style: TextStyle(color: primaryColor),
//                     ),
//                   ),
//                 ),
//                 FlatButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Center(
//                     child: Text(
//                       AppLocalizations.getLocalizationValue(locale, LocaleKey.no),
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
// }
