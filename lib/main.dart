import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:truk_fleet/auth/login_navigator.dart';
import 'package:truk_fleet/company/controller/add_driver_controller.dart';
import 'package:truk_fleet/company/controller/chat_controller.dart';
import 'package:truk_fleet/company/controller/my_shipment_controller.dart';
import 'package:truk_fleet/company/controller/request_controller.dart';
import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/models/user_model.dart';
import 'package:truk_fleet/models/wallet_model.dart';
import 'package:truk_fleet/utils/constants.dart';

import 'Routes/routes.dart';
import 'locale/app_localization.dart';
import 'locale/language_bloc/language_bloc.dart';
import 'models/pending_payout_model.dart';
import 'models/truk_model.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

AndroidNotificationChannel channel;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor));
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MyDrivers(),
        ),
        ChangeNotifierProvider(
          create: (context) => AvailableDrivers(),
        ),
        ChangeNotifierProvider(
          create: (context) => MyUser(),
        ),
        ChangeNotifierProvider(
          create: (context) => MyRequest(),
        ),
        ChangeNotifierProvider(
          create: (context) => MyTruksProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MyDriverUser(),
        ),
        ChangeNotifierProvider(
          create: (context) => MyWallet(),
        ),
        ChangeNotifierProvider(
          create: (context) => FleetRideModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatController(),
        ),
        ChangeNotifierProvider(
          create: (context) => MyPendingPayout(),
        ),
      ],
      child: BlocProvider(
        create: (_) => LanguageBloc()..add(LanguageLoadStarted()),
        child: BlocBuilder<LanguageBloc, Language>(
            buildWhen: (prevState, currentState) => prevState != currentState,
            builder: (context, snapshot) {
              return MaterialApp(
                localizationsDelegates: [
                  const AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: [
                  const Locale('en', 'US'),
                  const Locale('hi', 'IN'),
                  const Locale('te', 'IN'),
                ],
                locale: snapshot.locale,
                theme: ThemeData(
                  appBarTheme: AppBarTheme(
                    iconTheme: IconThemeData(color: Colors.black),
                    color: Colors.white,
                    elevation: 8.0,
                    centerTitle: true,
                  ),
                ),
                //initialRoute: PageRoutes.splashPage,
                routes: PageRoutes().routes(),
                debugShowCheckedModeBanner: false,
                home: LoginNavigator(),
              );
            }),
      ),
    );
  }
}
