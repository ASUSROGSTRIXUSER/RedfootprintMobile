import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import '../services/database.dart';


class EventDetails extends StatefulWidget {
  String eventLink;
  String eventName;
  String eventURL;

  EventDetails({this.eventLink, this.eventURL, this.eventName});
  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  ScrollController scrollForum = new ScrollController();
  bool isUploading = false;
  //var mediaHeight;

  TextEditingController eventNameController = new TextEditingController();
  TextEditingController eventLinkController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<Asset> images = List<Asset>();
  List<String> imageUrls = <String>[];
  @override
  void initState() {
    setState(() {
      eventLinkController.text = widget.eventLink;
      eventNameController.text = widget.eventName;
    });
    super.initState();
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
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
showAlertDialog(BuildContext context) {
    
      Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      // Create AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Update"),
        content: Text("Saved"),
        actions: [
          okButton,
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      // show the dialog

    
  }
  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: images.length,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        //    print(images[index]);

        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
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

    // print(storageTaskSnapshot.ref.getDownloadURL());
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
              .document("SpecialEvents")
              .collection("SpecialEventsData")
              .document()
              .setData({
            'EventName': eventNameController.text,
            'EventLink': eventLinkController.text,
            'urls': imageUrls,
            "Timeby": DateTime.now().toString()
          }).then((_) {
            showuploadSuccessful(context);
            eventNameController.clear();
            eventLinkController.clear();

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

  Widget eventTile(
    String eventName,
    String eventLink,
  ) {
    return GestureDetector(
        onTap: () {},
        child: Card(
            color: Color(0xFFF5F5F5),
            child: Container(
                margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Event Name:"),
                          SizedBox(
                            width: 20,
                          ),
                          Text(eventName),
                          //    RaisedButton(onPressed: () {}),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      )
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(
                Icons.delete_forever,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                MyDatabaseMethods().deleteEvent(widget.eventName);
              })
        ],
        backgroundColor: Color(0xFFA41D21),
        title: Text(
          'Event Details',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        'Event Thumbnail',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA41D21),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              images.length == 0
                  ? Image.network(
                      widget.eventURL,
                    )
                  : buildGridView(),
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
                              Text(
                                'Event Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA41D21),
                                ),
                              ),
                              //   Text("Event Name"),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: TextField(
                              readOnly: true,
                              controller: eventNameController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  filled: true,
                                  hintStyle:
                                      new TextStyle(color: Colors.grey[800]),
                                  //  hintText: "Event Name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                'Event Link',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA41D21),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: TextField(
                              controller: eventLinkController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  filled: true,
                                  hintStyle:
                                      new TextStyle(color: Colors.grey[800]),
                                  //  hintText: "Event Name",
                                  fillColor: Colors.white70),
                            ),
                          ),
                          /*        Row(
                            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Event Thumbnail',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA41D21),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                              icon: Icon(Icons.photo_library),
                              onPressed: loadAssets),*/
                          /*    images.length == 0
                              ? Container()
                              : Row(
                                  children: [
                                    Flexible(child: buildGridView()),
                                  ],
                                ),*/
                          SizedBox(
                            height: 20,
                          ),
                          isUploading
                              ? CircularProgressIndicator()
                              : RaisedButton(
                                  onPressed: () async{
                                    // uploadImages();
                                  await  MyDatabaseMethods().updateLink(
                                      widget.eventName,
                                      eventLinkController.text.trim(),
                                    );
await showAlertDialog(context);
                                  },
                                  color: Colors.redAccent,
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                        ],
                      )),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
