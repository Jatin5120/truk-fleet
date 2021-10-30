import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/driver/pages/driver_homepage.dart';
import 'package:truk_fleet/driver/pages/inride_page.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart' as sg;
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:truk_fleet/utils/constants.dart';

class Email {
  static String mailToken =
      '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';

  static const String driverAssignedTemplateID =
      "d-abb7173c4c264e74a85aa69b6a145ab7";
  static const String shipmentStartTemplateID =
      "d-153e98f8cac54374b1c9d3357e64516e";
  static const String shipmentCompleteTemplateID =
      "d-9644068b03e9448daa384f4843f85ffa";

  sendShipmentCompleteMail(ShipmentModel model, inv, context) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Text("Updating...."), CircularProgressIndicator()],
                ),
              ),
            ));
    String dest = await Helper().setLocationText(model.destination);

    await FirebaseFirestore.instance
        .collection(FirebaseHelper.driverCollection)
        .doc(model.driver)
        .update({'cstatus': true}).then((value) async {
      String userMail;
      String userName;
      await FirebaseFirestore.instance
          .collection(FirebaseHelper.userCollection)
          .doc(model.uid)
          .get()
          .then((value) {
        UserModel um = UserModel.fromSnapshot(value);
        userMail = um.email;
        userName = um.name;
      });
      await FirebaseFirestore.instance
          .collection(FirebaseHelper.shipment)
          .doc(Utils.currentShipmentId)
          .update({'driverId': null});
      try {
        final mailer = sg.Mailer(mailToken);
        // final mailer = sg.Mailer('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');
        final toAddress = sg.Address(userMail);
        final fromAddress = sg.Address('info@trukapp.com');
        final subject = 'SHIPMENT COMPLETED';
        Map<String, dynamic> dd = {
          'userName': userName,
          'destination': dest,
          'invoiceUrl': inv,
        };
        final personalization =
            sg.Personalization([toAddress], dynamicTemplateData: dd);
        final email = sg.Email([personalization], fromAddress, subject,
            templateId: shipmentCompleteTemplateID);
        // templateId: "d-9644068b03e9448daa384f4843f85ffa");
        mailer.send(email).then((result) {
          // ...
          print('mail sent: ${result.asError.error.toString()}');
        });
      } catch (e) {
        print("ERRRORR: $e");
      }
    });
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DriverHomeScreen(),
      ),
      (route) => false,
    );
  }

  sendShipmentStartMail(ShipmentModel model, context) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Text("Updating...."), CircularProgressIndicator()],
                ),
              ),
            ));
    String source = await Helper().setLocationText(model.source);
    DateTime st = DateTime.fromMillisecondsSinceEpoch(model.bookingDate);
    await FirebaseFirestore.instance
        .collection(FirebaseHelper.driverCollection)
        .doc(model.driver)
        .update({'cstatus': true}).then((value) async {
      String userMail;
      String userName;
      await FirebaseFirestore.instance
          .collection(FirebaseHelper.userCollection)
          .doc(model.uid)
          .get()
          .then((value) {
        UserModel um = UserModel.fromSnapshot(value);
        userMail = um.email;
        userName = um.name;
      });
      try {
        try {
          final mailer = sg.Mailer(mailToken);
          // final mailer = sg.Mailer('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');
          final toAddress = sg.Address(userMail);
          final fromAddress = sg.Address('info@trukapp.com');
          final subject = 'SHIPMENT STARTED';
          Map<String, dynamic> dd = {
            'userName': userName,
            'source': source,
            'orderNumber': model.bookingId,
            'shippingDate': st,
          };
          final personalization =
              sg.Personalization([toAddress], dynamicTemplateData: dd);
          final email = sg.Email([personalization], fromAddress, subject,
              templateId: shipmentStartTemplateID);
          // templateId: "d-153e98f8cac54374b1c9d3357e64516e");
          mailer.send(email).then((result) {
            // ...
            print('mail sent: ${result.asError.error.toString()}');
          });
        } catch (e) {
          print("Error: $e");
        }
      } catch (e) {
        print("ERRRORR: $e");
      }
    });
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => InRidePage(
          model: model,
        ),
      ),
    );
  }

  sendDriverAssignedMail(
      DriverModel model, context, email, QuoteModel quoteModel) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Text("Updating...."), CircularProgressIndicator()],
                ),
              ),
            ));
    String userName;
    String userMail;
    DriverModel dr;
    await FirebaseFirestore.instance
        .collection(FirebaseHelper.userCollection)
        .doc(quoteModel.uid)
        .get()
        .then((value) {
      UserModel u = UserModel.fromSnapshot(value);
      userName = u.name;
      userMail = u.email;
    });
    await FirebaseFirestore.instance
        .collection(FirebaseHelper.driverCollection)
        .where('uid', isEqualTo: model.uid)
        .get()
        .then((value) {
      for (var d in value.docs) {
        dr = DriverModel.fromSnapshot(d);
        d.reference.update({'cstatus': false}).then((value) async {
          try {
            final mailer = sg.Mailer(mailToken);
            // final mailer = sg.Mailer('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');

            final toAddress = sg.Address(userMail);
            final fromAddress = sg.Address('info@trukapp.com');
            final subject = 'DRIVER ASSIGNED';
            Map<String, dynamic> dd = {
              'userName': userName,
              'id': quoteModel.bookingId,
              'driverName': dr.name,
              'driverPhone': dr.mobile
            };
            final personalization =
                sg.Personalization([toAddress], dynamicTemplateData: dd);
            final email = sg.Email([personalization], fromAddress, subject,
                templateId: driverAssignedTemplateID);
            // templateId: "d-abb7173c4c264e74a85aa69b6a145ab7");
            mailer.send(email).then((result) {
              // ...
              if (result.isValue)
                print('mail sent: ${result.asValue.toString()}');
              else if (result.isError)
                print('mail error: ${result.asError.toString()}');
              else
                print("Something Unknown");
            });
          } catch (e) {
            print("Error: $e");
          }
        });
      }
    });
  }
}
