import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/utils/constants.dart';

class MyPayoutPage extends StatefulWidget {
  @override
  _MyPayoutPageState createState() => _MyPayoutPageState();
}

class _MyPayoutPageState extends State<MyPayoutPage> {
  Locale locale;
  final User user = FirebaseAuth.instance.currentUser;
  int totalIncome = 0;
  int cod = 0;
  int online = 0;
  int payoutReceived = 0;
  int remainingPayout = 0;
  bool isLoading = true;

  getData() async {
    await FirebaseFirestore.instance
        .collection(FirebaseHelper.shipment)
        .where('agent', isEqualTo: user.uid)
        .get()
        .then((value) {
      for (var d in value.docs) {
        if (d.get('paymentStatus').toString().toLowerCase() == 'cod') {
          setState(() {
            totalIncome = totalIncome + int.parse(d.get('price'));
            cod = cod + int.parse(d.get('price'));
          });
        } else {
          setState(() {
            totalIncome = totalIncome + int.parse(d.get('price'));
            online = online + int.parse(d.get('price'));
          });
        }
      }
    });
    await FirebaseFirestore.instance
        .collection(FirebaseHelper.payoutCollection)
        .where('user', isEqualTo: user.uid)
        .get()
        .then((value) {
      for (var e in value.docs) {
        setState(() {
          payoutReceived = payoutReceived + int.parse(e.get('amount'));
        });
      }
    });
    setState(() {
      remainingPayout = totalIncome - (cod + payoutReceived);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.getLocalizationValue(locale, LocaleKey.myPayout),
          style: TextStyle(color: primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : PendingPayout(
              totalIncome: totalIncome,
              cod: cod,
              online: online,
              payoutReceived: payoutReceived,
              remainingPayout: remainingPayout,
            ),
    );
  }
}

class PendingPayout extends StatefulWidget {
  const PendingPayout({
    Key key,
    @required this.totalIncome,
    @required this.cod,
    @required this.online,
    @required this.payoutReceived,
    @required this.remainingPayout,
  }) : super(key: key);

  final int totalIncome;
  final int cod;
  final int online;
  final int payoutReceived;
  final int remainingPayout;

  @override
  State<PendingPayout> createState() => _PendingPayoutState();
}

class _PendingPayoutState extends State<PendingPayout> {
  List<Map<String, dynamic>> _payouts;

  @override
  void initState() {
    super.initState();
    _payouts = [
      {
        'title': 'Net Income',
        'value': widget.totalIncome,
        'icon': Icons.account_balance_wallet_rounded,
      },
      {
        'title': 'COD',
        'value': widget.cod,
        'icon': Icons.local_atm_rounded,
      },
      {
        'title': 'Online payments',
        'value': widget.online,
        'icon': Icons.paid_outlined,
      },
      {
        'title': 'Payment Received',
        'value': widget.payoutReceived,
        'icon': Icons.price_check_rounded,
      },
      {
        'title': 'Payment Due',
        'value': widget.remainingPayout,
        'icon': Icons.payments_outlined,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (Map<String, dynamic> payout in _payouts) ...[
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.only(top: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                    child: Icon(
                      payout['icon'],
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    payout['title'],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Rs. ${payout['value']} /-',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
