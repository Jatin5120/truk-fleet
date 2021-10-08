import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/driver/pages/driver_homepage.dart';
import 'package:truk_fleet/screens/fleetSelection_screen.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/no_data_page.dart';

class BlockedUserPage extends StatefulWidget {
  @override
  _BlockedUserPageState createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUserPage> {
  @override
  void initState() {
    super.initState();
    //Provider.of<MyDriverUser>(context, listen: false).getUserFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text('Blocked'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: primaryColor),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (context) => FleetSelection(),
                ),
                (b) => false,
              );
            },
          )
        ],
      ),
      body: NoDataPage(
        text: 'Blocked by Company',
      ),
    );
  }
}
