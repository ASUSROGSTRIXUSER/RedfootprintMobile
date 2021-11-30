import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redfootprintios/services/authentication.dart';

import 'package:shimmer/shimmer.dart';

import '../../services/database.dart';
import 'ConversationScreen.dart';

class Chatroom extends StatefulWidget {
  Chatroom();

  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  Stream<QuerySnapshot> chats;
  String _currentUserEmail;
  Stream<QuerySnapshot> searchSnapshot;
  ScrollController scrollChats = new ScrollController();
  bool isSearchingProspect = false;
  List<String> valuesrealtime;
  TextEditingController searchTextEditingController =
      new TextEditingController();
  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;

        MyDatabaseMethods()
            .getContactsProfileChat(_currentUserEmail)
            .then((list) {
          setState(() {
            valuesrealtime = list;
          });
        });

        MyDatabaseMethods().getIsOnChats(_currentUserEmail).then((snapshots) {
          setState(() {
            chats = snapshots;
          });
        });
      });
    });
    super.initState();
  }

  initiateSearchOnChat() async {
    try {
      if (searchTextEditingController.text.isNotEmpty) {
        await MyDatabaseMethods()
            .searchOnChats(_currentUserEmail, searchTextEditingController.text)
            .then((val) async {
          setState(() {
            chats = val;
          });
        });

        await MyDatabaseMethods()
            .searchAlignProfilePic(
                _currentUserEmail, searchTextEditingController.text)
            .then((stringlist) {
          setState(() async {
            setState(() {
              valuesrealtime = stringlist;
            });
          });
        });
      } else if (searchTextEditingController.text.isEmpty) {
        setState(() {
          Auth().getCurrentUser().then((user) {
            setState(() {
              _currentUserEmail = user?.email;
              MyDatabaseMethods()
                  .getIsOnChats(_currentUserEmail)
                  .then((snapshots) {
                setState(() {
                  chats = snapshots;
                });
              });
            });
          });

          MyDatabaseMethods()
              .getContactsProfileChat(_currentUserEmail)
              .then((list) async {
            setState(() {
              valuesrealtime = list;
            });

            //    print(valuesrealtime.length);
          });
        });
      }
    } catch (e) {}
  }

  Widget chatRoomsList() {
    var mediaHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: chats,
        builder: (context, snap) {
          try {
            if (snap.data.documents.length == 0) {
              //  print(snapshot.hasData);
              return Container(
                  height: mediaHeight,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset("assets/ChatBack.png"),
                        Text("No Chats"),
                      ]));
            }
            if (snap.connectionState == ConnectionState.active) {
              return Container(
                  //   height: mediaHeight,
                  child: ListView.builder(
                      itemCount: snap.data.documents.length,
                      shrinkWrap: true,
                      controller: scrollChats,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        try {
                          return ChatRoomsTile(
                            recipientUser: snap
                                .data.documents[index].data['Name']
                                .toString(),
                            chatRoomId:
                                snap.data.documents[index].data['ChatRoomID'],
                            dataToAppbarRecipient: snap
                                .data.documents[index].data['Email']
                                .toString(),
                            lastChat: snap
                                .data.documents[index].data['LatestMessage'],
                            timeLastsent:
                                snap.data.documents[index].data['timeLastSent'],
                            url:
                                // snap.data.documents[index].data['ProfilePic'],
                                valuesrealtime[index] == ""
                                    ? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"
                                    : valuesrealtime[index],

                            //  snap.data.documents[index].data['ProfilePic'],
                            isSeen: snap.data.documents[index].data['isSeen'],
                            currentUserEmail: _currentUserEmail,
                            yMMD: snap.data.documents[index].data['yMMMD']
                                .toString(),
                          );
                        } catch (e) {
                          return Column(
                              //  mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(30),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300],
                                    highlightColor: Color(0xFFA41D21),
                                    //    enabled: _enabled,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        CircleAvatar(),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.0),
                                        ),
                                        Container(
                                          width: 40.0,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]);
                        }
                      }));
            } else if (snap.connectionState == ConnectionState.waiting) {
              return Container(
                  child: Center(child: CircularProgressIndicator()));
            } else {
              return Container(
                  child: Center(child: CircularProgressIndicator()));
            }
          } catch (e) {
            return Container(
              height: mediaHeight,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            isSearchingProspect
                ? Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFA41D21),
                      borderRadius: BorderRadius.only(
                        //      topLeft: const Radius.circular(30.0),
                        //      topRight: const Radius.circular(30.0),
                        bottomLeft: const Radius.circular(30.0),
                        bottomRight: const Radius.circular(30.0),
                      ),
                    ),
                    //  margin: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        //  color: Colors.white,
                        borderRadius: BorderRadius.only(
                          //      topLeft: const Radius.circular(30.0),
                          //      topRight: const Radius.circular(30.0),
                          bottomLeft: const Radius.circular(30.0),
                          bottomRight: const Radius.circular(30.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: TextField(
                            onChanged: (value) {
                              initiateSearchOnChat();
                            },
                            controller: searchTextEditingController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                filled: true,
                                //fillColor: Colors.white,
                                hintText: 'Search Conversations',
                                hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13),
                                border: InputBorder.none),
                          )),
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFA41D21),
                      borderRadius: BorderRadius.only(
                        //      topLeft: const Radius.circular(30.0),
                        //      topRight: const Radius.circular(30.0),
                        bottomLeft: const Radius.circular(30.0),
                        bottomRight: const Radius.circular(30.0),
                      ),
                    ),
                    //   margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            15,
                            0,
                            0,
                            0,
                          ),
                          child: Text(
                            "Chats",
                            style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(30.0),
                              topRight: const Radius.circular(30.0),
                              bottomLeft: const Radius.circular(30.0),
                              bottomRight: const Radius.circular(30.0),
                            ),
                          ),
                          child: IconButton(
                              color: Colors.black,
                              icon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  isSearchingProspect = true;
                                });
                              }),
                        ),
                      ],
                    )),
            Container(margin: EdgeInsets.all(4), child: chatRoomsList()),
          ],
        ),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String recipientUser;
  final String chatRoomId;
  final String dataToAppbarRecipient;
  final String lastChat;
  final BaseAuth auth;
  final String url;
  final String timeLastsent;
  final bool isSeen;
  final String currentUserEmail;
  final String yMMD;
  ChatRoomsTile(
      {this.recipientUser,
      @required this.chatRoomId,
      this.auth,
      this.dataToAppbarRecipient,
      this.lastChat,
      this.url,
      this.timeLastsent,
      this.isSeen,
      this.currentUserEmail,
      this.yMMD});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          MyDatabaseMethods().setSeen(dataToAppbarRecipient, currentUserEmail);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                        chatRoomId: chatRoomId,
                        authToConversationScreen: auth,
                        recipientEmail: dataToAppbarRecipient,
                        isSeen: isSeen,
                        lastmessage: lastChat,
                      )));
        },
        child: new Card(
            shape: new RoundedRectangleBorder(
                side: new BorderSide(color: Colors.red[900], width: 1.0),
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 1.0,
            color: Colors.white,
            child: new ListTile(
              leading: url != null
                  ? CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(url),
                      backgroundColor: Colors.transparent,
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                      backgroundColor: Colors.transparent,
                    ),
              title: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    recipientUser,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  new Text(
                    yMMD == null ? " " : yMMD,
                    style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                ],
              ),
              subtitle: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      child: Container(
                          margin: const EdgeInsets.only(top: 5.0, right: 15),
                          child: isSeen
                              ? new Text(
                                  lastChat,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: new TextStyle(
                                      color: Colors.grey, fontSize: 15.0),
                                )
                              : new Text(
                                  lastChat,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ))),
                  Flexible(
                    child: new Text(
                      timeLastsent,
                      style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                  )
                ],
              ),
            )));
  }
}
