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



class ModeratorPage extends StatefulWidget {
  String eventLink;
  String eventName;
  String eventURL;

  ModeratorPage({this.eventLink, this.eventURL, this.eventName});
  @override
  _ModeratorPageState createState() => _ModeratorPageState();
}

class _ModeratorPageState extends State<ModeratorPage> {
  Stream<QuerySnapshot> getForumUnApproved;
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
    MyDatabaseMethods().getPendingQuestion().then((pendingQuestion) {
      setState(() {
        getForumUnApproved = pendingQuestion;
      });
    });
    super.initState();
  }

  Widget eventTileList() {
    var mediaHeight = MediaQuery.of(context).size.height;
    var mediawidth = MediaQuery.of(context).size.width;
    try {
      return StreamBuilder(
        stream: getForumUnApproved,
        builder: (context, snapEvent) {
          if (snapEvent.connectionState == ConnectionState.active) {
            if (snapEvent.data.documents.length == 0) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Looks like there is no pending question",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    Icon(
                      Icons.search,
                      size: 40,
                    ),
                  ],
                ),
                height: mediaHeight,
                width: mediawidth,
              );
            }
            return ListView.builder(
                itemCount: snapEvent.data.documents.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // controller: scrollForum,
                itemBuilder: (context, index) {
                  // print(snapEvent.ref.documentsId);
                  return eventTile(
                    snapEvent.data.documents[index].data['Question'].toString(),
                    snapEvent.data.documents[index].data["QuestioneeName"]
                        .toString(),
                    snapEvent.data.documents[index].data["QuestioneeUserEmail"]
                        .toString(),
                  );
                });
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
    String question,
    String questioneeName,
    String questionneeEmail,
  ) {
    return GestureDetector(
        onTap: () {},
        child: Card(
            color: Colors.white,
            child: Container(
                margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Name:", style: TextStyle(fontSize: 15)),
                          SizedBox(
                            width: 20,
                          ),
                          Text(questioneeName, style: TextStyle(fontSize: 15)),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Question:"),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            question,
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton.icon(
                              color: Color(0xFFA41D21),
                              onPressed: () {
                                MyDatabaseMethods().approvedQuestion(
                                    questionneeEmail + question);
                              },
                              icon: Icon(
                                Icons.approval,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Approved",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )),
                          RaisedButton.icon(
                              color: Color(0xFFA41D21),
                              onPressed: () {
                                MyDatabaseMethods().disapprovedQuestion(
                                    questionneeEmail + question);
                              },
                              icon: Icon(
                                Icons.remove_from_queue,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Disapprove",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ))
                        ],
                      )
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color:Color(0xFFA41D21),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        'For Approval Questions',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color:  Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              eventTileList()
              /*    images.length == 0
                  ? Image.network(
                      widget.eventURL,
                    )
                  : buildGridView(),*/
            ]),
      ),
    );
  }
}
