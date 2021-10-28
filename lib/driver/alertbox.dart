import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/payment_type.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/utils/constants.dart';

class AB extends StatefulWidget {
  final ShipmentModel model;
  const AB({@required this.model});
  @override
  _ABState createState() => _ABState();
}

class _ABState extends State<AB> {
  bool isLoading = false;
  TextEditingController amount = new TextEditingController();
  var advance = 0.0;
  Locale locale;
  @override
  void initState() {
    isLoading = true;
    Future<QuerySnapshot> re = FirebaseFirestore.instance
        .collection("Quote")
        .where('bookingId', isEqualTo: widget.model.bookingId)
        .get();
    re.then((value) {
      print(value.docs.length);
      if (value.docs.length > 0) {
        setState(() {
          isLoading = false;
        });
        QuoteModel quoteModel = QuoteModel.fromSnapshot(value.docs[0]);
        if (quoteModel.advance > 0.0 &&
            widget.model.paymentStatus == PaymentType.cod) {
          setState(() {
            advance = quoteModel.advance;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: TextField(
              controller: amount,
              decoration: InputDecoration(
                hintText: "Enter Amount",
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "*** Amount should be between $advance to ${widget.model.price}",
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${AppLocalizations.getLocalizationValue(locale, LocaleKey.paymentConfirmation)}",
                          style: TextStyle(
                              color: primaryColor,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () {
              double payableAmount = double.parse(amount.text);
              print('payableAmount ${payableAmount}');
              print('advance ${advance}');
              if (payableAmount < advance) {
                Fluttertoast.showToast(
                    msg: 'Please collect full advance payment');
              } else {
                widget.model.status == 'pending'
                    ? _pay(widget.model, advance)
                    : Fluttertoast.showToast(msg: "Trip Already Started");
              }
            },
            style: ElevatedButton.styleFrom(
              primary:
                  widget.model.status == 'pending' ? primaryColor : Colors.grey,
            ),
            child: Text(
                AppLocalizations.getLocalizationValue(locale, LocaleKey.done)),
          )
        ],
      ),
    );
  }

  _pay(ShipmentModel model, double advance) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Processing...."),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            ));
    if (amount.text.isEmpty) {
      Fluttertoast.showToast(msg: "Amount not received");
      Navigator.pop(context);
      Navigator.pop(context);
    }
    if (double.parse(amount.text) >= advance &&
        int.parse(amount.text) <= int.parse(model.price)) {
      FirebaseFirestore.instance
          .collection(FirebaseHelper.shipment)
          .doc(model.id)
          .get()
          .then((value) {
        value.reference.update({'amountPaid': amount.text});
      });
      Fluttertoast.showToast(msg: "Amount received : ${amount.text}");
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "Please Enter Valid Amount received amount");
      Navigator.pop(context);
    }
  }
}
