

import 'dart:io';

import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:redfootprintios/pages/HomePage/NewHomePage.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/scheduler.dart';

import 'pages/root_page.dart';
import 'services/CallsAndMessagesServices.dart';
import 'services/authentication.dart';

void main() {
  setupLocator();
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
    theme: ThemeData(primaryColor: Colors.black),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyAppState();
}


/*Future<dynamic> myBackgroundHandler(Map<String, dynamic> message) async {
  return await MyAppState()._showNotification(message);
}*/
class MyAppState extends State<MyApp> {
 // FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
 // final FirebaseMessaging _firebaseMessaging 
  //= FirebaseMessaging();
 // @override
  //void initState() {
   /* var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSinitialize = new IOSInitializationSettings();
    var initializationSettings =
        new InitializationSettings(androidInitialize, iOSinitialize);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);*/

    
   /* _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //  print(message['notification']['body']);
      
      await  _showNotification(message);
    
        // print("Else");
      },
      onResume: (Map<String, dynamic> message) async {
        
        await onSelectNotification(message['notification']['body']);
        print("Resume");
      },
      
      onBackgroundMessage: Platform.isIOS ? null :myBackgroundHandler
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true));
        super.initState();
  }

  Future onSelectNotification(String payload) async {
   await showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }*/
 // }
 // Future notificationSelected(String payload) async {}
  /*Future _showNotification(Map<String, dynamic> message) async {
    var androidDetails = new AndroidNotificationDetails(
        "09234808983", "RedFootprint", "RedFootprintNotification",
        importance: Importance.Max);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(androidDetails, iosDetails);
    await _flutterLocalNotificationsPlugin.show(
        0,
        '${message['notification']['title']}',
        '${message['notification']['body']}',
        generalNotificationDetails);
  }*/

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 1,
        navigateAfterSeconds: new RootPage(auth: new Auth()),
        title: new Text(
          '',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.asset('assets/new_logo.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.red);
  }
}
