import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/controller/my_shipment_controller.dart';
import 'package:truk_fleet/company/controller/request_controller.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/shipment_model.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Map<String, dynamic>> gridList = [];
  List<Map<String, dynamic>> shipmentGridList = [];
  List<Map<String, dynamic>> myList;
  int quotes = 0;
  int rejectedQuotes = 0;
  int acceptedQuotes = 0;
  int totalShipment = 0;
  int completedShipment = 0;
  int pendingShipment = 0;
  int transitShipment = 0;
  int pendingQuotes = 0;
  Locale locale;
  @override
  Widget build(BuildContext context) {
    final pQuotes = Provider.of<MyRequest>(context);
    final pShips = Provider.of<FleetRideModel>(context);
    locale = AppLocalizations.of(context).locale;
    final Size size = MediaQuery.of(context).size;
    gridList = [];
    rejectedQuotes = 0;
    acceptedQuotes = 0;
    totalShipment = 0;
    completedShipment = 0;
    pendingShipment = 0;
    pendingQuotes = 0;
    transitShipment = 0;
    quotes = pQuotes.quotes.length;
    totalShipment = pShips.shipments.length;
    for (QuoteModel q in pQuotes.quotes) {
      if (q.status == RequestStatus.rejected) {
        rejectedQuotes += 1;
      }
      if (q.status == RequestStatus.accepted) {
        acceptedQuotes += 1;
      }
      if (q.status == RequestStatus.pending) {
        pendingQuotes += 1;
      }
    }
    for (ShipmentModel s in pShips.shipments) {
      if (s.status == RequestStatus.started) {
        transitShipment = transitShipment + 1;
      }
      if (s.status == RequestStatus.pending) {
        pendingShipment = pendingShipment + 1;
      }
      if (s.status == RequestStatus.completed) {
        completedShipment = completedShipment + 1;
      }
    }

    gridList = [
      {
        'title': 'Total Quotes Made',
        'count': '${pQuotes.quotes.length}',
        'color': Colors.blue
      },
      {
        'title': 'Quotes Rejected',
        'count': '$rejectedQuotes',
        'color': Colors.red
      },
      {
        'title': 'Quotes Accepted',
        'count': '$acceptedQuotes',
        'color': Colors.green.shade600
      },
      {
        'title': 'Quotes Pending',
        'count': '$pendingQuotes',
        'color': Colors.yellow.shade900
      }
    ];

    shipmentGridList = [
      {
        'title': 'Total Shipments',
        'count': '$totalShipment',
        'color': Colors.blue
      },
      {
        'title': 'In Transit Shipments',
        'count': '$transitShipment',
        'color': Colors.yellow.shade900
      },
      {
        'title': 'Pending Shipments',
        'count': '$pendingShipment',
        'color': Colors.purple.shade600
      },
      {
        'title': 'Completed Shipment',
        'count': '$completedShipment',
        'color': Colors.green.shade600
      },
    ];
    myList = [
      {"title": "Quote Stats", "list": gridList},
      {"title": "Shipment Stats", "list": shipmentGridList}
    ];
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: ListView.separated(
          itemCount: myList.length,
          shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(
                thickness: 1.5,
              ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10, left: 5),
                  child: Text(
                    myList[index]["title"],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount:
                      index == 0 ? gridList.length : shipmentGridList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 5).copyWith(bottom: 15),
                  itemBuilder: (context, i) {
                    List<Map<String, dynamic>> d = myList[index]["list"];
                    Color _color = d[i]['color'];
                    String _title = d[i]['title'];
                    String _count = d[i]['count'];
                    return Container(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: _color,
                        color: _color,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            Text(
                              _count,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }),
    );
  }
}
