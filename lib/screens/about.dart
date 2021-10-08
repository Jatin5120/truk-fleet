import 'package:flutter/material.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/utils/constants.dart';
class AboutUs extends StatelessWidget {
  Locale locale;

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(" ${AppLocalizations.getLocalizationValue(this.locale, LocaleKey.about)}",style: TextStyle(color: Colors.white),),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  child: RichText(
                    text: TextSpan(
                      text: "${AppLocalizations.getLocalizationValue(this.locale, LocaleKey.about_text)}",
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                  )
              ),
            ),
          ),
        )
    );
  }
}
