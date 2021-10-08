import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:truk_fleet/company/controller/message_helper.dart';
import 'package:truk_fleet/company/controller/request_controller.dart';
import 'package:truk_fleet/company/utils/chat_list_row.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/chatting_list_model.dart';
import 'package:truk_fleet/models/chatting_model.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:truk_fleet/utils/no_data_page.dart';

class Support extends StatefulWidget {
  final ChattingListModel chatListModel;

  const Support({Key key, this.chatListModel}) : super(key: key);

  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final User user = FirebaseAuth.instance.currentUser;
  TextStyle senderStyle = TextStyle(color: Colors.black, fontSize: 16);
  TextStyle receiverStyle = TextStyle(color: Colors.white, fontSize: 16);
  Size get size => MediaQuery.of(context).size;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  Locale locale;
  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Widget messageBubble({String message, String time, bool sender}) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
      alignment: sender ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: sender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sender)
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Text(
                '$time',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          Flexible(
            flex: 1,
            child: Material(
              elevation: 3.0,
              shadowColor: Colors.grey,
              type: MaterialType.canvas,
              borderRadius: sender
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
              child: ClipRRect(
                borderRadius: sender
                    ? BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      )
                    : BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
                  child: Align(
                    widthFactor: 1,
                    alignment: sender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      '$message',
                      style: sender ? senderStyle : receiverStyle,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: sender ? Colors.white : primaryColor,
                  ),
                ),
              ),
            ),
          ),
          if (!sender)
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                '$time',
                style: TextStyle(fontSize: 12),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.chatListModel.userModel.name}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraint) => Container(
          child: Container(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                ChatListRow(
                  model: widget.chatListModel,
                  onPriceUpdate: () => showPriceUpdateDialog(),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(FirebaseHelper.chatCollection)
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return NoDataPage(
                          text: 'Error',
                        );
                      }
                      List<QueryDocumentSnapshot> documents = snapshot.data.docs;
                      List<ChattingModel> chats = [];
                      for (QueryDocumentSnapshot d in documents) {
                        ChattingModel model = ChattingModel.fromSnap(d);
                        if (model.receiver == widget.chatListModel.userModel.uid || model.receiver == user.uid) {
                          if (model.sender == widget.chatListModel.userModel.uid || model.sender == user.uid) {
                            if (model.bookingId == widget.chatListModel.quoteModel.bookingId) {
                              chats.add(model);
                            }
                          }
                        }
                      }
                      return documents.length <= 0
                          ? NoDataPage(
                              text: AppLocalizations.getLocalizationValue(locale, LocaleKey.noData),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                ChattingModel m = chats[index];
                                String date = Helper().getFormattedDate(m.time);
                                return messageBubble(message: m.message, sender: m.sender == user.uid, time: date);
                              },
                            );
                    },
                  ),
                ),
                Container(
                  height: 60,
                  color: Colors.white,
                  child: TextFormField(
                    expands: true,
                    cursorColor: Colors.black,
                    controller: _messageController,
                    maxLines: null,
                    minLines: null,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: primaryColor,
                        ),
                        onPressed: () async {
                          String message = _messageController.text.trim();
                          if (message.isEmpty) {
                            Fluttertoast.showToast(msg: "Cannot send empty message");
                            return;
                          }
                          _messageController.clear();
                          await MessageHelper().sendMessage(
                            message,
                            widget.chatListModel.userModel.uid,
                            widget.chatListModel.quoteModel.bookingId,
                            true,
                          );
                        },
                      ),
                      // prefixIcon: IconButton(
                      //   icon: Icon(
                      //     Icons.add,
                      //     color: Colors.black,
                      //   ),
                      //   onPressed: () {},
                      // ),
                      hintText: 'Add text to this message',
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dialogWiget() {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            validator: (String value) {
              if (value.trim().isEmpty || int.parse(value) <= 0) {
                return AppLocalizations.getLocalizationValue(locale, LocaleKey.requiredText);
              }
              return null;
            },
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '₹ ${AppLocalizations.getLocalizationValue(locale, LocaleKey.fare)}'),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: size.width,
            child: RaisedButton(
              color: primaryColor,
              onPressed: () async {
                String price = _priceController.text.trim();
                if (price.length <= 0) {
                  Fluttertoast.showToast(msg: "Please put some price");
                  return;
                }
                if (int.parse(price) <= 0) {
                  Fluttertoast.showToast(msg: "Please put valid price");
                  return;
                }
                Navigator.pop(context);
                await RequestController().updatePrice(widget.chatListModel.quoteModel, price);
                Fluttertoast.showToast(msg: AppLocalizations.getLocalizationValue(locale, LocaleKey.update));
              },
              child: Text(
                '${AppLocalizations.getLocalizationValue(locale, LocaleKey.fare)} ${AppLocalizations.getLocalizationValue(locale, LocaleKey.update)}',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showPriceUpdateDialog() {
    Platform.isAndroid
        ? showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.getLocalizationValue(locale, LocaleKey.fare)} ${AppLocalizations.getLocalizationValue(locale, LocaleKey.update)}"),
                content: Container(child: dialogWiget()),
              );
            },
            barrierDismissible: true)
        : showCupertinoDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    "${AppLocalizations.getLocalizationValue(locale, LocaleKey.fare)} ${AppLocalizations.getLocalizationValue(locale, LocaleKey.update)}"),
                content: Material(
                  child: dialogWiget(),
                  color: Colors.transparent,
                ),
              );
            },
          );
  }
}
