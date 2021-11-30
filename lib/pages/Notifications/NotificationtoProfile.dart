
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:redfootprintios/services/CallsAndMessagesServices.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

class NotificationtoProfile extends StatefulWidget {
  String recipientEmail;
  BaseAuth authToContactProfile;
  String chatroomid;
  NotificationtoProfile(
      {this.recipientEmail, this.chatroomid, this.authToContactProfile});

  @override
  _NotificationtoProfileState createState() => _NotificationtoProfileState();
}

class _NotificationtoProfileState extends State<NotificationtoProfile> {
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  String _url =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg";
  String _currentUser = "";
  //String _chatroomID = "";
  String _userName = "";
  String _email = "";
  String _contactNumber = "";
  String _bioText = "";
  String _gender = "";
  LineChart performanceChart;

  @override
  void initState() {
    Auth().getCurrentUser().then((valueUser) {
      setState(() {
        _currentUser = valueUser?.email;
        // _chatroomID = MyDatabaseMethods()
        //      .getChatRoomId(_currentUser, widget.recipientEmail);
      });
    });
    MyDatabaseMethods()
        .getuserInfo(widget.recipientEmail)
        .then((recipientData) {
      setState(() {
        _contactNumber = recipientData.data['ContactNumber'];
        _bioText = recipientData.data['Bio'];
        _userName = recipientData.data['Name'];
        _url = recipientData.data['ProfilePic'];
        _gender = recipientData.data['Gender'];
      });
    });

    if (_url.toString() != "") {
      _url =
          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg";
    }

    super.initState();
  }

  showAlertDialog(BuildContext context, String prospectaddedName) {
    Widget okButton = FlatButton(
      child: Text("Close"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Prospect Request Accepted"),
      content: Text("$prospectaddedName can be seen on your Contacts"),
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

  acceptProspect(
      String authuserEmail, String reciepientName, String reciepientEmail) {
    try {
      Map<String, dynamic> prospectInfoMap = {
        "Email": widget.recipientEmail,
        "Contact Number": _contactNumber,
        "Name": _userName,
        "ProfilePic": _url,
        "isOnChat": 'true',
        "ChatRoomID": widget.chatroomid,
        "LatestMessage": "$reciepientName added you as prospect",
        "timeLastSent": "",
      };
      MyDatabaseMethods()
          .addasProspect(_currentUser, prospectInfoMap, widget.recipientEmail);
      Map<String, dynamic> notificationInfoMap = {
        "Email": _currentUser,
        "Name": _userName,
        "NotificationMessage": "accepted you",
        "timeNotificationSent":
            DateFormat.jm().format(DateTime.now()).toString(),
      };
      MyDatabaseMethods().sendNotification(
          widget.recipientEmail, notificationInfoMap, _currentUser);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 65,
                    backgroundImage: NetworkImage(_url),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 190,
                    height: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  acceptProspect(_currentUser, _userName,
                                      widget.recipientEmail);
                                  showAlertDialog(
                                      context, widget.recipientEmail);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 170,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(40.0),
                                      topRight: const Radius.circular(40.0),
                                      bottomLeft: const Radius.circular(40.0),
                                      bottomRight: const Radius.circular(40.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 26,
              ),
              Row(children: <Widget>[
                Text(
                  "Email",
                  // ignore: prefer_const_constructors
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(230, 0, 0, 0),
                  child: GestureDetector(
                    onTap: () {
                      _service.sendEmail(_email);
                    },
                    child: IconTile(
                      backColor: Colors.black,
                      imgAssetPath: "assets/email.png",
                    ),
                  ),
                )
              ]),
              SizedBox(
                height: 16,
              ),
              Text(
                widget.recipientEmail,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Row(children: <Widget>[
                Text(
                  "Contact Number",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(120, 0, 0, 0),
                  child: GestureDetector(
                    onTap: () {
                      _service.call(_contactNumber);
                    },
                    child: IconTile(
                      backColor: Colors.black,
                      imgAssetPath: "assets/call.png",
                    ),
                  ),
                )
              ]),
              SizedBox(
                height: 16,
              ),
              Text(
                _contactNumber,
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                "Gender",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                _gender,
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                "About",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                _bioText,
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  final String imgAssetPath;
  final Color backColor;

  IconTile({this.imgAssetPath, this.backColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16),
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
            color: backColor, borderRadius: BorderRadius.circular(15)),
        child: Image.asset(
          imgAssetPath,
          width: 20,
        ),
      ),
    );
  }
}
