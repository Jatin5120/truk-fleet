import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:truk_fleet/Invoice%20Handler/Invoice%20model/invoice.dart';
import 'package:truk_fleet/Invoice%20Handler/page/pdf_page.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/emailHelper.dart';
import 'package:truk_fleet/helper/payment_type.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/utils/constants.dart';

class FinalPaymentScreen extends StatefulWidget {
  final ShipmentModel model;
  const FinalPaymentScreen({Key key, this.model}) : super(key: key);

  @override
  _FinalPaymentScreenState createState() => _FinalPaymentScreenState();
}

class _FinalPaymentScreenState extends State<FinalPaymentScreen> {
  bool isLoading = true;
  String paymentRemaining = "0";
  List<InvoiceItem> items = [];
  String user;
  @override
  void initState() {
    Future<QuerySnapshot> re = FirebaseFirestore.instance
        .collection("Quote")
        .where('bookingId', isEqualTo: widget.model.bookingId)
        .get();
    re.then((value) {
      isLoading = false;
      print(value.docs.length);
      if (value.docs.length > 0) {
        QuoteModel quoteModel = QuoteModel.fromSnapshot(value.docs[0]);
        if (widget.model.paymentStatus == PaymentType.cod) {
          if (quoteModel.advance > 0.0)
            paymentRemaining =
                (double.parse(widget.model.price) - quoteModel.advance)
                    .toString();
          else
            paymentRemaining = widget.model.price;
        }
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircularProgressIndicator(),
                          Text("Generating invoice . . . ."),
                        ],
                      ),
                    ),
                  ),
                );
                await FirebaseFirestore.instance
                    .collection(FirebaseHelper.userCollection)
                    .doc(widget.model.uid)
                    .get()
                    .then((value) {
                  setState(() {
                    user = value.get('name');
                  });
                });
                for (var m in widget.model.materials) {
                  setState(
                    () {
                      items.add(
                        InvoiceItem(
                          quantity: m.quantity,
                          name: m.materialName,
                          type: m.materialType,
                          mode: widget.model.paymentStatus,
                          total: widget.model.price,
                        ),
                      );
                    },
                  );
                }
                await PdfPage().generateInvoice(widget.model, user, items);
                Navigator.pop(context);
                String inv;
                await FirebaseFirestore.instance
                    .collection(FirebaseHelper.invoiceCollection)
                    .where('id', isEqualTo: widget.model.id)
                    .get()
                    .then((value) {
                  for (var data in value.docs) {
                    setState(() {
                      inv = data['invoice'];
                    });
                  }
                });
                Email().sendShipmentCompleteMail(widget.model, inv, context);
                await FirebaseFirestore.instance
                    .collection(FirebaseHelper.driverCollection)
                    .doc(widget.model.driverId)
                    .update({'isAvailable': true});
              },
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
              ),
              child: Text("Done"),
            ),
          ),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Remaining payment to be taken : ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              widget.model.amountPaid == null
                  ? Text(
                      "\u20b9$paymentRemaining",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      "\u20b9${(double.parse(widget.model.price) - double.parse(widget.model.amountPaid))}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
