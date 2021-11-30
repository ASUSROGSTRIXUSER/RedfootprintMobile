
import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';


import 'package:google_fonts/google_fonts.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

class NewsPage extends StatefulWidget {
  final BaseAuth authtoChatroom;
  NewsPage({this.authtoChatroom});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Asset> images = List<Asset>();
  Stream<QuerySnapshot> news;
  TextEditingController newsTextController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<String> imageUrls = <String>[];
  bool isUploading = false;
  @override
  void initState() {
    MyDatabaseMethods().getNews().then((newData) {
      setState(() {
        news = newData;
      });
    });
    super.initState();
  }

  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child("NewsPhotos/$fileName");
    StorageUploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    if (uploadTask.isInProgress == true) {
      setState(() {
        isUploading = true;
      });
    }

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    if (uploadTask.isSuccessful == true) {
      setState(() {
        isUploading = false;
      });
    }
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  uploadImages() {
    // print("upload");
    for (var imageFile in images) {
      postImage(imageFile).then((downloadUrl) {
        imageUrls.add(downloadUrl.toString());
        if (imageUrls.length == images.length) {
          //  String documnetID = DateTime.now().millisecondsSinceEpoch.toString();
          Firestore.instance
              .collection('Events')
              .document("News")
              .collection("NewsData")
              .document()
              .setData({
            'News': newsTextController.text,
            'urls': imageUrls,
            "Timeby": DateTime.now().toString()
          }).then((_) {
            showuploadSuccessful(context);
            newsTextController.clear();
            //   widget.globalKey.currentState.showSnackBar(snackbar);
            setState(() {
              images = [];
              imageUrls = [];
            });
          });
        }
      }).catchError((err) {
        print(err);
      });
    }
  }

  void showuploadSuccessful(BuildContext context) {
    AchievementView(
      context,

      duration: Duration(seconds: 5),
      icon: Icon(
        Icons.alarm_add,
        color: Colors.black,
      ),
      color: Colors.white, //Color(0xFFA41D21)
      textStyleTitle: TextStyle(color: Colors.black),
      textStyleSubTitle: TextStyle(color: Colors.black),
      title: "Post Successful ",

      isCircle: true,
      listener: (status) {
        print(status);
      },
    )..show();
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          // actionBarColor: "#abcdef",
          actionBarTitle: "Gallery",
          allViewTitle: "All Photos",
          useDetailsView: true,
          // selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  Widget buildGridView() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: images.length,
      shrinkWrap: true,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];

        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
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
                  return Card(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
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
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(
                              makeitsnappy.data.documents[index].data['News'],
                              style: GoogleFonts.roboto(letterSpacing: 0.3),
                              textAlign: TextAlign.start),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        CachedNetworkImage(
                          filterQuality: FilterQuality.high,
                          imageUrl: makeitsnappy
                              .data.documents[index].data['urls'][0],
                        )
                      ],
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
      //    backgroundColor: Color(0xFFF5F5F5),
      // backgroundColor: Color(0xFFA41D21),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color: Color(0xFFA41D21),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        'Add News',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                //   height: mediaHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(30.0),
                    topRight: const Radius.circular(30.0),
                    // bottomLeft: const Radius.circular(30.0),
                    // bottomRight: const Radius.circular(30.0),
                  ),
                ),
                //margin: EdgeInsets.all(15),
                child: Container(
                  //  height: mediaHeight,
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Column(
                    children: [
                      Card(
                          child: Column(
                        children: [
                          Row(
                            children: [
                              /*      CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    _currentUserProfilePic),
                              ),*/
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    //  margin: EdgeInsets.all(10),
                                    child: TextField(
                                      maxLines: null,
                                      controller: newsTextController,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          filled: true,
                                          hintStyle: new TextStyle(
                                              color: Colors.grey[800]),
                                          hintText: "News Description",
                                          fillColor: Colors.white70),
                                    ),
                                  )),
                            ],
                          ),
                          images.length == 0
                              ? Container()
                              : Row(
                                  children: [
                                    Flexible(child: buildGridView()),
                                  ],
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.photo_library),
                                  onPressed: loadAssets),
                            ],
                          ),
                          isUploading
                              ? CircularProgressIndicator()
                              : RaisedButton(
                                  onPressed: () {
                                    uploadImages();
                                  },
                                  color: Colors.redAccent,
                                  child: Text(
                                    "Post",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                        ],
                      )),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              newsTiles()
            ]),
      ),
    );
  }
}
