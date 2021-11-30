import 'package:achievement_view/achievement_view.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

class PublicNewsPage extends StatefulWidget {
  final BaseAuth authtoChatroom;
  PublicNewsPage({this.authtoChatroom});

  @override
  _PublicNewsPageState createState() => _PublicNewsPageState();
}

class _PublicNewsPageState extends State<PublicNewsPage> {
  Stream<QuerySnapshot> streamforumRooms;

  //var mediaHeight;
  List _myActivities;
  List _like;
  List<Asset> images = List<Asset>();
  Stream<QuerySnapshot> news;
  TextEditingController newsTextController = new TextEditingController();
  // TextEditingController answerTextController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<String> imageUrls = <String>[];
  bool isUploading = false;

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  void initState() {
    MyDatabaseMethods().getNews().then((newData) {
      setState(() {
        news = newData;
      });
    });
    super.initState();
  }

  Widget gridView(dynamic url) {
    if (url.length == 1) {
      return GestureDetector(
           onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    //backgroundColor: Colors.black.withOpacity(0.6),
                    body: Center(
                        child: PhotoView(
                      imageProvider: CachedNetworkImageProvider(
                       url[0],
                      ),
                    )),
                  );
                }));
              },
        child: CachedNetworkImage(
          
          imageUrl: url[0],
        ),
      );
    } else {
      return GridView.count(primary: true,
        crossAxisCount: 2,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(url.length, (index) {
          return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    //backgroundColor: Colors.black.withOpacity(0.6),
                    body: Center(
                        child: PhotoView(
                      imageProvider: CachedNetworkImageProvider(
                        url[index],
                      ),
                    )),
                  );
                }));
              },
              child: ZoomIn(
                delay: Duration(seconds: 1),
                child: CachedNetworkImage(
                  filterQuality: FilterQuality.high,
                  imageUrl: url[index],
                  placeholder: (context, url) =>
                      new CircularProgressIndicator(),
                ),
              ));
        }),
      );
    }
  }

  Widget newsTiles() {
    return StreamBuilder(
        stream: news,
        builder: (context, makeitsnappy) {
          if (makeitsnappy.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: makeitsnappy.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return SlideInDown(
                    from: 300,
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Card(
                        elevation: 80,
                        shadowColor: Colors.red[900],
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(30, 10, 10, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(0xFFA41D21),
                                    radius: 25,
                                    child: Image.asset("assets/new_logo.png"),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "Red footprint Business Consultancy",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: Text(
                                  makeitsnappy
                                      .data.documents[index].data['News'],
                                  style: GoogleFonts.roboto(letterSpacing: 0.3),
                                  textAlign: TextAlign.start),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            gridView(makeitsnappy
                                .data.documents[index].data['urls']),
                            Container(
                              height: 20,
                              color: Color(0xFFA41D21),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    var mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50.0),
            bottomRight: Radius.circular(50.0),
          ),
        ),
        leading: Container(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            splashColor: Colors.red.withOpacity(0.2),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Color(0xFFA41D21).withOpacity(0.9),
        title: SlideInUp(
            delay: Duration(seconds: 2),
            from: 200,
            child: Text(
              'News',
              style: TextStyle(
                  // fontFamily: "Georgia",
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )),
      ),
      backgroundColor: Colors.black.withOpacity(0.4),
      // backgroundColor: Color(0xFFA41D21),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              newsTiles(),
            ]),
      ),
    );
  }
}
