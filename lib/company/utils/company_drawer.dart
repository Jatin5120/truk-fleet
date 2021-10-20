import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/pages/fleet_document_page.dart';
import 'package:truk_fleet/company/pages/my_payout_page.dart';
import 'package:truk_fleet/company/pages/my_shipment_screen.dart';
import 'package:truk_fleet/company/pages/settings.dart';
import 'package:truk_fleet/company/pages/company_profile.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:truk_fleet/screens/about.dart';
import 'package:truk_fleet/screens/fleetSelection_screen.dart';
import 'package:truk_fleet/company/pages/support_screen.dart';
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/company/pages/my_drivers.dart';
import 'package:truk_fleet/company/pages/my_truks.dart';

class CompanyDrawerMenu extends StatefulWidget {
  @override
  CompanyDrawerMenuState createState() => CompanyDrawerMenuState();
}

class CompanyDrawerMenuState extends State<CompanyDrawerMenu> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).locale;
    final pUser = Provider.of<MyUser>(context);
    double width = MediaQuery.of(context).size.width;
    Widget placeHolder = Text(
      pUser.isUserLoading ? '...' : '${pUser.user.name[0]}',
      style: TextStyle(
        fontSize: 26,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    return ListView(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: pUser.isUserLoading
                    ? CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryColor,
                        child: placeHolder,
                      )
                    : (pUser.user.image == 'na' || pUser.user.image == null
                        ? CircleAvatar(
                            radius: 40,
                            backgroundColor: primaryColor,
                            child: placeHolder,
                          )
                        : Container(
                            height: 80,
                            width: 80,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: CachedNetworkImage(
                                imageUrl: pUser.user.image,
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                              ),
                            ),
                          )),
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  pUser.isUserLoading ? 'Loading...' : '${pUser.user.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  pUser.isUserLoading ? 'Loading...' : '${pUser.user.mobile}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => CompanyProfile(),
                      ),
                    );
                  },
                  child: Text(
                      AppLocalizations.getLocalizationValue(
                          locale, LocaleKey.edit),
                      style: TextStyle(color: Colors.blue, fontSize: 18)),
                ),
              ),
              SizedBox(height: 5),
              Divider(height: 2),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        myListTile(
          title: AppLocalizations.getLocalizationValue(
              locale, LocaleKey.shipments),
          leading: SvgPicture.asset(
            'assets/svg/truck_svg.svg',
            height: 22,
            width: 27,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => CompanyHomeFragment()));
          },
        ),
        myListTile(
          title:
              AppLocalizations.getLocalizationValue(locale, LocaleKey.myTruks),
          leading: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Image.asset(
              'assets/images/frontal-truck.png',
              height: 25,
              width: 25,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => MyTrucks(),
              ),
            );
          },
        ),
        myListTile(
          title:
              AppLocalizations.getLocalizationValue(locale, LocaleKey.myDriver),
          leading: Image.asset(
            'assets/images/delivery-man.png',
            height: 25,
            width: 25,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => MyDrivers(),
              ),
            );
          },
        ),
        myListTile(
          title:
              AppLocalizations.getLocalizationValue(locale, LocaleKey.myPayout),
          leading: Icon(
            Icons.payment,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => MyPayoutPage(),
              ),
            );
          },
        ),
        myListTile(
          title: AppLocalizations.getLocalizationValue(
              locale, LocaleKey.documents),
          leading: Icon(Icons.dock, color: Colors.black),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => FleetDocumentScreen()));
          },
        ),
        myListTile(
          title:
              AppLocalizations.getLocalizationValue(locale, LocaleKey.support),
          leading: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(
              Icons.contact_support,
              color: Colors.black,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SupportScreen(),
              ),
            );
          },
        ),
        myListTile(
          title: AppLocalizations.getLocalizationValue(locale, LocaleKey.about),
          leading: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(
              Icons.info_outlined,
              color: Colors.black,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AboutUs(),
              ),
            );
          },
        ),
        myListTile(
            title: AppLocalizations.getLocalizationValue(
                locale, LocaleKey.settings),
            leading: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => SettingsPage()));
            }),
        Container(
          height: 50,
          width: width,
          alignment: Alignment.center,
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app,
                    color: Color.fromRGBO(255, 113, 1, 100)),
                SizedBox(width: 10),
                Text(
                  AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.logout),
                  style: TextStyle(fontSize: 20, color: primaryColor),
                )
              ],
            ),
            onTap: () {
              Helper().showConfirmationDialog(
                title: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.logout),
                subTitle: AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.logoutConfirm),
                context: context,
                onTap: () {
                  Navigator.pop(context);
                  SharedPref().logoutUser();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FleetSelection(),
                    ),
                    (route) => false,
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget myListTile({String title, void Function() onTap, Widget leading}) {
    return ListTile(
      leading: leading,
      title: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
      onTap: onTap,
    );
  }
}
