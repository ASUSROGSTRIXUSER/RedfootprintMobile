import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:flutter_circular_text/circular_text/widget.dart';









import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import '../services/database.dart';



import 'EventDetails.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  Stream<QuerySnapshot> streamofEventList;
  Stream<QuerySnapshot> streamforumRooms;
  String _currentUserEmail;
  String _currentUserName;

  ScrollController scrollForum = new ScrollController();

  //var mediaHeight;

  List<Asset> images = List<Asset>();
  bool isUploading = false;
  String _myActivitiesResult;
  TextEditingController eventNameController = new TextEditingController();
  TextEditingController eventLinkController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<String> imageUrls = <String>[];
  @override
  void initState() {
   

    MyDatabaseMethods().viewEventsList().then((eventListData)  {
      setState(() {
        streamofEventList =  eventListData;
      });
    });
    // var mediaHeight = MediaQuery.of(context).size.height;
    super.initState();
  }

  Widget eventTileList() {
    var mediaHeight = MediaQuery.of(context).size.height;
    var mediawidth = MediaQuery.of(context).size.width;
    try {
      return StreamBuilder(
        stream: streamofEventList,
        builder: (context, snapEvent) {
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
                height: mediaHeight,
                width: mediawidth,
              );
            }
         
             return   
              GridView.count(
                
                primary: true,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
 // padding: const EdgeInsets.all(20),
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  crossAxisCount: 2,
            
            shrinkWrap: true,
             physics: NeverScrollableScrollPhysics(),
             children: List.generate(snapEvent.data.documents.length, (index) {
               return eventTile(
                    snapEvent.data.documents[index].data['EventName']
                        .toString(),
                    snapEvent.data.documents[index].data['EventLink']
                        .toString(),
                    snapEvent.data.documents[index].data['urls'][0],
                );
             })
               /*  eventTile(
                    snapEvent.data.documents[index+1].data['EventName']
                        .toString(),
                    snapEvent.data.documents[index+1].data['EventLink']
                        .toString(),
                    snapEvent.data.documents[index+1].data['urls'][0],
                  ),*/
                  
             
            );
                  // print(snapEvent.ref.documentsId);
                 
                

                  
                  
                 
             
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
        FirebaseStorage.instance.ref().child("EventsBanner/$fileName");
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
    if (images.length == 0) {
      setState(() {
        isUploading = false;
      });
    } else {
      for (var imageFile in images) {
        postImage(imageFile).then((downloadUrl) {
          imageUrls.add(downloadUrl.toString());
          if (imageUrls.length == images.length) {
            //  String documnetID = DateTime.now().millisecondsSinceEpoch.toString();
            Firestore.instance
                .collection('Events')
                .document("SpecialEvents")
                .collection("SpecialEventsData")
                .document(eventNameController.text)
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
  }

  Widget eventTile(
    String eventName,
    String eventLink,
    String eventURL,
  ) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventDetails(
                        eventLink: eventLink,
                        eventName: eventName,
                        eventURL: eventURL,
                      )));
        },
        child: Card(
            color: Color(0xFFF5F5F5),
            child: Container(
               // margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                child:
                
                
                 Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                           //   Text("Event Name:"),
                              SizedBox(
                                width: 5,
                              ),
                              Text(eventName),
                               SizedBox(
                                width: 10,
                              ),
                             //   Flexible(
                          //    child: 
                              Container(
                            height: 150,
                           // margin: EdgeInsets.all(20),
                            child: Image.network(eventURL),
                          )
                         // )
                            ],
                          ),

                          //    RaisedButton(onPressed: () {}),
                        
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
                color: Color(0xFFA41D21),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        'Add Events',
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
                /*      Card(child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                       Text("Monday"),
                        Text("Tuesday"),
                         Text("Wednesday"),
                          Text("Thursday"),
                           Text("Friday"),
                            Text("Saturday"),
                             Text("Sunday"),
                      ],)),*/



                      Card(
                          child: Column(
                        children: [
                          images.length == 0
                              ? Container()
                              : Row(
                                  children: [
                                    Flexible(child: buildGridView()),
                                  ],
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
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
                              onPressed: loadAssets),
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
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: TextField(
                              controller: eventNameController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                  ),
                                  filled: true,
                                  hintStyle:
                                      new TextStyle(color: Colors.grey[800]),
                                  //  hintText: "Event Name",
                                  fillColor: Colors.white70),
                            ),
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
                                      Radius.circular(30.0),
                                    ),
                                  ),
                                  filled: true,
                                  hintStyle:
                                      new TextStyle(color: Colors.grey[800]),
                                  //  hintText: "Event Name",
                                  fillColor: Colors.white70),
                            ),
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
              Center(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'List of Events',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
              eventTileList()
            ]),
      ),
    );
  }
}
