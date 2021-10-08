import 'package:flutter/material.dart';
import 'package:truk_fleet/auth/login/login_page.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/utils/constants.dart';

class FleetSelection extends StatefulWidget {
  @override
  _FleetSelectionState createState() => _FleetSelectionState();
}

class _FleetSelectionState extends State<FleetSelection> {
  EdgeInsetsGeometry padding = EdgeInsets.only(left: 15, right: 15);
  TextStyle selectedTitleTextStyle =
      TextStyle(color: Colors.white, fontSize: 18);
  TextStyle unselectedTitleTextStyle = TextStyle(fontSize: 18);
  TextStyle selectedSubtitleTextStyle =
      TextStyle(color: Colors.white, fontSize: 16);
  TextStyle unselectedSubtitleTextStyle =
      TextStyle(fontSize: 16, color: Colors.grey);
  Locale locale;
  String type = LoginType.company;

  bool selected = true;
  int selection = 0;
  Widget selectionCard({
    String title,
    int index,
    void Function() onTap,
    String assetImage,
    String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      padding: padding,
      child: Card(
        elevation: selection == index ? 12 : 1.0,
        color: selection == index ? primaryColor : Colors.white,
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image(
                height: 30,
                width: 30,
                image: AssetImage(assetImage),
              ),
            ),
          ),
          onTap: () {
            setState(() {
              selection = index;
            });
            onTap();
          },
          title: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10.0),
            child: Text(title,
                style: selection == index
                    ? selectedTitleTextStyle
                    : unselectedTitleTextStyle),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8.0),
            child: Text(
              subtitle,
              style: selection == index
                  ? selectedSubtitleTextStyle
                  : unselectedSubtitleTextStyle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.fleetSelectionScreenTitle),
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              selectionCard(
                assetImage: 'assets/images/truckingCompany.png',
                index: 0,
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.fleetSelectionTitle),
                subtitle: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.fleetSelectionSubtitle),
                onTap: () {
                  setState(() {
                    type = LoginType.company;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              selectionCard(
                assetImage: 'assets/images/driver.png',
                index: 1,
                subtitle: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.driverSelectionSubtitle),
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.driverSelectionTitle),
                onTap: () {
                  setState(() {
                    type = LoginType.driver;
                  });
                },
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 65,
                width: size.width,
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(type),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.getLocalizationValue(
                        locale, LocaleKey.continueText),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
