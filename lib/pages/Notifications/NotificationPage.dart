
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:redfootprintios/services/authentication.dart';
import '../../services/database.dart';



class NotificationPage extends StatefulWidget {
  final BaseAuth authtoChatroom;
  NotificationPage({this.authtoChatroom});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Stream<QuerySnapshot> notifications;

  String _currentUserEmail;
  String _currentUserName;
  String _currentUserProfilePic;

  String _photoUrl;
  String _notificationStatus;

  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;
        _currentUserName = user?.displayName;
        _currentUserProfilePic = user?.photoUrl;

        MyDatabaseMethods().getNotification(_currentUserEmail).then((snapinit) {
          setState(() {
            notifications = snapinit;
          });
        });
      });
    });
    super.initState();
  }

  Widget notificationPageTileList() {
    try {
      return StreamBuilder(
        stream: notifications,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.active) {
            return ListView.builder(
                itemCount: snap.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return notificationTile(
                    snap.data.documents[index].data['NotificationMessage']
                        .toString(),
                    snap.data.documents[index].data['Email'].toString(),
                    snap.data.documents[index].data['Name'].toString(),
                    snap.data.documents[index].data['ChatRoomID'].toString(),
                    snap.data.documents[index].data['ProfilePicture'],
                    snap.data.documents[index].data['NotificationStatus'],
                    snap.data.documents[index].data['ContactNumber'],
                    snap.data.documents[index].data['timeNotificationSent'],
                    _currentUserProfilePic,
                    _currentUserEmail,
                    _currentUserName,
                    snap.data.documents[index].data['jobTitle'],
                  );
                });
          } else if (snap.connectionState == ConnectionState.waiting) {
            return Container(child: Center(child: CircularProgressIndicator()));
          } else {
            return Container(
              child: Text("No Recent Notification"),
            );
          }
        },
      );
    } catch (e) {
      if (e.toString().contains(null)) {
        return Container();
      }
    }
    
  }

  Widget notificationTile(
    String notificationMessage,
    String senderEmail,
    String senderName,
    String chatroomid,
    String photoURL,
    bool notificationStatus,
    String contactNumber,
    String timeSent,
    String currentuserProfilePic,
    String currentUserEmail,
    String currentUsername,
    String jobTitle,
  ) {
    return Card(
        elevation: 1.0,
        margin: EdgeInsets.all(5),
        child: new ListTile(
            leading: photoURL != null
                ? CircleAvatar(
                    radius: 28,
                    backgroundImage: CachedNetworkImageProvider(photoURL),
                  )
                : CircleAvatar(
                    radius: 28,
                    backgroundImage: CachedNetworkImageProvider(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                  ),
            title: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text('$notificationMessage',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  new Text(
                    timeSent,
                    style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                ]),
            subtitle: notificationStatus
                ? Row(children: [
                    new InkWell(
                      onTap: () {
                        Map<String, dynamic> notificationInfoMap = {
                          "Email": _currentUserEmail,
                          "Name": currentUsername,
                          "ChatRoomID": chatroomid,
                          "NotificationType": "ConfirmProspect",
                          "NotificationStatus": false,
                          "NotificationMessage":
                              "$currentUsername accepted you ",
                          "timeNotificationSent":
                              DateFormat.jm().format(DateTime.now()).toString(),
                          "ProfilePicture": currentuserProfilePic,
                        };

                        Map<String, dynamic> prospectInfoMap = {
                          "Email": senderEmail,
                          "Contact Number": contactNumber,
                          "Name": senderName,
                          "ProfilePic": photoURL,
                          "isOnChat": 'true',
                          "ChatRoomID": chatroomid,
                          "LatestMessage": "You accepted $senderName",
                          "timeLastSent": "",
                          "isSeen": false,
                          "isHighQualityClient": false,
                          "jobTitle": jobTitle,
                          "Schedule": "",
                        };
                        MyDatabaseMethods().addasProspect(
                            currentUserEmail, prospectInfoMap, senderEmail);

                        MyDatabaseMethods().updateCurrentUserNotficationAccept(
                            currentUserEmail, senderEmail, senderName);
                        MyDatabaseMethods().sendNotification(
                            senderEmail, notificationInfoMap, currentUserEmail);
                      },
                      child: new Container(
                        width: 100.0,
                        height: 30.0,
                        decoration: new BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Text(
                              'Confirm',
                              style: new TextStyle(
                                  fontSize: 10.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    new InkWell(
                      onTap: () {
                        MyDatabaseMethods().updateCurrentUserNotficationIgnore(
                            currentUserEmail, senderEmail, senderName);
                      },
                      child: new Container(
                        width: 100.0,
                        height: 30.0,
                        decoration: new BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Text(
                              'Ignore',
                              style: new TextStyle(
                                  fontSize: 10.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  ])
                : Container()),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Container(
        child: notificationPageTileList(),
      ),
    );
  }
}
