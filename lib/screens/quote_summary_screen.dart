import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/payment_type.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import '../helper/helper.dart';

import '../models/material_model.dart';
import '../utils/constants.dart';

class QuoteSummaryScreen extends StatefulWidget {
  final QuoteModel quoteModel;
  final bool onlyView;
  const QuoteSummaryScreen({
    Key key,
    @required this.quoteModel,
    this.onlyView = false,
  }) : super(key: key);

  @override
  _QuoteSummaryScreenState createState() => _QuoteSummaryScreenState();
}

class _QuoteSummaryScreenState extends State<QuoteSummaryScreen> {
  bool isLoading = false;
  String sourceAddress = '';
  String destinationAddress = '';
  String payment;
  final User user = FirebaseAuth.instance.currentUser;
  Locale locale;
  var advance;
  getAdvance () async {
    await FirebaseFirestore.instance.collection(FirebaseHelper.quoteCollection).where('bookingId',isEqualTo: widget.quoteModel.bookingId).get().then((value){
      for(var d in value.docs){
        setState(() {
          advance=d.get('advance');
        });
      }
    });
  }
  @override
  void initState() {
    Helper().setLocationText(widget.quoteModel.source).then((value) => setState(() => sourceAddress = value));
    Helper().setLocationText(widget.quoteModel.destination).then((value) => setState(() => destinationAddress = value));
    getAdvance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(advance);
    locale = AppLocalizations.of(context).locale;
    final Size size = MediaQuery.of(context).size;
    final EdgeInsetsGeometry padding = EdgeInsets.only(left: 16, right: 16, top: 20);
    final TextStyle style = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    String title = AppLocalizations.getLocalizationValue(locale, LocaleKey.orderSummary);
    if (!widget.onlyView) {
      title = AppLocalizations.getLocalizationValue(locale, LocaleKey.quotes);
    }
    final pUser = Provider.of<MyUser>(context);
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(title),
        ),
        body: Container(
          child: ListView(
            children: [
              Container(
                padding: padding,
                child: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.shipmentDetails), style: style),
              ),
              buildMaterialContainer(size),
              buildTypes(size),
              Container(
                padding: padding,
                child: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupLocation), style: style),
              ),
              createLocationBlock(size, 0),
              Container(
                padding: padding,
                child: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.dropLocation), style: style),
              ),
              createLocationBlock(size, 1),
              Container(
                padding: padding,
                child: Text(AppLocalizations.getLocalizationValue(locale, LocaleKey.pickupDate), style: style),
              ),
              createDateBlock(),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: Container(
                  child: Text(
                    '${widget.quoteModel.insured ? AppLocalizations.getLocalizationValue(locale, LocaleKey.withInsurance) : AppLocalizations.getLocalizationValue(locale, LocaleKey.withOutInsurance)}',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: Text(
                  "${AppLocalizations.getLocalizationValue(locale, widget.quoteModel.paymentStatus)} - \u20B9${widget.quoteModel.price}",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: const Color(0xff76b448),
                    fontWeight: FontWeight.w500,
                    height: 2.142857142857143,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: Text(
                  "Advance - \u20B9$advance",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: const Color(0xff76b448),
                    fontWeight: FontWeight.w500,
                    height: 2.142857142857143,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              if (!widget.onlyView)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: [
                      Radio(
                        value: PaymentType.cod,
                        groupValue: payment,
                        onChanged: (b) {
                          setState(() {
                            payment = b;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(PaymentType.paymentKeys[PaymentType.cod]),
                      ),
                    ],
                  ),
                ),
              if (!widget.onlyView)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: [
                      Radio(
                        value: PaymentType.online,
                        groupValue: payment,
                        onChanged: (b) {
                          setState(() {
                            payment = b;
                          });
                        },
                      ),
                      Expanded(
                        child: Text("${PaymentType.paymentKeys[PaymentType.online]}(Discount of 200)"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMaterialContainer(Size size) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xfff8f8f8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.quoteModel.materials.length,
        itemBuilder: (context, index) {
          MaterialModel m = widget.quoteModel.materials[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '${index + 1}. ',
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Text(
                    '${m.materialName}',
                    style: TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '${m.quantity} KG',
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTypes(Size size) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xfff8f8f8),
      ),
      child: Column(
        children: [
          createTypes(
              AppLocalizations.getLocalizationValue(this.locale, LocaleKey.mandateType),
              AppLocalizations.getLocalizationValue(this.locale,
                  widget.quoteModel.mandate.toLowerCase().contains('ondemand') ? LocaleKey.onDemand : LocaleKey.lease)),
          SizedBox(
            height: 10,
          ),
          createTypes(
              AppLocalizations.getLocalizationValue(this.locale, LocaleKey.loadType),
              AppLocalizations.getLocalizationValue(
                  this.locale,
                  widget.quoteModel.load.toLowerCase().contains('partial')
                      ? LocaleKey.partialTruk
                      : LocaleKey.fullTruk)),
          SizedBox(
            height: 10,
          ),
          createTypes(
              AppLocalizations.getLocalizationValue(this.locale, LocaleKey.trukType),
              AppLocalizations.getLocalizationValue(this.locale,
                  widget.quoteModel.truk.toLowerCase().contains('closed') ? LocaleKey.closedTruk : LocaleKey.openTruk)),
        ],
      ),
    );
  }

  Widget createTypes(String heading, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$heading',
            style: TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          '$value',
          style: TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget createLocationBlock(Size size, int type) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xfff8f8f8),
      ),
      child: Text(
        type == 0 ? sourceAddress : destinationAddress,
      ),
    );
  }
  Widget createDateBlock() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xfff8f8f8),
      ),
      child: Text(
        widget.quoteModel.pickupDate
      ),
    );
  }
}
