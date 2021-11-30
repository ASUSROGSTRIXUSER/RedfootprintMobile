
import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:intl/intl.dart';
import 'package:redfootprintios/pages/ChatAndVideo/VideoRoom.dart';
import 'package:redfootprintios/pages/ProfilePages/PublicProfilePage.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:share/share.dart';


import '../../services/database.dart';



class VideoRoomList extends StatefulWidget {
  @override
  _VideoRoomListState createState() => _VideoRoomListState();
}

class _VideoRoomListState extends State<VideoRoomList> {
  Stream<QuerySnapshot> videoRooms;
  ScrollController scrollsearch = new ScrollController();
  ScrollController scrollContact = new ScrollController();
  String _currentUserEmail;
  String _photoUrl;
  DateTime selectedDate = DateTime.now();
  TextEditingController searchRoom = new TextEditingController();
  TextEditingController roompasswordController = new TextEditingController();
  Stream<QuerySnapshot> searchSnapshot;
  bool _isSearching = false;
  List<DocumentSnapshot> valuesrealtime;
  String _currentUserName;
  bool _roomPasswordvalidateError = false;
  var modifieddatalistValues;
  String businessWork;
  List string = [];
  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;
        _photoUrl = user?.photoUrl;
        _currentUserName = user?.displayName;

        MyDatabaseMethods().getuserInfo(_currentUserEmail).then((businesstype) {
          setState(() {
            businessWork = businesstype.data['JobTitle'];
          });
        });
        MyDatabaseMethods().getVideoRooms().then((snapshots) {
          setState(() {
            videoRooms = snapshots;
          });
        });
      });
    });
    super.initState();
  }

  initiateSearchPeople() async {
    try {
      if (searchRoom.text.isNotEmpty) {
        await MyDatabaseMethods().searchRoom(searchRoom.text).then((val) {
          setState(() {
            videoRooms = val;
            _isSearching = true;
          });
        });
      } else if (searchRoom.text.isEmpty) {
        setState(() {
          MyDatabaseMethods().getVideoRooms().then((snapshots) {
            setState(() {
              videoRooms = snapshots;
            });
          });
          _isSearching = false;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget shareButton(BuildContext context, String name) {
    final RenderBox box = context.findRenderObject();
    Share.share(name,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Widget searchList() {
    return StreamBuilder(
        stream: videoRooms,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.active) {
            return ListView.builder(
                itemCount: snap.data.documents.length,
                shrinkWrap: true,
                controller: scrollsearch,
                itemBuilder: (context, index) {
                  return SearchTile(
                    name: snap.data.documents[index].data['RoomName'],
                    // email: snap.data.documents[index].data['Email'],
                    //  photoURL: snap.data.documents[index].data['ProfilePic'],
                    // currentUserEmail: _currentUserEmail,
                  );
                });
          } else if (snap.connectionState == ConnectionState.waiting) {
            return Container(child: Center(child: CircularProgressIndicator()));
          } else {
            return Container(
              child: Text("No Room Found"),
            );
          }
        });
  }

  Widget videoRoomsList() {
    return Container(
        // height: 150,
        child: StreamBuilder(
      stream: videoRooms,
      // ignore: missing_return
      builder: (context, snap) {
        try {
          if (snap.data.documents.length == 0) {
            //  print(snapshot.hasData);
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/VideoRoomEmpty.PNG"),
                  Text("No Rooms Found"),
                ]);
          }
          if (snap.data.documents.length > 0) {
            return ListView.builder(
                itemCount: snap.data.documents.length,
                shrinkWrap: true,
                controller: scrollContact,
                itemBuilder: (context, index) {
                  return VideoRoomsTile(
                    roomName:
                        snap.data.documents[index].data['RoomName'].toString(),
                    contactEmail:
                        snap.data.documents[index].data['Email'].toString(),
                    roomtype:
                        snap.data.documents[index].data['RoomType'].toString(),
                    roomCreator:
                        snap.data.documents[index].data['CreatedBy'].toString(),
                    roompassword: snap
                        .data.documents[index].data['RoomPassword']
                        .toString(),
                    roompasswordController: roompasswordController,
                    roomPasswordValidator: _roomPasswordvalidateError,
                    currentUserName: _currentUserName,
                    businessWork: businessWork,
                  );
                });
          }
        } catch (e) {
          return Container();
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Stack(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(20.0),
                bottomRight: const Radius.circular(20.0),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(25, 15, 0, 10),
            child: Text(
              "Rooms",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                    bottomLeft: const Radius.circular(10.0),
                    bottomRight: const Radius.circular(10.0),
                  ),
                ),
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 30,
                    ),
                    Flexible(
                        child: TextField(
                      onChanged: (value) {
                        initiateSearchPeople();
                      },
                      controller: searchRoom,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintText: 'Search room',
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 13),
                          border: InputBorder.none),
                    )),
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Icon(Icons.search),
                    )
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.all(5),
                  //  height: mediaHeight,
                  child: videoRoomsList()),
            ],
          )
        ],
      )),
    );
    // )
  }
}

class VideoRoomsTile extends StatelessWidget {
  final String contactEmail;
  final String roomName;
  final String chatroomid;
  final String roomtype;
  final String roomCreator;
  final String roompassword;
  final bool roomPasswordValidator;
  final String currentUserName;
  final String businessWork;
  final TextEditingController roompasswordController;

  VideoRoomsTile({
    this.contactEmail,
    this.chatroomid,
    this.roomName,
    this.roomtype,
    this.roompassword,
    this.roompasswordController,
    this.roomPasswordValidator,
    this.roomCreator,
    this.currentUserName,
    this.businessWork,
  });
  showPromptWrongPassword(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Wrong Password"),
      actions: [okButton],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    // show the dialog
  }

  showEnterPassword(BuildContext context, TextEditingController roomPassword) {
    Widget okButton = FlatButton(
      child: Text("Enter Room"),
      onPressed: () {
        if (roompassword == roompasswordController.text) {
          MyDatabaseMethods().registerroomuserslist(
              currentUserName + businessWork, currentUserName, roomName);
          Navigator.of(context).pop();
          roompasswordController.clear();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoRoom(
                        roomName: roomName,
                      )));
        } else {
          showPromptWrongPassword(context);
        }

        //  Navigator.of(context).pop();
      },
    );
    Widget back = FlatButton(
      child: Text("Back"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Private Room Password"),
      content: TextField(
        maxLines: 2,
        keyboardType: TextInputType.multiline,
        controller: roompasswordController,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          errorText: roomPasswordValidator ? 'Wrong Password' : null,
          border: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          filled: true,
          hintText: "Password",
          fillColor: Colors.white70,
          hintStyle: TextStyle(color: Colors.grey[800]),
        ),
      ),
      actions: [okButton, back],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (roomtype == "Private") {
            showEnterPassword(context, roompasswordController);
          } else {
            MyDatabaseMethods().registerroomuserslist(
                currentUserName + businessWork, currentUserName, roomName);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoRoom(
                          roomName: roomName,
                          currentUserName: currentUserName,
                        )));
          }
        },
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFA41D21),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(50.0),
                  topRight: const Radius.circular(50.0),
                  bottomLeft: const Radius.circular(50.0),
                  bottomRight: const Radius.circular(50.0),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(children: [
                      Text("Room name:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.normal)),
                      Center(
                        child: Text(roomName,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                  Flexible(
                    child: Column(children: [
                      Text("Room Type:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.normal)),
                      Center(
                        child: Text(roomtype,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class SearchTile extends StatelessWidget {
  final String name;
  final String email;
  final String photoURL;
  final String currentUserEmail;
  SearchTile({
    this.name,
    this.email,
    this.photoURL,
    this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(photoURL)),
          SizedBox(
            width: 20,
          ),
          Column(children: [
            Text(name,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.bold)),
            Text(email,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))
          ]),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PublicProfilePage(
                            publicProfilePageEmail: email,
                            heroTag: "AvatarSP" + email.toString(),
                          )));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xFFA41D21),
                  borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Text("Profile", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
