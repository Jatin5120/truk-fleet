import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/models/chatting_list_model.dart';
import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class ChatController with ChangeNotifier {
  final User user = FirebaseAuth.instance.currentUser;
  List<ChattingListModel> chatList = [];
  List<ChattingListModel> get chattings => chatList;
  bool isChatLoading = true;
  getAllMessages() async {
    isChatLoading = true;
    CollectionReference userRef = FirebaseFirestore.instance.collection(FirebaseHelper.userCollection);
    Stream<QuerySnapshot> snap = FirebaseFirestore.instance
        .collection(FirebaseHelper.fleetOwnerCollection)
        .doc(user.uid)
        .collection(FirebaseHelper.chatListCollection)
        .orderBy('time', descending: true)
        .snapshots();

    snap.listen((event) async {
      chatList = [];
      if (event.size > 0) {
        for (QueryDocumentSnapshot snapshot in event.docs) {
          String otherUser = snapshot.get('clientId');
          int bookingId = snapshot.get('bookingId');
          final doc = await userRef.doc(otherUser).get();
          UserModel userModel = UserModel.fromSnapshot(doc);
          final bookingSnap = await FirebaseFirestore.instance
              .collection(FirebaseHelper.quoteCollection)
              .where('bookingId', isEqualTo: bookingId)
              .snapshots()
              .first;
          try {
            final bookingDoc = QuoteModel.fromSnapshot(bookingSnap.docs[0]);
            chatList.add(ChattingListModel(id: snapshot.id, quoteModel: bookingDoc, userModel: userModel));
          } catch (e) {
            Fluttertoast.showToast(msg: "Please restart the app! Some Error occurred");
          }
        }
      }
      chatList = chatList.distinct();
      isChatLoading = false;
      notifyListeners();
    });
  }
}
