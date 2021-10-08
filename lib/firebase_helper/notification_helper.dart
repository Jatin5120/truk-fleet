import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationHelper {
  final User user = FirebaseAuth.instance.currentUser;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void registerNotification({String doc}) async {
    await firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        //})(onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
        AndroidNotification androidNotification = message.notification?.android;
        AppleNotification appleNotification = message.notification?.apple;
        if (message.notification != null &&
            (Platform.isAndroid
                ? androidNotification != null
                : appleNotification != null)) {
          Platform.isAndroid
              ? showNotification(message.notification)
              : showNotification(message.notification);
        }
      },
      // onResume: (Map<String, dynamic> message) {
      //   print('onResume: $message');
      //   return;
      // }, onLaunch: (Map<String, dynamic> message) {
      //   print('onLaunch: $message');
      //   return;
      // }
    );
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      //Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
    });
    firebaseMessaging.getToken().then((token) {
      //print('token: $token');
      FirebaseFirestore.instance
          .collection(doc)
          .doc(user.uid)
          .update({'token': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteNotification notification) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'com.augmentik.trukapp' : 'com.augmentik.trukappios',
      'TruK',
      channelDescription: 'Notification from TruK Fleet',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);
    //String title = Platform.isAndroid ? androidNotification.t
    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title.toString(),
      notification.body.toString(),
      platformChannelSpecifics,
      payload: json.encode(notification),
    );
  }
}
