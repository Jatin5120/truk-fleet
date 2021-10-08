import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:truk_fleet/models/chatting_model.dart';

class MessageHelper {
  final User user = FirebaseAuth.instance.currentUser;
  Future<void> sendMessage(String message, String receiver, int bookingId, bool isVendor) async {
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    ChattingModel model = ChattingModel(
      isVendor: isVendor,
      bookingId: bookingId,
      isSeen: false,
      message: message,
      receiver: receiver,
      sender: user.uid,
      time: currentTime,
    );

    updateChatList(user.uid, true, currentTime, bookingId, receiver);
    updateChatList(receiver, false, currentTime, bookingId, user.uid);

    CollectionReference reference = FirebaseFirestore.instance.collection(FirebaseHelper.chatCollection);
    await reference.add(model.toMap());
  }

  updateChatList(String id, bool isVendor, int time, int bookingId, String receiver) async {
    CollectionReference referenceChatList = FirebaseFirestore.instance
        .collection(isVendor ? FirebaseHelper.fleetOwnerCollection : FirebaseHelper.userCollection)
        .doc(id)
        .collection(FirebaseHelper.chatListCollection);

    await referenceChatList.doc("$receiver$bookingId").set({
      'bookingId': bookingId,
      'clientId': receiver,
      'time': time,
    });
  }
}
