import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:redfootprintios/services/authentication.dart';
import '../../services/database.dart';

class AnswerForumPage extends StatefulWidget {
  final BaseAuth authtoChatroom;
  final String question;
  final String heroTag;
  final String questioeeEmail;
  final String qustioneeProfile;
  final String questioneeName;
  final List likelist;
  final bool isAnswered;
  AnswerForumPage(
      {this.authtoChatroom,
      this.questioeeEmail,
      this.question,
      this.heroTag,
      this.qustioneeProfile,
      this.questioneeName,
      this.likelist,
      this.isAnswered});
  @override
  _AnswerForumPageState createState() => _AnswerForumPageState();
}

class _AnswerForumPageState extends State<AnswerForumPage> {
  Stream<QuerySnapshot> notifications;
  Stream<QuerySnapshot> streamAnswer;
  bool isLiked = false;
  bool isDisliked = false;
  String _currentUserEmail;
  String _currentUserName;
  String _currentUserProfilePic;

  String _currentphotoUrl;

  TextEditingController questionTextController = new TextEditingController();
  TextEditingController answerTextController = new TextEditingController();

  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;
        _currentUserName = user?.displayName;
        _currentUserProfilePic = user?.photoUrl;
        if (widget.likelist.contains(_currentUserName)) {
          setState(() {
            isLiked = true;
          });
        }
      });
    });

    MyDatabaseMethods()
        .getForumAnswer(widget.questioeeEmail, widget.question)
        .then((forumRooms) {
      streamAnswer = forumRooms;
    });
    super.initState();
  }

  Widget answerTileList() {
    try {
      return StreamBuilder(
        stream: streamAnswer,
        builder: (context, snapForumAnswerRooms) {
          if (snapForumAnswerRooms.connectionState == ConnectionState.active) {
            return ListView.builder(
                itemCount: snapForumAnswerRooms.data.documents.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return answerTile(
                    snapForumAnswerRooms.data.documents[index].data['Answer']
                        .toString(),
                    snapForumAnswerRooms
                        .data.documents[index].data['fromUserprofile']
                        .toString(),
                    snapForumAnswerRooms.data.documents[index].data['fromName']
                        .toString(),
                  );
                });
          } else if (snapForumAnswerRooms.connectionState ==
              ConnectionState.waiting) {
            return Container();
          } else {
            return Container(
              child: Text(""),
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

  Widget answerTile(String answer, String answerProfile, String answereeName) {
    //answerTile({this})

    return Card(
      child: Container(
          margin: EdgeInsets.all(20),
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(answerProfile),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  answereeName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    answer,
                    textAlign: TextAlign.justify,
                    //  widget.question,
                    //   maxLines: 3,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            )
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    //var mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        // backgroundColor: Color(0xFFA41D21),
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Color(0xFFA41D21),
            centerTitle: true,
            title: Text(
              'Question Page',
              style: TextStyle(color: Colors.white),
            )),
        body: SingleChildScrollView(
            child: Container(
          //  height: mediaHeight,
          margin: EdgeInsets.all(10),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            //  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                  shape: new RoundedRectangleBorder(
                      side: new BorderSide(color: Colors.red[900], width: 5.0),
                      borderRadius: BorderRadius.circular(10.0)),
                  shadowColor: Colors.black,
                  elevation: 10,
                  child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: widget.heroTag,
                                child:
                                    widget.qustioneeProfile.toString() != null
                                        ? CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    widget.qustioneeProfile
                                                        .toString()),
                                          )
                                        : CircleAvatar(),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      widget.questioneeName != null
                                          ? Text(
                                              widget.questioneeName,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(""),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      widget.isAnswered
                                          ? Flexible(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.greenAccent,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft: const Radius
                                                              .circular(50.0),
                                                          topRight: const Radius
                                                              .circular(50.0),
                                                          bottomLeft:
                                                              const Radius
                                                                      .circular(
                                                                  50.0),
                                                          bottomRight:
                                                              const Radius
                                                                      .circular(
                                                                  50.0),
                                                        )),
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Answered",
                                                    style:
                                                        TextStyle(fontSize: 8),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ]),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            //  crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Flexible(
                                child: Text(
                                  widget.question,
                                  //    question,
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                              // Flexible(child: Text('12:21pm'))
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              isLiked
                                  ? RaisedButton.icon(
                                      color: Color(0xFFF5F5F5),
                                      onPressed: () {
                                        MyDatabaseMethods().unliked(
                                            _currentUserName,
                                            widget.questioeeEmail +
                                                widget.question);
                                        Map<String, dynamic>
                                            notificationInfoMap = {
                                          "Email": _currentUserEmail,
                                          "Name": _currentUserName,
                                          "NotificationType":
                                              "LikedyourQuestion",
                                          "NotificationStatus": false,
                                          "NotificationMessage":
                                              "$_currentUserName liked your question ",
                                          "timeNotificationSent":
                                              DateFormat.jm()
                                                  .format(DateTime.now())
                                                  .toString(),
                                          "ProfilePicture":
                                              _currentUserProfilePic,
                                        };
                                        MyDatabaseMethods().sendNotification(
                                            widget.questioeeEmail,
                                            notificationInfoMap,
                                            _currentUserEmail);
                                        setState(() {
                                          isLiked = false;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      label: Text(
                                        "(You) Liked",
                                        style: TextStyle(fontSize: 12),
                                      ))
                                  : RaisedButton.icon(
                                      color: Color(0xFFF5F5F5),
                                      onPressed: () {
                                        MyDatabaseMethods().liked(
                                            _currentUserName,
                                            widget.questioeeEmail +
                                                widget.question);
                                        setState(() {
                                          isLiked = true;
                                          isDisliked = false;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.thumb_up,
                                        size: 18,
                                      ),
                                      label: Text(
                                        "Like",
                                        style: TextStyle(fontSize: 12),
                                      )),
                              SizedBox(
                                width: 30,
                              ),

                              // Flexible(child: Text('12:21pm'))
                            ],
                          ),
                        ],
                      ))),
              Card(
                  color: Color(0xFFA41D21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          "Answers",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      answerTileList(),
                    ],
                  )),
              widget.isAnswered
                  ? Container()
                  : Card(
                      color: // Color(0xFFF5F5F5),
                          Color(0xFFA41D21),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _currentUserProfilePic != null
                                ? CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        _currentUserProfilePic),
                                  )
                                : CircleAvatar(),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: answerTextController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      filled: true,
                                      hintStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      hintText: "Type in your text",
                                      fillColor: Colors.white),
                                  maxLines: null,
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: IconButton(
                                    iconSize: 25,
                                    icon: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (answerTextController.text == "") {
                                      } else {
                                        Map<String, dynamic> answerMap = {
                                          "Answer": answerTextController.text,
                                          "from": _currentUserEmail,
                                          "fromName": _currentUserName,
                                          "fromUserprofile":
                                              _currentUserProfilePic,
                                          "timestamps": DateTime.now()
                                        };
                                        MyDatabaseMethods().answered(
                                            answerTextController.text,
                                            widget.questioeeEmail +
                                                widget.question);
                                        print(widget.questioeeEmail +
                                            widget.question);
                                        MyDatabaseMethods().addAnswerQuestion(
                                          answerMap,
                                          widget.questioeeEmail,
                                          widget.question,

                                          //    questioneeEmail
                                        );
                                        setState(() {
                                          answerTextController.text = "";
                                        });
                                      }
                                    }))
                          ],
                        ),
                      )),
            ],
          ),
        )));
  }
}
