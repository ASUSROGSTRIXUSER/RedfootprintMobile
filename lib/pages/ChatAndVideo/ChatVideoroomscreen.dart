import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redfootprintios/pages/ChatAndVideo/ChatsOnly.dart';
import 'package:redfootprintios/pages/ChatAndVideo/ConversationScreen.dart';
import 'package:redfootprintios/pages/ChatAndVideo/GroupCallMenu.dart';
import 'package:redfootprintios/services/authentication.dart';

import '../../services/database.dart';

class ChatVideoroom extends StatefulWidget {
  ChatVideoroom();

  @override
  _ChatVideoroomState createState() => _ChatVideoroomState();
}

class _ChatVideoroomState extends State<ChatVideoroom> {
  Stream<QuerySnapshot> chats;
  String _currentUserEmail;
  String _url =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg";
  Stream<QuerySnapshot> searchSnapshot;
  ScrollController scrollChats = new ScrollController();
  bool isSearchingProspect = false;
  TextEditingController searchTextEditingController =
      new TextEditingController();
  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;
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
            .then((val) {
          setState(() {
            chats = val;
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
                        return ChatRoomsTile(
                          recipientUser: snap.data.documents[index].data['Name']
                              .toString(),
                          chatRoomId:
                              snap.data.documents[index].data['ChatRoomID'],
                          dataToAppbarRecipient: snap
                              .data.documents[index].data['Email']
                              .toString(),
                          lastChat:
                              snap.data.documents[index].data['LatestMessage'],
                          timeLastsent:
                              snap.data.documents[index].data['timeLastSent'],
                          url: snap.data.documents[index].data['ProfilePic'],
                          isSeen: snap.data.documents[index].data['isSeen'],
                          currentUserEmail: _currentUserEmail,
                        );
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
    var mediaHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
        length: 2,
        child: Scaffold(

          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size(0, 55),
            child: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
               
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              backgroundColor:Color(0xFFA41D21),
              bottom: TabBar(
                tabs: [
                  Tab(
                      icon: JelloIn(child: Column(
                    children: [
                      Icon(
                        Icons.chat,
                        color: Colors.white,
                      ),
                      Text("Chat Room"),
                    ],
                  ))),
                  Tab(
                      icon: JelloIn(child:Column(
                    children: [
                      Icon(
                        Icons.videocam,
                        color: Colors.white,
                      ),
                      Text("Video Room"),
                    ],
                  ) ,) ),
                ],
              ),
            ),
          ),
          body: TabBarView(children: [Chatroom(), IndexPage()]),
        ));
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

  ChatRoomsTile(
      {this.recipientUser,
      @required this.chatRoomId,
      this.auth,
      this.dataToAppbarRecipient,
      this.lastChat,
      this.url,
      this.timeLastsent,
      this.isSeen,
      this.currentUserEmail});

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
                    timeLastsent,
                    style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                ],
              ),
              subtitle: new Container(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: isSeen
                      ? new Text(
                          lastChat,
                          maxLines: 2,
                          style:
                              new TextStyle(color: Colors.grey, fontSize: 15.0),
                        )
                      : new Text(
                          lastChat,
                          maxLines: 2,
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        )),
            )));
  }
}
