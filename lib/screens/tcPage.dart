import 'package:flutter/material.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/utils/constants.dart';

class TCPage extends StatelessWidget {
  Locale locale;

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            "${AppLocalizations.getLocalizationValue(this.locale, LocaleKey.insuranceText2)}",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  child: RichText(
                text: TextSpan(
                  text:
                      "${AppLocalizations.getLocalizationValue(this.locale, LocaleKey.TC)}",
                  style: TextStyle(color: Colors.black),
                ),
              )),
            ),
          ),
        ));
  }
}
