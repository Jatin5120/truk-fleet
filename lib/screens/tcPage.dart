import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/utils/constants.dart';

class TCPage extends StatelessWidget {
  Locale locale;
  String data;

  TCPage({this.data});

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
      body: data == null
          ? SafeArea(
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
            )
          : Markdown(
              data: data,
            ),
    );
  }
}
