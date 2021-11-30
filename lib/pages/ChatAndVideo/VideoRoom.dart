
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:redfootprintios/pages/ChatAndVideo/VideoChatPage.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

class VideoRoom extends StatefulWidget {
  @override
  _VideoRoomState createState() => _VideoRoomState();
  String creatorName;
  String role;
  String roomName;
  String currentUserName;
  VideoRoom({this.creatorName, this.role, this.roomName, this.currentUserName});
}

class _VideoRoomState extends State<VideoRoom> {
  String _currentUserEmail;

  String businessWork;

  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;

        MyDatabaseMethods().getuserInfo(_currentUserEmail).then((businesstype) {
          setState(() {
            businessWork = businesstype.data['JobTitle'];
          });
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget usersListThatJOINED() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('VideoRooms')
            .where('RoomName', isEqualTo: widget.roomName)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.active) {
            // var list = snap.data.document.data['UsersThatJoined'];
            return ListView.builder(
                itemCount: snap.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return usersTile(
                    snap.data.documents[index].data['UsersThatJoined'],
                    snap.data.documents[index]
                        .data['UsersThatJoinedOccupation'],
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.of(context).pop();
          MyDatabaseMethods().leaveRoomDeleteRegister(
              widget.currentUserName + businessWork,
              widget.currentUserName,
              widget.roomName);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                MyDatabaseMethods().leaveRoomDeleteRegister(
                    widget.currentUserName + businessWork,
                    widget.currentUserName,
                    widget.roomName);
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: Color(0xFFA41D21),
            title: Text("Room: " + widget.roomName),
          ),
          body: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10),
                  Container(
                    color: Color(0xFFA41D21),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_drop_down),
                        Text(
                          "Active Users",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  usersListThatJOINED(),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Color(0xFFA41D21),
              label: Column(
                children: [
                  Icon(Icons.add_to_home_screen),
                  Text("Join Call"),
                ],
              ),
              onPressed: () async {
                await _handleCameraAndMic();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoCall(
                              channelName: widget.roomName,
                            )));
              }),
        ));
  }
}

Future<void> _handleCameraAndMic() async {
  await PermissionHandler().requestPermissions(
    [PermissionGroup.camera, PermissionGroup.microphone],
  );
}

// final String currentUserEmail;
usersTile(
  List userArayList,
  List workList,
  //  this.currentUserEmail,
) {
  @override
  var listinit;
  List<String> deanslist = new List();
  for (var i = 0; i < userArayList.length; i++) {
    Firestore.instance
        .collection('users')
        .where("Name", isEqualTo: userArayList[i])
        .getDocuments()
        .then((snapshot) => {
              snapshot.documents.forEach((doc) {
                print(doc.data['ProfilePic']);
                deanslist.add(doc.data['ProfilePic']);
                print(deanslist.length);
              })
            });
    return Container(
        padding: EdgeInsets.all(10),
        child: new ListView.builder(
            shrinkWrap: true,
            itemCount: userArayList.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new Column(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15.0),
                      topRight: const Radius.circular(15.0),
                      bottomLeft: const Radius.circular(15.0),
                      bottomRight: const Radius.circular(15.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        child: Text(
                          userArayList[index],
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      /*   Container(
                        margin: EdgeInsets.all(5),
                        child: Text(
                          workList[index]
                              .toString()
                              .replaceAll(userArayList[index], ""),
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),*/
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ]);
            }));
  }
}
