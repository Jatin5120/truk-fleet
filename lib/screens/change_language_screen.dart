import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truk_fleet/locale/language_bloc/language_bloc.dart';
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
import 'package:truk_fleet/utils/constants.dart';

class ChangeLanguageScreen extends StatefulWidget {
  @override
  _ChangeLanguageScreenState createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  final List<Map<String, dynamic>> langList = [
    {'title': 'English', 'locale': SharedPref.en},
    {'title': 'हिन्दी', 'locale': SharedPref.hi},
    {'title': 'తెలుగు', 'locale': SharedPref.te},
  ];
  int selectedIndex = -1;
  bool isLoaded = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Change Language'),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.only(top: 25),
        child: BlocBuilder<LanguageBloc, Language>(
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: langList.length,
              itemBuilder: (context, index) {
                if (!isLoaded) {
                  if (snapshot.locale == langList[index]['locale']) {
                    selectedIndex = index;
                  }
                }
                print(selectedIndex);
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: const EdgeInsets.all(0),
                    onTap: () {
                      isLoaded = true;
                      BlocProvider.of<LanguageBloc>(context)
                        ..add(LanguageSelected(Language(langList[index]['locale'])));
                      selectedIndex = index;
                      setState(() {});
                      Navigator.pop(context);
                    },
                    title: Card(
                      shadowColor: selectedIndex == index ? primaryColor : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 12,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 60,
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: selectedIndex == index ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              child: selectedIndex == index
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : Container(),
                            ),
                            Expanded(
                              child: Text(
                                langList[index]['title'],
                                style: TextStyle(
                                    color: selectedIndex == index ? Colors.white : Colors.black, fontSize: 18),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
