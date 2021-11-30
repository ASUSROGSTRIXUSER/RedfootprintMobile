
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';






import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:redfootprintios/pages/ProfilePages/PublicProfilePage.dart';
import 'package:redfootprintios/services/authentication.dart';
import '../../services/database.dart';
import 'ForumDetails.dart';
import 'TagTiles.dart';



class MyQuestionPage extends StatefulWidget {
  MyQuestionPage();

  @override
  _MyQuestionPageState createState() => _MyQuestionPageState();
}

class _MyQuestionPageState extends State<MyQuestionPage> {
  Stream<QuerySnapshot> notifications;
  Stream<QuerySnapshot> myquestion;
  String _currentUserEmail;
  String _currentUserName;
  String _currentUserProfilePic;
  ScrollController scrollForum = new ScrollController();
  String _currentphotoUrl;
  //var mediaHeight;
  List _myActivities;
  List _like;
  String _myActivitiesResult;
  TextEditingController questionTextController = new TextEditingController();
  TextEditingController answerTextController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    _myActivities = [];
    _like = [];
    _myActivitiesResult = '';

    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;
        _currentUserName = user?.displayName;
        _currentUserProfilePic = user?.photoUrl;
        //  _like = [_currentUserName];
        MyDatabaseMethods().getMyQuestion(_currentUserEmail).then((forumRooms) {
          setState(() {
            myquestion = forumRooms;
          });
        });
      });
    });

    // var mediaHeight = MediaQuery.of(context).size.height;
    super.initState();
  }

  Widget _simplePopup(
          String forumRoom, bool isAnsweredpop, BuildContext context) =>
      PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: Colors.black,
          size: 25,
        ),
        onSelected: (value) {
          switch (value) {
            case 'Mark as Answered':
              {
                MyDatabaseMethods().questionMarkAsAnswered(forumRoom);

                // print('hello HW');
                break;
              }
            case 'Mark as Unanswered':
              {
                MyDatabaseMethods().questionMarkAsUnAnswered(forumRoom);
              }
              break;
            case 'Call':
              {}

              break;
            default:
          }
        },
        itemBuilder: (context) => [
          isAnsweredpop
              ? PopupMenuItem(
                  value: "Mark as Unanswered",
                  child: Text("Mark as Unanswered"),
                )
              : PopupMenuItem(
                  value: "Mark as Answered",
                  child: Text("Mark as Answered"),
                )

          /*     PopupMenuItem(
            value: "Close Question",
            child: Text("Close Question"),
          ),*/
        ],
      );

  _saveForm() {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivitiesResult = _myActivities.toString();
        for (var i = 0; i < _myActivities.length; i++) {
          print(_myActivities[i]);
        }
      });
    }
  }

  Widget myquestionTileList() {
    var mediaHeight = MediaQuery.of(context).size.height;
    try {
      return StreamBuilder(
        stream: myquestion,
        builder: (context, snapForumRooms) {
          if (snapForumRooms.connectionState == ConnectionState.active) {
            return ListView.builder(
                itemCount: snapForumRooms.data.documents.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // controller: scrollForum,
                itemBuilder: (context, index) {
                  if (snapForumRooms.data.documents.length == 0) {
                       return Container(
                color: Colors.white,
                child: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Looks like there is no topic about that category",
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
               // width: mediawidth,
              );
                  } else {
                    return forumTile(
                      snapForumRooms.data.documents[index].data['Question']
                          .toString(),
                      snapForumRooms
                          .data.documents[index].data['QuestioneeUserProfile']
                          .toString(),
                      snapForumRooms
                          .data.documents[index].data['QuestioneeUserEmail']
                          .toString(),
                      snapForumRooms
                          .data.documents[index].data['QuestioneeName']
                          .toString(),
                      snapForumRooms.data.documents[index].data['tags'],
                      snapForumRooms.data.documents[index].data['Likes'],
                      snapForumRooms
                          .data.documents[index].data['usersthatanswered'],
                      snapForumRooms.data.documents[index].data['isAnswered'],
                      snapForumRooms
                          .data.documents[index].data['isAdminApproved'],
                      snapForumRooms.data.documents[index].data['isPending'],
                    );
                  }
                });
          } else if (snapForumRooms.connectionState ==
              ConnectionState.waiting) {
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
      if (e.toString().contains(null)) {
        return Container(
          height: mediaHeight,
        );
      }
    }
  }

  Widget tagtilesList(List tagtilelist) {
    try {
      return ListView.builder(
          itemCount: tagtilelist.length,
          shrinkWrap: true,
          // scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          //  controller: scrollForum,
          itemBuilder: (context, index) {
            if (tagtilelist.length == 0) {
            } else {
              return TagTiles(
                tagTile: tagtilelist[index],
              );
            }
            return Container();
          });
    } catch (e) {
      if (e.toString().contains(null)) {
        return Container();
      }
    }
  }

  Widget forumTile(
      String question,
      String userProfile,
      String questioneeEmail,
      String questioneeName,
      List tags,
      List likes,
      List userthatresponse,
      bool isAnswered,
      bool isAdminApproved,
      bool isPending) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnswerForumPage(
                questioeeEmail: questioneeEmail,
                question: question,
                heroTag:
                    "Avatar" + userProfile.toString() + question.toString(),
                qustioneeProfile: userProfile.toString(),
                questioneeName: questioneeName,
                likelist: likes,
                isAnswered: isAnswered,
              ),
            ),
          );
        },
        child: Card(
            color: Color(0xFFF5F5F5),
            child: Container(
                margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //    crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PublicProfilePage(
                                          publicProfilePageEmail:
                                              questioneeEmail.toString(),
                                          heroTag: "ContactAvatar" +
                                              question.toString(),
                                        )));
                          },
                          child: Hero(
                            tag: "Avatar" +
                                userProfile.toString() +
                                question.toString(),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  CachedNetworkImageProvider(userProfile),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 20,
                        ),

                        Column(
                          children: [
                            Text(
                              questioneeName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text("asked a Question"),
                          ],
                        ),

                        SizedBox(
                          width: 30,
                        ),
                        isAdminApproved
                            ? Flexible(
                                child: _simplePopup(questioneeEmail + question,
                                    isAnswered, context))
                            : Container()
                        /*Flexible(
                          child: Text(
                            question,
                            maxLines: 3,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )*/
                        // Flexible(child: Text('05/10/2020'))
                      ],
                    ),
                    isPending
                        ? Container(
                            width: 220,
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(30.0),
                                topRight: const Radius.circular(30.0),
                                bottomLeft: const Radius.circular(30.0),
                                bottomRight: const Radius.circular(30.0),
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Approval Pending",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.refresh)
                                ],
                              ),
                            ))
                        : isAdminApproved
                            ? Container()
                            : Container(
                                width: 220,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(30.0),
                                    topRight: const Radius.circular(30.0),
                                    bottomLeft: const Radius.circular(30.0),
                                    bottomRight: const Radius.circular(30.0),
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Question Disapproved",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(Icons.error)
                                    ],
                                  ),
                                )),
                    isAnswered
                        ? Container(
                            width: 220,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(30.0),
                                topRight: const Radius.circular(30.0),
                                bottomLeft: const Radius.circular(30.0),
                                bottomRight: const Radius.circular(30.0),
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Flexible(child: Container( margin: EdgeInsets.all(15),  child: Text(
                                    "You mark this Answered",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),) )  , 
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.check)
                                ],
                              ),
                            ))
                        : Container(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0),
                          bottomLeft: const Radius.circular(30.0),
                          bottomRight: const Radius.circular(30.0),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // CircleAvatar(),

                            Flexible(
                              child: Text(
                                question,
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),

                            //     Text("5 Answers"),

                            // CircleAvatar(),

                            // Text('12:21pm')

                            // Text('12:21pm')r
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Likes: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.thumb_up,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(likes.length.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Answers: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.question_answer,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(userthatresponse.length.toString()),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text("Tags :",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 150,
                              child: tagtilesList(tags),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    /*    Container(
                      width: 100,
                      child: tagtilesList(tags),
                    ),*/
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    var mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      //    backgroundColor: Color(0xFFF5F5F5),
      //   backgroundColor: Color(0xFFA41D21),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                  child: myquestionTileList(),
                ),
              )
            ]),
      ),
    );
  }
}
