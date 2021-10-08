import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/company/pages/track.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/material_model.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/screens/quote_summary_screen.dart';

class ExpandableCardContainer extends StatefulWidget {
  final ShipmentModel model;
  final String docID;
  final bool isCollapsed;

  const ExpandableCardContainer(
      {Key key, this.model, this.docID, this.isCollapsed = false})
      : super(key: key);

  @override
  _ExpandableCardContainerState createState() =>
      _ExpandableCardContainerState();
}

class _ExpandableCardContainerState extends State<ExpandableCardContainer> {
  Locale locale;
  final BoxDecoration enabledDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: const Color(0xffff7101),
    boxShadow: [
      BoxShadow(
        color: const Color(0x99ff7101),
        offset: Offset(0, 3),
        blurRadius: 10,
      ),
    ],
  );
  final BoxDecoration disabledBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    border: Border.all(width: 1.0, color: const Color(0xffbfbfbf)),
  );
  final BoxDecoration completedDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.green,
    boxShadow: [
      BoxShadow(
        color: Colors.green.withOpacity(0.8),
        offset: Offset(0, 3),
        blurRadius: 10,
      ),
    ],
  );
  final enabledTextStyle = TextStyle(color: Colors.white);
  final disabledTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    color: const Color(0xffbfbfbf),
    fontWeight: FontWeight.w500,
    height: 1.5625,
  );

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    QuoteModel quoteModel = QuoteModel.fromMap(widget.model.toMap());
    double weight = 0;
    for (MaterialModel val in widget.model.materials) {
      weight += val.quantity;
    }

    return Card(
      elevation: 8,
      child: ExpandablePanel(
        collapsed: Container(),
        header: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 15),
                          child: Image.asset(
                            'assets/images/delivery_truck.png',
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Booking Id: ${widget.model.bookingId}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black),
                      ),
                      Text(
                        "${AppLocalizations.getLocalizationValue(locale, LocaleKey.quantity)}: $weight KG",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      FutureBuilder<String>(
                        future:
                            Helper().setLocationText(widget.model.destination),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text('Address...');
                          }
                          String dest = snapshot.data.split(',')[2] == null
                              ? snapshot.data.split(',')[3]
                              : snapshot.data.split(',')[2];
                          return Text(
                            "${AppLocalizations.getLocalizationValue(locale, LocaleKey.destination)}: $dest",
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${AppLocalizations.getLocalizationValue(locale, LocaleKey.date)}: ${widget.model.pickupDate}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${AppLocalizations.getLocalizationValue(locale, LocaleKey.fare)} \u20B9 ${widget.model.price}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${AppLocalizations.getLocalizationValue(locale, LocaleKey.payments)}: ${AppLocalizations.getLocalizationValue(locale, widget.model.paymentStatus)}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        //collapsed: ,
        expanded: Container(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => QuoteSummaryScreen(
                                quoteModel: quoteModel,
                                onlyView: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color(0xffff7101),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x99ff7101),
                                offset: Offset(0, 3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.getLocalizationValue(
                                  locale, LocaleKey.orderSummary),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: widget.model.status == RequestStatus.completed
                          ? Container(
                              height: 40.0,
                              decoration: completedDecoration,
                              child: Center(
                                child: Text(
                                  AppLocalizations.getLocalizationValue(
                                      locale, LocaleKey.delivered),
                                  style: enabledTextStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap:
                                  widget.model.status != RequestStatus.started
                                      ? () {}
                                      : () {
                                          double weight = 0.0;
                                          for (MaterialModel m
                                              in widget.model.materials) {
                                            weight += m.quantity;
                                          }
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => TrackNew(
                                                shipmentModel: widget.model,
                                              ),
                                            ),
                                          );
                                        },
                              child: Container(
                                height: 40.0,
                                decoration:
                                    widget.model.status == RequestStatus.started
                                        ? enabledDecoration
                                        : disabledBoxDecoration,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.getLocalizationValue(
                                        locale, LocaleKey.track),
                                    style: widget.model.status ==
                                            RequestStatus.started
                                        ? enabledTextStyle
                                        : disabledTextStyle,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
