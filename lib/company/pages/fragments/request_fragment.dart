import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/controller/request_controller.dart';
import 'package:truk_fleet/company/pages/send_quote.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/material_model.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/request_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:truk_fleet/utils/no_data_page.dart';
import '../../../utils/constants.dart';

class RequestFragment extends StatefulWidget {
  @override
  _RequestFragmentState createState() => _RequestFragmentState();
}

class _RequestFragmentState extends State<RequestFragment> {
  final User user = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> filteredList = [];
  bool isFilter = false;
  List<Map<String, dynamic>> myList = [];
  Locale locale;
  RequestModel prevReq;
  List<QuoteModel> quotesList = [];

  @override
  void initState() {
    //Provider.of<MyRequest>(context, listen: false).getRequestList();

    final b = Provider.of<MyRequest>(context, listen: false);
    b.getQuoteList();
    super.initState();
  }

  var _radioValue = 'all';
  void _handleRadioValueChange(String value) {
    //final pRequest = Provider.of<MyRequest>(context);
    // for (QuoteModel element in quotesList) {
    //   if(element.bookingId == )
    // }
    switch (value) {
      case 'all':
        isFilter = false;
        filteredList = [];
        break;
      case LocaleKey.cancelled:
        isFilter = true;
        filteredList = [];
        print('Enter filter cancelled');
        print('Enter filter cancelled ${LocaleKey.cancelled}');
        filteredList = myList
            .where(
                (element) => element['request'].status == LocaleKey.cancelled)
            .toList();
        break;
      case LocaleKey.accepted:
        isFilter = true;
        filteredList = [];
        filteredList = myList
            .where(
                (element) => (element['request'].status == LocaleKey.accepted))
            .toList();
        break;
      case LocaleKey.rejected:
        isFilter = true;
        filteredList = [];
        filteredList = myList
            .where(
                (element) => (element['request'].status == LocaleKey.rejected))
            .toList();
        break;

      case LocaleKey.pending:
        isFilter = true;
        filteredList = [];
        filteredList = myList
            .where((element) =>
                (element['request'].status != LocaleKey.accepted &&
                    element['request'].status != LocaleKey.cancelled &&
                    element['request'].status != LocaleKey.rejected))
            .toList();
        break;
      // default:
      //   isFilter = false;
      //   filteredList = [];
      //   break;
    }
    _radioValue = value;
    setState(() {});
  }

  Future<String> getAdress(LatLng lateLng) async {
    final coordinates = Coordinates(lateLng.latitude, lateLng.longitude);
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    String street = address.first.featureName;
    String area = address.first.subLocality;
    String pincode = address.first.postalCode;
    String city = address.first.subAdminArea;
    return '$street, $area, $city, $pincode';
  }

  getLocation(RequestModel requestModel, String string) async {
    bool isTrack = false;
    var address = await getAdress(requestModel.source);
    if (address.toLowerCase().contains(string.toLowerCase())) {
      isTrack = true;
    }
    print('IsTrack is $isTrack');
    return isTrack;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pRequest = Provider.of<MyRequest>(context);

    locale = AppLocalizations.of(context).locale;
    myList = pRequest.requests;
    print('YOur filter list ---> ${filteredList.length}');
    print('YOur filter list ---> ${filteredList}');
    quotesList = pRequest.quotes;
    return Container(
      height: size.height,
      width: size.width,
      padding: const EdgeInsets.all(16),
      child: pRequest.requests.length <= 0
          ? NoDataPage(
              text: AppLocalizations.getLocalizationValue(
                  locale, LocaleKey.noQuotesRequested),
            )
          : Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (string) async {
                          if (string.trim().length <= 0 || string.isEmpty) {
                            setState(() {
                              isFilter = false;
                              filteredList = [];
                            });
                          } else {
                            setState(() {
                              filteredList = pRequest.requests.where((element) {
                                if (element['request']
                                        .bookingId
                                        .toString()
                                        .contains(
                                            string.trim().toLowerCase()) ||
                                    element['request']
                                        .pickupDate
                                        .contains(string.toLowerCase())) {
                                  return true;
                                }

                                if (element['user']
                                    .name
                                    .toLowerCase()
                                    .contains(string.toLowerCase()))
                                  return true;

                                if (element['request']
                                    .destinationString
                                    .toLowerCase()
                                    .contains(string.toLowerCase()))
                                  return true;

                                if (element['request']
                                    .sourceString
                                    .toLowerCase()
                                    .contains(string.toLowerCase()))
                                  return true;
                                return false;
                              }).toList();
                              isFilter = true;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.getLocalizationValue(
                              locale, LocaleKey.searchHint),
                          border: OutlineInputBorder(),
                          labelText: AppLocalizations.getLocalizationValue(
                              locale, LocaleKey.search),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.filter_alt_rounded),
                        onPressed: () {
                          Widget dialog = AlertDialog(
                            backgroundColor: Colors.white,
                            elevation: 8,
                            title: Text(
                              "Filter Requests",
                              style: TextStyle(
                                fontFamily: 'Maven',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                RadioListTile(
                                  activeColor: Colors.green,
                                  value: 'all',
                                  title: Text("All"),
                                  groupValue: _radioValue,
                                  onChanged: (a) {
                                    _handleRadioValueChange(a);
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Colors.green,
                                  value: LocaleKey.pending,
                                  title: Text("Pending"),
                                  groupValue: _radioValue,
                                  onChanged: (a) {
                                    _handleRadioValueChange(a);
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Colors.green,
                                  value: LocaleKey.accepted,
                                  title: Text("Accepted"),
                                  groupValue: _radioValue,
                                  onChanged: (a) {
                                    _handleRadioValueChange(a);
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Colors.green,
                                  value: LocaleKey.rejected,
                                  title: Text("Rejected"),
                                  groupValue: _radioValue,
                                  onChanged: (a) {
                                    _handleRadioValueChange(a);
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Colors.green,
                                  value: LocaleKey.cancelled,
                                  title: Text("Cancelled"),
                                  groupValue: _radioValue,
                                  onChanged: (a) {
                                    _handleRadioValueChange(a);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                          showGeneralDialog(
                              context: context,
                              pageBuilder: (context, anim1, anim2) => dialog,
                              barrierDismissible: true,
                              barrierLabel: '',
                              transitionBuilder:
                                  (context, anim1, anim2, child) {
                                return Transform.scale(
                                  scale: anim1.value,
                                  origin: Offset(
                                      MediaQuery.of(context).size.width * 0.5,
                                      -200),
                                  child: child,
                                );
                              },
                              transitionDuration: Duration(milliseconds: 400));
                        }),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: isFilter
                        ? filteredList.length
                        : pRequest.requests.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = isFilter
                          ? filteredList[index]
                          : pRequest.requests[index];
                      // print('Your data is ${data}');
                      UserModel userModel = data['user'];
                      RequestModel requestModel = data['request'];
                      QuoteModel quoteModel;

                      // print('element is ${pRequest.quoteList}');

                      for (QuoteModel element in pRequest.quotes) {
                        // print('QuoteModel is ${requestModel.bookingId}');
                        // print('condition is ${element.bookingId == requestModel.bookingId}');
                        if (element.bookingId == requestModel.bookingId) {
                          log("Element --> ${element.truk}");
                          quoteModel = element;
                          break;
                        }
                      }
                      return buildRequestCard(
                          requestModel, userModel, quoteModel);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildRequestCard(
      RequestModel requestModel, UserModel userModel, QuoteModel quoteModel) {
    String status = RequestStatus.pending;
    String paymentStatus = '';
    if (quoteModel != null) {
      print('Quet function ${quoteModel.paymentStatus}');
      paymentStatus = quoteModel.paymentStatus;
      status = quoteModel.status;
      if (status == RequestStatus.assigned) {
        return Container();
      }
    }
    double weight = 0;
    for (MaterialModel val in requestModel.materials) {
      weight += val.quantity;
    }
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userModel.name}, $paymentStatus",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  FutureBuilder<String>(
                      future: Helper().setLocationText(requestModel.source),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text('Address...');
                        }
                        return Text(
                          "${snapshot.data.split(',')[2].trimLeft()}" ?? "",
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        );
                      }),
                  FutureBuilder<String>(
                      future:
                          Helper().setLocationText(requestModel.destination),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text('|');
                        }
                        return Text(
                          "|\n${snapshot.data.split(',')[2].trimLeft()}" ?? "",
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        );
                      }),
                  SizedBox(height: 5),
                  Text(
                    "${AppLocalizations.getLocalizationValue(locale, LocaleKey.quantity)} - $weight KG",
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      buildQuoteButton(() {
                        log("Quote --> $quoteModel");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SendQuote(
                                keyTitle: 'quote',
                                quoteModel: quoteModel,
                                requestModel: requestModel,
                                requestUser: userModel,
                              ),
                            ));
                      }, 'Quote', status),
                      quoteModel == null
                          ? Container()
                          : Expanded(
                              child: Center(
                                child: Text(
                                  "\u20B9 ${quoteModel.price}",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            )
                    ],
                  )
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "ID ${requestModel.bookingId}",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${requestModel.pickupDate}",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppLocalizations.getLocalizationValue(
                      locale,
                      requestModel.truk.toLowerCase().contains('closed')
                          ? LocaleKey.closedTruk
                          : LocaleKey.openTruk),
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${AppLocalizations.getLocalizationValue(locale, LocaleKey.insurance)} : ${requestModel.insured ? AppLocalizations.getLocalizationValue(locale, LocaleKey.yes) : AppLocalizations.getLocalizationValue(locale, LocaleKey.no)}",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: buildAssignDriverButton(
                    status,
                    () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => SendQuote(
                            keyTitle: 'assign',
                            quoteModel: quoteModel,
                            requestModel: requestModel,
                            requestUser: userModel,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildQuoteButton(Function onPressed, String title, String status) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: ElevatedButton(
        onPressed: RequestStatus.pending == status ? onPressed : null,
        style: ElevatedButton.styleFrom(
          primary: getColor(status),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Center(
          child: Text(
            getButtonText(status) ?? status,
            style: TextStyle(
              color: RequestStatus.pending == status
                  ? Colors.white
                  : getColor(status),
            ),
          ),
        ),
      ),
    );
  }

  buildAssignDriverButton(String status, Function onPressed) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          primary: Colors.blue,
        ),
        onPressed:
            status == RequestStatus.accepted && status != RequestStatus.assigned
                ? onPressed
                : null,
        child: Center(
          child: Text(
            AppLocalizations.getLocalizationValue(
                locale, LocaleKey.assignDriver),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color getColor(String status) {
    switch (status) {
      case RequestStatus.pending:
        return greenButtonColor;
      case RequestStatus.rejected:
      case RequestStatus.cancelled:
        return Colors.red;
      case RequestStatus.accepted:
      case RequestStatus.quoted:
      default:
        return greenButtonColor;
    }
  }

  String getButtonText(String status) {
    switch (status) {
      case RequestStatus.pending:
        return AppLocalizations.getLocalizationValue(locale, LocaleKey.quote);
      case RequestStatus.accepted:
        return AppLocalizations.getLocalizationValue(
            locale, LocaleKey.accepted);
      case RequestStatus.quoted:
        return AppLocalizations.getLocalizationValue(locale, LocaleKey.quoted);
      case RequestStatus.rejected:
        return AppLocalizations.getLocalizationValue(
            locale, LocaleKey.rejected);
      case RequestStatus.assigned:
        return AppLocalizations.getLocalizationValue(
            locale, LocaleKey.assigned);
      case RequestStatus.cancelled:
        //print(AppLocalizations.getLocalizationValue(locale, LocaleKey.cancelled));
        return AppLocalizations.getLocalizationValue(
            locale, LocaleKey.cancelled);
      default:
        return AppLocalizations.getLocalizationValue(locale, LocaleKey.quote);
    }
  }
}
