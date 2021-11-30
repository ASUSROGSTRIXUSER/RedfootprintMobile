
import 'package:flutter/material.dart';



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redfootprintios/services/database.dart';

import '../../services/authentication.dart';

class Searchscreen extends StatefulWidget {
  Searchscreen({this.authToSearchScreen});
  final BaseAuth authToSearchScreen;
  @override
  _SearchscreenState createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen> {
  TextEditingController searchTextEditingController =
      new TextEditingController();
  MyDatabaseMethods databaseMethods = new MyDatabaseMethods();

  Stream<QuerySnapshot> searchSnapshot;
  bool haveUserSearched = false;
  bool isLoading = false;
  String authcurrentuserEmail;

  initiateSearch() async {
    try {
      if (searchTextEditingController.text.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        await databaseMethods
            .searchUserByName(searchTextEditingController.text)
            .then((val) {
          setState(() {
            isLoading = false;
            haveUserSearched = true;
            searchSnapshot = val;
          });
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        authcurrentuserEmail = user?.email;
      });
    });
    super.initState();
  }

  Widget searchList() {
    return StreamBuilder(
        stream: searchSnapshot,
        builder: (context, snap) {
          return snap.hasData
              ? ListView.builder(
                  itemCount: snap.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return searchTile(
                      snap.data.documents[index].data['Name'],
                      snap.data.documents[index].data['Email'],
                      snap.data.documents[index].data['ProfilePic'],
                    );
                  })
              : Container();
        });
  }

  getChatRoomId(String a, String b) {
    if (a.hashCode <= b.hashCode) {
      return '$a-$b';
    } else {
      return '$b-$a';
    }
  }

  sendMessage(
      String authuserEmail, String reciepientName, String reciepientEmail) {
    List<String> users = [authuserEmail, reciepientEmail];
    String chatRoomId = getChatRoomId(authuserEmail, reciepientEmail);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
      "LatestMessage": "",
      "timeLastSent": "",
    };

    // MyDatabaseMethods().createChatRoom(chatRoomId, chatRoom);
  }

  Widget searchTile(String name, String email, String photoURL) {
    return Container(
      color: Colors.black26,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(photoURL),
          ),
          SizedBox(
            width: 20,
          ),
          Column(children: [
            Text(name,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
            Text(email,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))
          ]),
          Spacer(),
          GestureDetector(
              onTap: () {
                sendMessage(
                  authcurrentuserEmail,
                  name,
                  email,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text("Profile"),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: new Text('Search People'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    onChanged: (value) {
                      initiateSearch();
                    },
                    controller: searchTextEditingController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: 'Search by email',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none),
                  )),
                  Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(40)),
                    child: Icon(Icons.search),
                  )
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}
