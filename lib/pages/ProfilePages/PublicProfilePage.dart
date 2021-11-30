import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as Path;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:redfootprintios/pages/ChatAndVideo/ConversationScreen.dart';
import 'package:redfootprintios/services/CallsAndMessagesServices.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class PublicProfilePage extends StatefulWidget {
  PublicProfilePage(
      {this.publicProfilePageEmail, this.pageSource, this.heroTag});
  String heroTag;
  String pageSource;
  String publicProfilePageEmail;
  State<StatefulWidget> createState() => new _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
   static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      
    ),
    Text(
      'Index 1: Likes',
      
    ),
    Text(
      'Index 2: Search',
      
    ),
    Text(
      'Index 3: Profile',
      
    ),
  ];



  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  String _userName = "";
 int _selectedIndex = 1;
 bool showphotos =false;
 bool showinfo = true;
  var _downUrl;
  String _email = "";
  String _contactNumber = "";
  String _bioText = "";
  String _facebookID = "";
  String _address = "";
  String _education = "";
  String _work = "";
  String _jobtitle = "";
  String _isOnChat = "";
  bool _isAddAble = true;
  bool _isUserTrue = false;
  bool _isOnNoti = false;
  String _currentUserEmail = "";
  String _currentUserProfilePic = "";
  String _currentUserName = "";
  String _currentUserPhoneNumber = "";
  String _chatroomid = "";
  String _currentJobTitle = "";
  String isUser = "";
  String _civilStatus = "";
  String _motivation = "";
  String _recreation = "";
  List<GestureDetector> listCar = new List<GestureDetector>();
  TextEditingController _bioEditingController = new TextEditingController();
  TextEditingController _facebookIDController = new TextEditingController();
  List<dynamic> fromfirestoreuserlist =List<dynamic>();
  final picker = ImagePicker();
  var numberofprospects;
  @override
  void initState() {
    try {
      Auth().getCurrentUser().then((currentValues) {
        setState(() {
          _currentUserEmail = currentValues?.email;
          _currentUserProfilePic = currentValues?.photoUrl;
          _currentUserName = currentValues?.displayName;
          // _currentUserPhoneNumber = currentValues?.phoneNumber;
               Firestore.instance.collection('users').document(widget.publicProfilePageEmail).collection("featuredphotos").orderBy("TimeUploaded").snapshots().listen((eventlistener) async{
        fromfirestoreuserlist.clear();
        for (var i = 0; i < eventlistener.documents.length; i++) {
          setState(() {
             fromfirestoreuserlist.insert(i, eventlistener.documents[i].data["photoUrl"]);
        });
     //   print(eventlistener.documents.length);
        }
       });

  


          MyDatabaseMethods()
              .countProspects(widget.publicProfilePageEmail)
              .then((prospectNumbers) {
            setState(() {
              numberofprospects = prospectNumbers;
            });
          });
          MyDatabaseMethods()
              .getuserInfo(_currentUserEmail)
              .then((currentUservalues) {
            setState(() {
              _currentUserPhoneNumber =
                  currentUservalues.data['ContactNumber'].toString();
              _currentJobTitle = currentUservalues.data['JobTitle'].toString();
            });
          });
          if (_currentUserEmail == widget.publicProfilePageEmail) {
            setState(() {
              _isAddAble = false;
              _isUserTrue = true;
              isUser = "(You)";
            });
          }
          MyDatabaseMethods()
              .isAlreadySentCurrentUserRequest(
                  _currentUserEmail, widget.publicProfilePageEmail)
              .then((isOnNoti) {
            setState(() {
              _isOnNoti = isOnNoti.data['NotificationStatus'];
              _chatroomid = isOnNoti.data['ChatRoomID'].toString();
            });
          });
          MyDatabaseMethods()
              .getContactsisAddable(
                  _currentUserEmail, widget.publicProfilePageEmail)
              .then((isUserOnChats) {
            setState(() {
              _isOnChat = isUserOnChats.data['isOnChat'].toString();
              _chatroomid = isUserOnChats.data['ChatRoomID'].toString();
            });

            if (_isOnChat == 'true') {
              setState(() {
                _isAddAble = false;
              });
            } else if (_isOnChat == "false") {
              setState(() {
                _isAddAble = true;
              });
            } else if (_isOnChat = null) {
              print('key to success');
            }
          });
        });
      });
    } catch (e) {
      if (e.toString().contains("NoSuchMethodError")) {
        print(e.toString() + 'error Here');
        setState(() {
          _isAddAble = true;
        });
      }
    }

    MyDatabaseMethods().getuserInfo(widget.publicProfilePageEmail).then((val) {
      setState(() {
        _userName = val.data['Name'].toString();
        _downUrl = val.data['ProfilePic'].toString();
        _email = widget.publicProfilePageEmail;
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
      });
    });

    super.initState();
  }

 Widget buildGridViewFeaturePhotos() {
    return fromfirestoreuserlist.length == 0? Container(child: Center( child: Text("No photos",style: TextStyle(color: Colors.black),),),):
    GridView.count(
      shrinkWrap: true,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: 
       List.generate(fromfirestoreuserlist.length, (index) {
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
            child: Container(           
              margin: EdgeInsets.all(1),
              child: CachedNetworkImage(
                imageUrl:
                fromfirestoreuserlist[index].toString(),
                height: 150,
               fit: BoxFit.cover
             
              ),
            ));
      })
    );
  }

  showAlertDialog(BuildContext context, String prospectaddedName,
      String message, String intro) {
    Widget okButton = FlatButton(
      child: Text("Close"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Prospect Added"),
      content: Text("$intro $prospectaddedName $message"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  addasProspectButton(String currentUser) {
    Map<String, dynamic> prospectInfoMap = {
      "Email": widget.publicProfilePageEmail,
      "Contact Number": _contactNumber,
      "Name": _userName,
      "ProfilePic": _downUrl,
      "isOnChat": 'true',
      "ChatRoomID": MyDatabaseMethods()
          .getChatRoomId(currentUser, widget.publicProfilePageEmail),
      "LatestMessage": "You added $_userName",
      "timeLastSent": "",
      "isSeen": true,
      "isHighQualityClient": false,
      "jobTitle": _jobtitle,
      "Schedule": "",
    };
    MyDatabaseMethods().addasProspect(
        currentUser, prospectInfoMap, widget.publicProfilePageEmail);

    Map<String, dynamic> notificationInfoMap = {
      "Email": currentUser,
      "Name": _currentUserName,
      "ChatRoomID": MyDatabaseMethods()
          .getChatRoomId(currentUser, widget.publicProfilePageEmail),
      "ContactNumber": _currentUserPhoneNumber,
      "NotificationType": "AddProspect",
      "NotificationStatus": true,
      "NotificationMessage": "$_currentUserName added you ",
      "timeNotificationSent": DateFormat.jm().format(DateTime.now()).toString(),
      "ProfilePicture": _currentUserProfilePic,
      "jobTitle": _currentJobTitle,
    };
    MyDatabaseMethods().sendNotification(
        widget.publicProfilePageEmail, notificationInfoMap, currentUser);
    //    MyDatabaseMethods().createChatRoom(chatRoomId, chatRoomMap)
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Color(0xFFA6140A),
          centerTitle: true,
          title: Text(
            'Profile Page',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  child: Container(
                width: double.infinity,
                height: 800.0,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        child: Stack(
                          children: <Widget>[
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
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
                                        tag: widget.heroTag,
                                        child: CircleAvatar(
                                          radius: 100,
                                          backgroundImage: (_downUrl != null &&
                                                  _downUrl != "")
                                              ? CachedNetworkImageProvider(
                                                  _downUrl,
                                                )
                                              : CachedNetworkImageProvider(
                                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg",
                                                ),
                                        ),
                                      ))
                                ]),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        child: Text('$_userName $isUser',
                            style: GoogleFonts.roboto(
                                fontSize: 26, color: Colors.black)),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      _isUserTrue
                          ? Container()
                          : _isAddAble
                              ? _isOnNoti
                                  ? new InkWell(
                                      onTap: () {
                                        Map<String, dynamic>
                                            notificationInfoMap = {
                                          "Email": _currentUserEmail,
                                          "Name": _currentUserName,
                                          "ChatRoomID": _chatroomid,
                                          "NotificationType": "ConfirmProspect",
                                          "NotificationStatus": false,
                                          "NotificationMessage":
                                              "$_currentUserName accepted you ",
                                          "timeNotificationSent":
                                              DateFormat.jm()
                                                  .format(DateTime.now())
                                                  .toString(),
                                          "ProfilePicture":
                                              _currentUserProfilePic,
                                        };

                                        Map<String, dynamic> prospectInfoMap = {
                                          "Email": _email,
                                          "Contact Number": _contactNumber,
                                          "Name": _userName,
                                          "ProfilePic": _downUrl,
                                          "isOnChat": 'true',
                                          "ChatRoomID": _chatroomid,
                                          "LatestMessage":
                                              "You accepted $_userName ",
                                          "timeLastSent": "",
                                          "isSeen": false,
                                          "isHighQualityClient": false,
                                          "jobTitle": _jobtitle,
                                          "Schedule": "",
                                          "timeLastSentTimeStamp":
                                              FieldValue.serverTimestamp()
                                        };
                                        MyDatabaseMethods().addasProspect(
                                            _currentUserEmail,
                                            prospectInfoMap,
                                            _email);

                                        MyDatabaseMethods()
                                            .updateCurrentUserNotficationAccept(
                                                _currentUserEmail,
                                                _email,
                                                _userName);
                                        MyDatabaseMethods().sendNotification(
                                            _email,
                                            notificationInfoMap,
                                            _currentUserEmail);
                                        showAlertDialog(context, _userName, '',
                                            'You accepted');
                                        setState(() {
                                          _isOnNoti = false;
                                          _isAddAble = false;
                                        });
                                      },
                                      child: new Container(
                                        width: 300.0,
                                        height: 50.0,
                                        decoration: new BoxDecoration(
                                          color: Color(0xFFA41D21),
                                          borderRadius:
                                              new BorderRadius.circular(20.0),
                                        ),
                                        child: new Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person_add,
                                                color: Colors.white),
                                            new Text(
                                              'Confirm',
                                              style: new TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : new InkWell(
                                      onTap: () {
                                        addasProspectButton(_currentUserEmail);
                                        showAlertDialog(context, _userName,
                                            "will be on your Contacts", "");
                                        setState(() {
                                          _isAddAble = false;
                                        });
                                      },
                                      child: new Container(
                                        width: 300.0,
                                        height: 50.0,
                                        decoration: new BoxDecoration(
                                          color: Color(0xFFA41D21),
                                          borderRadius:
                                              new BorderRadius.circular(20.0),
                                        ),
                                        child: new Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person_add,
                                                color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            new Text(
                                              'Add',
                                              style: new TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                              : new InkWell(
                                  onTap: () {
                                    MyDatabaseMethods()
                                        .getContactsisAddable(_currentUserEmail,
                                            widget.publicProfilePageEmail)
                                        .then((isUserOnChats) {
                                      setState(() {
                                        _chatroomid = isUserOnChats
                                            .data['ChatRoomID']
                                            .toString();

                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ConversationScreen(
                                                      recipientEmail:
                                                          _email.toString(),
                                                      chatRoomId: _chatroomid,
                                                    )));
                                      });
                                    });
                                  },
                                  child: new Container(
                                    width: 300.0,
                                    height: 50.0,
                                    decoration: new BoxDecoration(
                                      color: Color(0xFFA41D21),
                                      borderRadius:
                                          new BorderRadius.circular(20.0),
                                    ),
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.chat_bubble,
                                            color: Colors.white),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        new Text(
                                          'Message',
                                          style: new TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      SizedBox(
                        height: 10,
                      ),
                      Container (
                        height: 50,
                        margin: EdgeInsets.all(5),
                         decoration: BoxDecoration(
                                    color:Color(0xFFA41D21) ,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20.0),
                                      topRight: const Radius.circular(20.0),
                                      bottomLeft: const Radius.circular(20.0),
                                      bottomRight: const Radius.circular(20.0),
                                    ),
                                  ),
                        child:
                GNav(
                
                gap: 5,
                activeColor: Colors.black,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: Duration(milliseconds: 800),
                tabBackgroundColor:Colors.white,
                tabs: [
                  GButton(
                    icon: LineIcons.photo,
                    text: 'Photos',
                  ),
                  GButton(
                    icon: LineIcons.list,
                    text: 'Info',
                  ),
                  GButton(
                    icon: LineIcons.trophy,
                    text: 'Achievement',
                  ),
                 
                ],
               selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }),),
                _selectedIndex == 1?
                      Flexible(
                        child: Card(
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
                                            fontSize: 25, color: Colors.black))
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
                                    Flexible(
                                        child: Text('$_civilStatus',
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
                                      Icons.business_center,
                                      color: Color(0xFFA41D21),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Flexible(
                                        child: new Text(
                                      '$_jobtitle',
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
                                      Icons.work,
                                      color: Color(0xFFA41D21),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Flexible(
                                        child: new Text('$_work',
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
                                        child: new Text('$_motivation',
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
                                      Icons.directions_bike,
                                      color: Color(0xFFA41D21),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Flexible(
                                        child: new Text('$_recreation',
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
                                        child: new Text('$_email',
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
                                      Icons.phone,
                                      color: Color(0xFFA41D21),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Flexible(
                                        child: new Text('$_contactNumber',
                                            style: GoogleFonts.roboto(
                                                fontSize: 17,
                                                color: Colors.black)))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ):_selectedIndex == 0 ? Card(
                color: Colors.white,
                //   child: Padding(
                //    padding: const EdgeInsets.symmetric(
                //       vertical: 20.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Container(
                          margin: EdgeInsets.all(15),
                          child: Text("Photos",
                              style: GoogleFonts.tinos(
                                  fontSize: 25, color: Colors.black))),
                    ]),
                    Column(children: [                 
                    ]),
                    buildGridViewFeaturePhotos(),
                      SizedBox(
                        height: 20,
                      )
                  ],
                ),
                //  ),
              )
                      :
                      _selectedIndex == 2 ?  Card(
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
                        height: 10.0,
                      ),
                      Text(
                        "Baby Steps",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      new LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 50,
                        animation: true,
                        lineHeight: 20.0,
                        animationDuration: 2000,
                        percent: numberofprospects == 0
                            ? 0.0
                            : numberofprospects == 1
                                ? 0.2
                                : numberofprospects == 2
                                    ? 0.4
                                    : numberofprospects == 3
                                        ? 0.6
                                        : numberofprospects == 4
                                            ? 0.9
                                            : 1.0,
                        center: numberofprospects == 0
                            ? Text("$numberofprospects of 5")
                            : numberofprospects == 1
                                ? Text("$numberofprospects of 5")
                                : numberofprospects == 2
                                    ? Text("$numberofprospects of 5")
                                    : numberofprospects == 3
                                        ? Text("$numberofprospects of 5")
                                        : numberofprospects == 4
                                            ? Text("$numberofprospects of 5")
                                            : Text("Unlocked"),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: Colors.greenAccent,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      //   Text("Number of Prospects added"),
                      SizedBox(
                        height: 40.0,
                      ),
                      Text(
                        "Hustler",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      new LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 50,
                        animation: true,
                        lineHeight: 20.0,
                        animationDuration: 2000,
                        percent: numberofprospects == 5
                            ? 0.1
                            : numberofprospects == 6
                                ? 0.2
                                : numberofprospects == 7
                                    ? 0.4
                                    : numberofprospects == 8
                                        ? 0.6
                                        : numberofprospects == 9
                                            ? 0.9
                                            : numberofprospects == 10
                                                ? 1.0
                                                : 1.0,
                        center: numberofprospects == 0
                            ? Text("Locked")
                            : numberofprospects == 5
                                ? Text("5 more to unlock")
                                : numberofprospects == 6
                                    ? Text("4 more to unlock")
                                    : numberofprospects == 7
                                        ? Text("3 more to unlock")
                                        : numberofprospects == 8
                                            ? Text("2 more to unlock")
                                            : numberofprospects == 9
                                                ? Text("1 more to unlock")
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
              ):Container(),
                    ],
                  ),
                ),
              )),
             
             
              
              Container(
                color: Colors.white,
                child: SizedBox(
                  height: 50.0,
                ),
              ),
            ],
          ),
        ));
  }
}
