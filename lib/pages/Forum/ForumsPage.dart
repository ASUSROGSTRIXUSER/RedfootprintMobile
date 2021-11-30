import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:flutter_circular_text/circular_text/widget.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:redfootprintios/pages/ProfilePages/PublicProfilePage.dart';
import 'package:redfootprintios/pages/Forum/CreateQuestion.dart';
import 'package:redfootprintios/pages/Forum/MyQuestions.dart';
import 'package:redfootprintios/services/authentication.dart';
import '../../services/database.dart';
import 'ForumDetails.dart';
import 'TagTiles.dart';

class ForumPage extends StatefulWidget {
  final BaseAuth authtoChatroom;
  ForumPage({this.authtoChatroom});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  Stream<QuerySnapshot> notifications;
  Stream<QuerySnapshot> streamforumRooms;
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
      });
    });
 
    MyDatabaseMethods().getForumRooms().then((forumRooms) {
      setState(() {
        streamforumRooms = forumRooms;
      });
    });
    // var mediaHeight = MediaQuery.of(context).size.height;
    super.initState();
  }

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

  Widget forumPageTileList() {
    var mediaHeight = MediaQuery.of(context).size.height;
    var mediawidth = MediaQuery.of(context).size.width;
    try {
      return StreamBuilder(
        stream: streamforumRooms,
        builder: (context, snapForumRooms) {
          if (snapForumRooms.connectionState == ConnectionState.active) {
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
                width: mediawidth,
              );
            }
            return ListView.builder(
              reverse: true,
                itemCount: snapForumRooms.data.documents.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // controller: scrollForum,
                itemBuilder: (context, index) {
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
                      snapForumRooms.data.documents[index].data['isAnswered']);
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
      return Container(
        color: Colors.white,
        child: Text("Empty"),
        height: mediaHeight,
      );
    }
  }

  Widget _simplePopup(BuildContext context) => PopupMenuButton<String>(
        icon: Icon(
          Icons.widgets,
          color: Colors.white,
          size: 25,
        ),
        onSelected: (value) {
          switch (value) {
            case 'All':
              {
                MyDatabaseMethods().getForumRooms().then((forumRooms) {
                  streamforumRooms = forumRooms;
                });
                //    MyDatabaseMethods().questionMarkAsAnswered(forumRoom);

                // print('hello HW');
                break;
              }
            case 'Guide Related':
              {
                MyDatabaseMethods()
                    .getForumRoomsSorting("Guide Related")
                    .then((forumRooms) {
                  streamforumRooms = forumRooms;
                });
                //    MyDatabaseMethods().questionMarkAsAnswered(forumRoom);

                // print('hello HW');
                break;
              }
            case 'Health Related':
              {
                MyDatabaseMethods()
                    .getForumRoomsSorting("Health Related")
                    .then((forumRooms) {
                  streamforumRooms = forumRooms;
                });
              }
              break;
            case 'Review Related':
              {
                MyDatabaseMethods()
                    .getForumRoomsSorting("Review Related")
                    .then((forumRooms) {
                  streamforumRooms = forumRooms;
                });
              }

              break;
            case 'Strategy Related':
              {
                MyDatabaseMethods()
                    .getForumRoomsSorting("Strategy Related")
                    .then((forumRooms) {
                  streamforumRooms = forumRooms;
                });
              }

              break;
            case 'Problem Related':
              {
                MyDatabaseMethods()
                    .getForumRoomsSorting("Problem Related")
                    .then((forumRooms) {
                  streamforumRooms = forumRooms;
                });
              }

              break;
            case 'Testimony Related':
              {
                MyDatabaseMethods()
                    .getForumRoomsSorting("Testimony Related")
                    .then((forumRooms) {
                  streamforumRooms = forumRooms;
                });
              }

              break;
            default:
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: "All",
            child: Row(
              children: [
                Icon(Icons.public),
                SizedBox(
                  width: 5,
                ),
                Text("All")
              ],
            ),
          ),
          PopupMenuItem(
            value: "Guide Related",
            child: Row(
              children: [
                Icon(Icons.directions),
                SizedBox(
                  width: 5,
                ),
                Text("Guide Related"),
              ],
            ),
          ),
          PopupMenuItem(
            value: "Review Related",
            child: Row(
              children: [
                Icon(Icons.rate_review),
                SizedBox(
                  width: 5,
                ),
                Text("Review Related"),
              ],
            ),
          ),
          PopupMenuItem(
            value: "Health Related",
            child: Row(
              children: [
                Icon(
                  Icons.healing,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Health Related"),
              ],
            ),
          ),
          PopupMenuItem(
            value: "Strategy Related",
            child: Row(
              children: [
                Icon(
                  Icons.star,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Strategy Related"),
              ],
            ),
          ),
          PopupMenuItem(
            value: "Problem Related",
            child: Row(
              children: [
                Icon(Icons.scatter_plot),
                SizedBox(
                  width: 5,
                ),
                Text("Approach Related"),
              ],
            ),
          ),
          PopupMenuItem(
            value: "Testimony Related",
            child: Row(
              children: [
                Icon(Icons.people),
                SizedBox(
                  width: 5,
                ),
                Text("Testimony Related"),
              ],
            ),
          ),
        ],
      );
  Widget tagtilesList(List tagtilelist) {
    try {
      return GridView.count(
        crossAxisCount: 4,
        //itemCount: tagtilelist.length,
        shrinkWrap: true,
        // scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        //  controller: scrollForum,
        children: List.generate(tagtilelist.length, (index) {
          if (tagtilelist.length == 0) {
          } else {
            return TagTiles(
              tagTile: tagtilelist[index],
            );
          }
          return Container();
        }),
        // itemBuilder: (context, index) {

        //}
      );
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
  ) {
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
            shape: new RoundedRectangleBorder(
                side: new BorderSide(color: Colors.red[900], width: 2.0),
                borderRadius: BorderRadius.circular(10.0)),
            shadowColor: Colors.black,
            elevation: 50,
            color: Colors.white,
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
                          width: 10,
                        ),
                        isAnswered
                            ? Flexible(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Colors.greenAccent,
                                          borderRadius: BorderRadius.only(
                                            topLeft:
                                                const Radius.circular(50.0),
                                            topRight:
                                                const Radius.circular(50.0),
                                            bottomLeft:
                                                const Radius.circular(50.0),
                                            bottomRight:
                                                const Radius.circular(50.0),
                                          )),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      "Answered",
                                      style: TextStyle(fontSize: 8),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            //   topLeft: const Radius.circular(30.0),
                            //   topRight: const Radius.circular(30.0),
                            //   bottomLeft: const Radius.circular(30.0),
                            //  bottomRight: const Radius.circular(30.0),
                            ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                question,
                                maxLines: null,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              //    color: Colors.black,
                              width: MediaQuery.of(context).size.width - 70,
                              height: 50,
                              child: tagtilesList(tags),
                            )
                          ],
                        )
                      ],
                    ),
                    Card(
                        elevation: 50,
                        color: Colors.red[600],
                        child: Container(
                            margin: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(likes.length.toString()),
                                SizedBox(
                                  width: 20,
                                ),
                                Icon(
                                  Icons.question_answer,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(userthatresponse.length.toString()),
                              ],
                            )))
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    var mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      //    backgroundColor: Color(0xFFF5F5F5),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50.0),
            bottomRight: Radius.circular(50.0),
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        title: Text(
          'Discussions',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          _simplePopup(context),
          IconButton(
            icon: Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Color(0xFFA41D21),
                        bottom: TabBar(
                          tabs: [
                            Tab(
                                icon: Column(
                              children: [
                                Icon(Icons.create),
                                Text("Create a Question"),
                              ],
                            )),
                            Tab(
                                icon: Column(
                              children: [
                                Icon(Icons.query_builder),
                                Text("My Questions"),
                              ],
                            )),
                          ],
                        ),
                        title: Text('Create or Review Your Questions'),
                        centerTitle: true,
                      ),
                      body: TabBarView(
                          children: [CreateQuestionPage(), MyQuestionPage()]),
                    ));
              }));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /*   Container(
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
                  child:*/
              Container(
                //  height: mediaHeight,
                margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: forumPageTileList(),
              ),
              //)
            ]),
      ),
    );
  }
}
