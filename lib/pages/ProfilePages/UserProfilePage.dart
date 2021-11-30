import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:redfootprintios/pages/ProfilePages/AboutUserDetails.dart';
import 'package:redfootprintios/services/CallsAndMessagesServices.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';
import 'package:slimy_card/slimy_card.dart';



class ProfileCustomization extends StatefulWidget {
  ProfileCustomization({this.auth, this.tag, this.logoutCallback});
  String tag;
  BaseAuth auth;
  final VoidCallback logoutCallback;
  State<StatefulWidget> createState() => new _ProfileCustomizationState();
}

class _ProfileCustomizationState extends State<ProfileCustomization> {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  String _userName = "";
  File _image;
  var _downUrl;
  List<Asset> images = List<Asset>();
  String _email = "";
  String _contactNumber = "";
  String _bioText = "";
  String _facebookID = "";
  String _address = "";
  String _education = "";
  String _work = "";
  String _jobtitle = "";
  String _civilStatus = "";
  String _motivation = "";
  String _recreation = "";
  String _birthdate = "";
  String _gender = "";
  bool _isEditDetails;
  var prospectcount;
  List<dynamic> fromfirestoreuserlist =List<dynamic>();
  TextEditingController _bioEditingController = new TextEditingController();
  TextEditingController _facebookIDController = new TextEditingController();
  final picker = ImagePicker();
  QuerySnapshot deleteobject;
  //var data = [0.0, 1.0, 1.5, 2.0, 0.0, 0.0, -0.5, -1.0, -0.5, 0.0, 0.0];

  @override
  void initState() {
    Auth().getCurrentUser().then((value) {
      setState(() {
        _userName = value?.displayName;
        _downUrl = value?.photoUrl;
        _email = value?.email;

      Firestore.instance.collection('users').document(_email).collection("featuredphotos").orderBy("TimeUploaded",descending: true).snapshots().listen((eventlistener) async{
        fromfirestoreuserlist.clear();
        setState(() {
                deleteobject = eventlistener;
     
      
        for (var i = 0; i < eventlistener.documents.length; i++) {
       
             fromfirestoreuserlist.insert(i, eventlistener.documents[i].data["photoUrl"]);        
         
     //   print(eventlistener.documents.length);
     
        }
           });
       });
        

        MyDatabaseMethods().countProspects(_email).then((prospectnumber) {
          setState(() {
            prospectcount = prospectnumber;
          });
        });
        MyDatabaseMethods().getuserInfo(value?.email).then((val) {
          setState(() {
            _contactNumber = val.data['ContactNumber'].toString();
            _bioEditingController.text = val.data['Bio'].toString();
            _facebookID = val.data['FacebookID']
                .toString()
                .replaceAll("https://www.facebook.com/", "");
            _facebookIDController.text = val.data['FacebookID'].toString();
            _address = val.data['Address'].toString();
            _education = val.data['Education'].toString();
            _work = val.data['Work'].toString();
            _jobtitle = val.data['JobTitle'].toString();
            _recreation = val.data['Recreation'].toString();
            _motivation = val.data['Motivation'].toString();
            _civilStatus = val.data['Status'].toString();
            _birthdate = val.data['Birthday'].toString();
            _gender = val.data['Gender'].toString();
          });
        });
      });
    });
    if (_facebookID == "") {
      setState(() {
        _facebookID = "";
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      uploadProfilePic(context);
    });
  }

  Future uploadProfilePic(BuildContext context) async {
    String fileName = Path.basename(_image.path);
    StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('ProfilesPictures/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    _downUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      //Firestore Save
      Auth().getCurrentUser().then((value) {
        MyDatabaseMethods()
            .uploadProfilePic('$_downUrl', value?.email.toString());
        // Auth update
        UserUpdateInfo info = new UserUpdateInfo();
        info.photoUrl = '$_downUrl';
        value.updateProfile(info);
        // print('$_downUrl' + 'Upload pic process');
      });
    }); 
  }

 Future uploadToFirebaseStorage(Asset imageFile) async {
   // List<String> featuredDownUrl;
   //List<dynamic> listUrl = List<dynamic>();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child("FeaturedPhotos/$fileName");
    StorageUploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
     
    Map <String, dynamic> featurelist ={
    "photoUrl": await storageTaskSnapshot.ref.getDownloadURL(),
    "TimeUploaded": DateTime.now()
    };

    Firestore.instance.collection("users").document(_email).collection("featuredphotos").document(imageFile.name.toString()).setData(featurelist);
    //return await storageTaskSnapshot.ref.getDownloadURL();
  }

  Future<void> viewUserImages() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Detected';

    try {
      await PermissionHandler().requestPermissions([PermissionGroup.camera]);
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        // enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#A41D21",
          actionBarTitle: "Gallery",
          allViewTitle: "All Photos",
          useDetailsView: true,
          // selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) 
    return ;
    setState(() {
      images = resultList;
    });

    for (var i = 0; i < images.length; i++) {
      setState(() {
        uploadToFirebaseStorage(images[i]) ;

      }); 
    } 
    images.clear();
  }

  Future<Null> _refreshUserInfo() async {
    Auth().getCurrentUser().then((value) {
      setState(() {
        _userName = value?.displayName;
        _downUrl = value?.photoUrl;
        _email = value?.email;

        MyDatabaseMethods().getuserInfo(value?.email).then((val) {
          setState(() {
            _contactNumber = val.data['ContactNumber'].toString();
            _bioEditingController.text = val.data['Bio'].toString();
            _facebookID = val.data['FacebookID']
                .toString()
                .replaceAll("https://www.facebook.com/", "");
            _facebookIDController.text = val.data['FacebookID'].toString();
            _address = val.data['Address'].toString();
            _education = val.data['Education'].toString();
            _work = val.data['Work'].toString();
            _jobtitle = val.data['JobTitle'].toString();
            _recreation = val.data['Recreation'].toString();
            _motivation = val.data['Motivation'].toString();
            _civilStatus = val.data['Status'].toString();
            _birthdate = val.data['Birthday'].toString();
            _gender = val.data['Gender'].toString();
          });
        });
      });
    });
  }

  Widget buildGridViewFeaturePhotos() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(fromfirestoreuserlist.length, (index) {
        return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Scaffold(
                  body: Center(
                      child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(fromfirestoreuserlist[index].toString()),
                  )),
                );
              }));
            },
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(         
              margin: EdgeInsets.all(1),
              child: CachedNetworkImage(
                imageUrl:
                fromfirestoreuserlist[index].toString(),
              //  fit: BoxFit.cover,
             
              ),
            ),
              Positioned(
                top: -5,right: 5,
                child: 
              IconButton(icon: Icon(Icons.close,color: Colors.red[900],),onPressed: ()=>
              deleteobject.documents[index].reference.delete()
              ,),),
             
            ],),);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaWidth = MediaQuery.of(context).size.width;
    var mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor:Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFA41D21),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.menu, // add custom icons also
            ),
          ),
          title: Text('Profile'),
        ),
        body: RefreshIndicator(
            onRefresh: _refreshUserInfo,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                      child: Container(
                    width: double.infinity,
                    height: 780.0,
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFA41D21),
                                    borderRadius: BorderRadius.only(
                                      //   topLeft: const Radius.circular(10.0),
                                      //  topRight: const Radius.circular(10.0),
                                      bottomLeft: const Radius.circular(30.0),
                                      bottomRight: const Radius.circular(30.0),
                                    ),
                                  ),
                                  height: 150,
                                  width: mediaWidth,
                                  //   color: Colors.redAccent,
                                ),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 50,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 50.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return Scaffold(
                                                    // backgroundColor: Colors.black,
                                                    body: Center(
                                                        child: PhotoView(
                                                      imageProvider:
                                                          CachedNetworkImageProvider(
                                                              _downUrl),
                                                    )),
                                                  );
                                                }));
                                              },
                                              child: Hero(
                                                tag: widget.tag,
                                                child: CircleAvatar(
                                                  radius: 100,
                                                  backgroundImage: (_downUrl !=
                                                          null)
                                                      ? CachedNetworkImageProvider(
                                                          _downUrl,
                                                        )
                                                      : CachedNetworkImageProvider(
                                                          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg",
                                                        ),
                                                ),
                                              ))),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 150.0,
                                              ),
                                              child: IconButton(
                                                color: Colors.black,
                                                icon: Icon(
                                                  Icons.add_a_photo,
                                                  size: 30.0,
                                                ),
                                                onPressed: () {
                                                  getImage();
                                                },
                                              ),
                                            ),
                                          ]),
                                    ]),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Flexible(
                            child: Text('$_userName',
                                style: GoogleFonts.roboto(
                                    fontSize: 26, color: Colors.black))) ,
                     
                          SizedBox(
                            height: 10.0,
                          ),
                          Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5.0),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.white,
                            elevation: 5.0,
                            child: ListTile(
                              title: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text('Intro',
                                          style: GoogleFonts.tinos(
                                              fontSize: 25,
                                              color: Colors.black))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.wc,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text('$_civilStatus',
                                          style: GoogleFonts.roboto(
                                              fontSize: 17,
                                              color: Colors.black))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.business_center,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text('$_jobtitle',
                                          style: GoogleFonts.roboto(
                                              fontSize: 17,
                                              color: Colors.black))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.work,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Flexible(
                                          child: Text(
                                        '$_work',
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.roboto(
                                            fontSize: 17, color: Colors.black),
                                      ))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.directions_bike,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Flexible(
                                          child: Text('$_recreation',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 17,
                                                  color: Colors.black)))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.mood,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Flexible(
                                          child: Text('$_motivation',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 17,
                                                  color: Colors.black)))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.email,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Flexible(
                                          child: Text('$_email',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 17,
                                                  color: Colors.black)))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.call,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Center(
                                          child: Text('$_contactNumber',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 17,
                                                  color: Colors.black)))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.wc,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Center(
                                          child: Text('$_gender',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 17,
                                                  color: Colors.black)))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.cake,
                                        color: Color(0xFFA41D21),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Center(
                                          child: Text('$_birthdate',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 17,
                                                  color: Colors.black)))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Flexible(
                                          child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DropdownSamplePage()));
                                        },
                                        child: Container(
                                          width: 300.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFA41D21),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Edit Details',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  Card(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: <Widget>[
                          Container(
                              margin: EdgeInsets.all(15),
                              child: Text("Featured Photos",
                                  style: GoogleFonts.tinos(
                                      fontSize: 25, color: Colors.black))),
                        ]),
                        Column(children: [
                          SizedBox(
                            height: 20,
                          )
                        ]),
                   fromfirestoreuserlist.length == 0?Container():   buildGridViewFeaturePhotos(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                                child: InkWell(
                              onTap: viewUserImages,
                              child: Container(
                                margin: EdgeInsets.all(10),
                                width: 300.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFA41D21),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'Add Photos',
                                    style: TextStyle(
                                        fontSize: 18.0, color: Colors.white),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                    //  ),
                  ),
                  /*    Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text("Achievements",
                                style: GoogleFonts.tinos(
                                    fontSize: 25, color: Colors.black)),
                          ]),
                          SizedBox(
                            height: 30.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                child: Image.asset("assets/A4.PNG"),
                              ),
                              Text(
                                "Baby Steps",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 10.0,
                          ),
                          new LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width - 50,
                            animation: true,
                            lineHeight: 20.0,
                            animationDuration: 2000,
                            percent: prospectcount == 0
                                ? 0.0
                                : prospectcount == 1
                                    ? 0.2
                                    : prospectcount == 2
                                        ? 0.4
                                        : prospectcount == 3
                                            ? 0.6
                                            : prospectcount == 4
                                                ? 0.9
                                                : 1.0,
                            center: prospectcount == 0
                                ? Text("$prospectcount of 5 prospects")
                                : prospectcount == 1
                                    ? Text("4 more to unlock")
                                    : prospectcount == 2
                                        ? Text("3 more to unlock")
                                        : prospectcount == 3
                                            ? Text("2 more to unlock")
                                            : prospectcount == 4
                                                ? Text("1 more to unlock")
                                                : Text("Unlocked"),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: Colors.greenAccent,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          ///  Text("Number of Prospects added"),
                          SizedBox(
                            height: 40.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                child: Image.asset("assets/A2.PNG"),
                              ),
                              Text(
                                "Hustler",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 10.0,
                          ),
                          new LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width - 50,
                            animation: true,
                            lineHeight: 20.0,
                            animationDuration: 2000,
                            percent: prospectcount == 5
                                ? 0.1
                                : prospectcount == 6
                                    ? 0.2
                                    : prospectcount == 7
                                        ? 0.4
                                        : prospectcount == 8
                                            ? 0.6
                                            : prospectcount == 9
                                                ? 0.9
                                                : prospectcount == 10
                                                    ? 1.0
                                                    : 1.0,
                            center: prospectcount == 0
                                ? Text("$prospectcount of 10 prospects")
                                : prospectcount == 5
                                    ? Text("5 more to unlock")
                                    : prospectcount == 6
                                        ? Text("4 more to unlock")
                                        : prospectcount == 7
                                            ? Text("3 more to unlock")
                                            : prospectcount == 8
                                                ? Text("2 more to unlock")
                                                : prospectcount == 9
                                                    ? Text("1 more to unlock"):
                                                    prospectcount == 10
                                                    ?  Text("Unlocked")
                                                    : Text("Unlocked"),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: Colors.greenAccent,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),*/
                  
                  Container(
                    color: Colors.white,
                    child: SizedBox(
                      height: 20.0,
                    ),
                  ),
                ],
              ),
            )));
  }
}
