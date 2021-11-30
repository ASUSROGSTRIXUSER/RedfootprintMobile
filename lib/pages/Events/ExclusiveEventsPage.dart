import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:redfootprintios/pages/DashboardItems/SideEvents.dart';
//import 'package:redfootprintios/pages/DashboardItems/SmallEventPage.dart';
import 'package:redfootprintios/services/CallsAndMessagesServices.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

//import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

import 'package:video_player/video_player.dart';

import 'SideEvents.dart';
import 'SmallEventPage.dart';
import 'SmallEventScape.dart';

//import 'package:webview_flutter/webview_flutter.dart';
List<String> imgList = [
  'assets/meeting-with-ceo-new-576x1024.jpg',
  'assets/mlm-fundamental-new-576x1024.jpg',
  'assets/success-u-new-576x1024.jpg',
  'assets/inspiration-night-new-576x1024.jpg',
  'assets/the-bys-new-576x1024.jpg',
  'assets/rfp-special-event.jpg',
  "assets/the-new-you-new-576x1024.jpg",
];

class ExclusiveEventsSubPage extends StatefulWidget {
  final BaseAuth authtoChatroom;
  ExclusiveEventsSubPage({this.authtoChatroom});

  @override
  _ExclusiveEventsSubPageState createState() => _ExclusiveEventsSubPageState();
}

class _ExclusiveEventsSubPageState extends State<ExclusiveEventsSubPage> {
  String reason = '';
  final CarouselController _carouselcontroller = CarouselController();
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  VideoPlayerController controller;
  Future<void> initializeVideoPlayerFuture;
  String _currentUserEmail;
  String _currentUserName;
  String _currentUserProfilePic;
  // List<String> imgList;
  String _photoUrl;
  String _notificationStatus;
  Stream<QuerySnapshot> streamofEventList;
  void onPageChange(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      reason = changeReason.toString();
    });
  }

  @override
  void initState() {
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    MyDatabaseMethods().viewEventsList().then((eventList) {
      setState(() {
        streamofEventList = eventList;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget carouselList() {
    var mediaHeight = MediaQuery.of(context).size.height / 1.3;
    var mediawidth = MediaQuery.of(context).size.width;
    try {
      return StreamBuilder(
        stream: streamofEventList,
        builder: (context, snapEvent) {
          List<GestureDetector> listCar = new List<GestureDetector>();
          if (snapEvent.connectionState == ConnectionState.active) {
            if (snapEvent.data.documents.length == 0) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Looks like there is no events available",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    Icon(
                      Icons.search,
                      size: 40,
                    ),
                  ],
                ),
                //  height: mediaHeight,
                width: mediawidth,
              );
            }
            for (var i = 0; i < snapEvent.data.documents.length; i++) {
              listCar.add(GestureDetector(
                onTap: () {
                  // print(snapEvent.data.documents[i].data['EventLink']);
                  return CallsAndMessagesService()
                      .launchWeb(snapEvent.data.documents[i].data['EventLink']);
                },
                child: Container(
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: Stack(
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: snapEvent.data.documents[i].data['urls']
                                  [0],
                              placeholder: (context, url) =>
                                  new CircularProgressIndicator(),
                              // fit: BoxFit.contain,
                              //  width: 1000.0,
                              // height: 1000,
                            ),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(),
                            ),
                          ],
                        )),
                  ),
                ),
              ));
            }
            return Column(
              children: [
                SizedBox(
                  height: 80,
                ),
                SlideInUp(
                  delay: Duration(seconds: 1),
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height / 7.5,
                    child: Hero(
                      tag: "EXvent",
                      child: Image.asset("assets/ExclusiveEvents.png"),
                    ),
                  ),
                ),
                CarouselSlider(
                  carouselController: _carouselcontroller,
                  options: CarouselOptions(
                    onPageChanged: onPageChange,
                    height: mediaHeight,
                    autoPlay: true,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                  ),
                  items: listCar,
                )
              ],
            );
            /*            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: IconButton(
                      color: Colors.red[900],
                   iconSize: 70,
                    onPressed: () => _carouselcontroller.previousPage(),
                    icon: Icon(Icons.keyboard_arrow_left)
                    // Text('←'),
                  ),
                ),
                Flexible(
                  child: IconButton(
                    color: Colors.red[900],
                      iconSize: 70,
                    onPressed: () => _carouselcontroller.nextPage(),
                    icon:Icon(Icons.keyboard_arrow_right)
                   //  Text('→'),
                  ),
                ),
                
            
            ],)*/

          } else if (snapEvent.connectionState == ConnectionState.waiting) {
            return Container(
                height: mediaHeight,
                child: Center(child: CircularProgressIndicator()));
          } else {
            return Container(
                height: mediaHeight,
                child: Center(child: CircularProgressIndicator()));
          }
        },
      );
    } catch (e) {
      return Container(
        color: Colors.white,
        child: Text("Empty"),
        height: mediaHeight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.1),
          leading: Container(),
          actions: [
            ClipOval(
              child: Material(
                color: Colors.white.withOpacity(0.7), // button color
                child: InkWell(
                  splashColor: Colors.red, // inkwell color
                  child:
                      SizedBox(width: 56, height: 56, child: Icon(Icons.close,color: Colors.black,)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        body: SingleChildScrollView(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                  alignment: AlignmentDirectional.topCenter,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  width: MediaQuery.of(context).size.width / 1.2,
                  //  margin: EdgeInsets.fromLTRB(30,0,30,0),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      'Online Exclusive Events',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA41D21)),
                    ),
                  )),
              carouselList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        color: Colors.red[500],
                        iconSize: 80,
                        onPressed: () => _carouselcontroller.previousPage(),
                        icon: Icon(Icons.keyboard_arrow_left)
                        // Text('←'),
                        ),
                  ),
                  Flexible(
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        color: Colors.red[500],
                        iconSize: 80,
                        onPressed: () => _carouselcontroller.nextPage(),
                        icon: Icon(Icons.keyboard_arrow_right)
                        //  Text('→'),
                        ),
                  ),
                ],
              )
            ],
          ),
        )

        // SmallEventScrapePage(),

        );
  }
}
