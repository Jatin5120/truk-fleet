import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/company/controller/chat_controller.dart';
import 'package:truk_fleet/company/pages/support.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/chatting_list_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/no_data_page.dart';

class ChatFragment extends StatefulWidget {
  @override
  ChatFragmentState createState() => ChatFragmentState();
}

class ChatFragmentState extends State<ChatFragment> {
  Locale locale;

  Widget messageTile(ChattingListModel chattingListModel) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => Support(
              chatListModel: chattingListModel,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3.5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Center(
                  child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.account_circle)),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chattingListModel.userModel.name.toUpperCase(),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            FutureBuilder<String>(
                              future: Helper().setLocationText(
                                  chattingListModel.quoteModel.source),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Text('Address...');
                                }
                                return Text(
                                  snapshot.data.split(",")[2] ??
                                      snapshot.data.split(",")[3],
                                );
                              },
                            ),
                            Text("-"),
                            Expanded(
                              child: FutureBuilder<String>(
                                future: Helper().setLocationText(
                                    chattingListModel.quoteModel.destination),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text('Address...');
                                  }
                                  return Text(
                                    snapshot.data.split(",")[2] ??
                                        snapshot.data.split(",")[3],
                                    maxLines: 1,
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chattingListModel.quoteModel.pickupDate,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        chattingListModel.quoteModel.trukName,
                        style: TextStyle(color: primaryColor, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    final pChatList = Provider.of<ChatController>(context);
    return Container(
      height: size.height,
      width: size.width,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: pChatList.isChatLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : (pChatList.chattings.length <= 0
              ? NoDataPage(
                  text: AppLocalizations.getLocalizationValue(
                      locale, LocaleKey.noData),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: pChatList.chattings.length,
                  itemBuilder: (context, index) {
                    final ChattingListModel chattingListModel =
                        pChatList.chattings[index];
                    return messageTile(chattingListModel);
                  },
                )),
    );
  }
}
