import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/controller/my_shipment_controller.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/models/truk_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/no_data_page.dart';
import '../../utils/expandable_card_container.dart';

class CompanyHomeFragment extends StatefulWidget {
  @override
  _CompanyHomeFragmentState createState() => _CompanyHomeFragmentState();
}

class _CompanyHomeFragmentState extends State<CompanyHomeFragment> {
  final User user = FirebaseAuth.instance.currentUser;
  Locale locale;
  List<ShipmentModel> filteredList = [];
  bool isFilter = false;
  @override
  Widget build(BuildContext context) {
    final pTruks = Provider.of<MyTruksProvider>(context);
    final pShipments = Provider.of<FleetRideModel>(context);
    locale = AppLocalizations.of(context).locale;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.shipments)),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: pTruks.isTrukLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : (pShipments.shipmentList.length <= 0
                ? NoDataPage(
                    text: AppLocalizations.getLocalizationValue(locale, LocaleKey.noShipment),
                  )
                : pShipments.isShipmentLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ))
                    : myShipments(pShipments.shipments)),
      ),
    );
  }

  Widget myShipments(List<ShipmentModel> shipments) {
    List<int> ids = [];
    for (ShipmentModel d in shipments) {
      ids.add(d.bookingId);
    }
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.number,
          onChanged: (string) {
            if (string.trim().length <= 0 || string.isEmpty) {
              setState(() {
                isFilter = false;
                filteredList = [];
              });
            } else {
              setState(() {
                filteredList = shipments
                    .where((element) =>
                        element.bookingId.toString().contains(string.trim().toLowerCase()) ||
                        element.price.contains(string.toLowerCase()) ||
                        element.pickupDate.contains(string.toLowerCase()))
                    .toList();
                isFilter = true;
              });
            }
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.getLocalizationValue(locale, LocaleKey.searchHint),
            border: OutlineInputBorder(),
            labelText: AppLocalizations.getLocalizationValue(locale, LocaleKey.search),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: isFilter ? filteredList.length : shipments.length,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              ShipmentModel model = isFilter ? filteredList[index] : shipments[index];
              String docID = isFilter ? filteredList[index].id : shipments[index].id;

              bool isCollapsed = true;
              return ExpandableCardContainer(
                docID: docID,
                model: model,
                isCollapsed: isCollapsed,
              );
            },
          ),
        ),
      ],
    );
  }
}
