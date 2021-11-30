import 'dart:async';

//import 'package:agora_rtc_engine/rtc_engine.dart';


import 'package:achievement_view/achievement_view.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

import 'VideoRoom.dart';
import 'VideoRoomList.dart';
import 'call.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();
  final _roomPasswordController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;
  bool _passwordvalidateError = false;

  ClientRole _role = ClientRole.Broadcaster;
  ClientRole _watch = ClientRole.Audience;
  String access = "Public";
  String currentuserName;
  @override
  void initState() {
    // TODO: implement initState
    Auth().getCurrentUser().then((value) {
      setState(() {
        currentuserName = value.displayName;
      });
    });
  }

  @override
  void dispose() {
   
    _channelController.dispose();
    super.dispose();
  }

  Widget createroom() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                /*  Image.asset(
                  "assets/CreateRoom1.jpg",
                  height: 200,
                ),*/
                Row(
                  children: <Widget>[
                    Expanded(
                        child: TextField(
                      controller: _channelController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          errorText:
                              _validateError ? 'Room name is needed' : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[800]),
                          hintText: "Room name",
                          fillColor: Colors.white70),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: "Public",
                      groupValue: access,
                      onChanged: (value) {
                        setState(() {
                          access = value;
                        });
                      },
                    ),
                    Column(children: [Icon(Icons.public), Text("Public")]),
                    SizedBox(
                      width: 10,
                    ),
                    Radio(
                      value: "Private",
                      groupValue: access,
                      onChanged: (value) {
                        setState(() {
                          access = value;
                        });
                      },
                    ),
                    Column(children: [Icon(Icons.lock_open), Text("Private")])
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                access == "Private"
                    ? Row(
                        children: <Widget>[
                          Expanded(
                              child: TextField(
                            controller: _roomPasswordController,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                errorText: _passwordvalidateError
                                    ? 'You need to set a password if you want it private'
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                filled: true,
                                hintStyle:
                                    new TextStyle(color: Colors.grey[800]),
                                hintText: "Room Password",
                                fillColor: Colors.white70),
                          ))
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: onJoin,
                          child: Text('Create'),
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(0, 55),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              bottom: TabBar(
                  unselectedLabelColor: Colors.redAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.redAccent),
                  tabs: [
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Colors.redAccent, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Create room"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Colors.redAccent, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Join room"),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          body: TabBarView(children: [
            createroom(),
            VideoRoomList(),
            //   Icon(Icons.games),
          ]),
        ));
  }

  showAlertDialog(
    BuildContext context,
  ) {
    Widget okButton = FlatButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Room Already Exist"),
      content: Text("Create Room Failed"),
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

  Future<void> onJoin() async {
    await _handleCameraAndMic();
    var exist = false;

    if (access == "Public") {
      print(access);
      setState(() {
        _channelController.text.isEmpty
            ? _validateError = true
            : _validateError = false;
      });
      if (_channelController.text.isEmpty) {
      } else {
        MyDatabaseMethods()
            .checkIfRoomExist(_channelController.text)
            .then((valueifExist) {
          setState(() {
            exist = valueifExist;
            if (exist == true) {
              showAlertDialog(context);
            } else {
              Map<String, dynamic> roominfo = {
                "RoomName": _channelController.text,
                "RoomType": "Public",
                "CreatedBy": currentuserName,
                "RoomPassword": "",
              };
              MyDatabaseMethods()
                  .createVideoRoom(_channelController.text, roominfo);
              // await for camera and mic permissions before pushing video page
              //

              // push video page with given channel name
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoRoom(
                    roomName: _channelController.text,
                    //role: _role,
                  ),
                ),
              );
            }
          });
        });
      }
    } else {
      setState(() {
        _channelController.text.isEmpty
            ? _validateError = true
            : _validateError = false;
        _roomPasswordController.text.isEmpty
            ? _passwordvalidateError = true
            : _passwordvalidateError = false;
      });
      if (_channelController.text.isEmpty &&
          _roomPasswordController.text.isEmpty) {
      } else {
        MyDatabaseMethods()
            .checkIfRoomExist(_channelController.text)
            .then((valueifExist) {
          setState(() {
            exist = valueifExist;
            if (exist == true) {
              showAlertDialog(context);
            } else {
              Map<String, dynamic> roominfo = {
                "RoomName": _channelController.text,
                "RoomType": "Private",
                "CreatedBy": currentuserName,
                "RoomPassword": _roomPasswordController.text
              };
              MyDatabaseMethods()
                  .createVideoRoom(_channelController.text, roominfo);
              // await for camera and mic permissions before pushing video page
              //

              // push video page with given channel name
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoRoom(
                    roomName: _channelController.text,
                    //role: _role,
                  ),
                ),
              );
            }
          });
        });
      }
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
}
