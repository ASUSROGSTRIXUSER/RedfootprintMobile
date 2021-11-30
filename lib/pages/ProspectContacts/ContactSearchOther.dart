import 'package:achievement_view/achievement_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:redfootprintios/pages/ProfilePages/PublicProfilePage.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:share/share.dart';

import 'package:shimmer/shimmer.dart';

import '../../services/database.dart';
import '../ChatAndVideo/GroupCallMenu.dart';

class ContactRoomSearch extends StatefulWidget {
  @override
  _ContactRoomSearchState createState() => _ContactRoomSearchState();
}

class _ContactRoomSearchState extends State<ContactRoomSearch> {
  Stream<QuerySnapshot> contacts;
  ScrollController scrollsearch = new ScrollController();
  ScrollController scrollContact = new ScrollController();
  String _currentUserEmail;
  String _photoUrl;
  DateTime selectedDate = DateTime.now();
  TextEditingController searchPeople = new TextEditingController();
  Stream<QuerySnapshot> searchSnapshot;
  bool _isSearching = false;
  List<String> valuesrealtime;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;
        _photoUrl = user?.photoUrl;
        /*  MyDatabaseMethods()
            .getContactsRealtime(_currentUserEmail)
            .then((list)  {
          setState(() {
            valuesrealtime = list;
          });*/

        // print(valuesrealtime.length);
      });

      MyDatabaseMethods().getContacts(_currentUserEmail).then((snapshots) {
        setState(() {
          //      contacts = snapshots;
        });
        //  });
      });
    });
    super.initState();
  }

  initiateSearchPeople() async {
    try {
      if (searchPeople.text.isNotEmpty) {
        await MyDatabaseMethods()
            .searchUserByNameAntiCrash(searchPeople.text)
            .then((val) {
          setState(() {
            searchSnapshot = val;
            _isSearching = true;
          });
        });
      } else if (searchPeople.text.isEmpty) {
        setState(() {
          _isSearching = false;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Null> _refreshContactInfo() async {
    MyDatabaseMethods().getContacts(_currentUserEmail).then((snapshots) {
      setState(() {
        contacts = snapshots;
      });
    });
  }

  Widget shareButton(BuildContext context, String name) {
    final RenderBox box = context.findRenderObject();
    Share.share(name,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Widget searchList() {
    return StreamBuilder(
        stream: searchSnapshot,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.active) {
            return ListView.builder(
                itemCount: snap.data.documents.length,
                shrinkWrap: true,
                controller: scrollsearch,
                itemBuilder: (context, index) {
                  return SearchTile(
                    name: snap.data.documents[index].data['Name'],
                    email: snap.data.documents[index].data['Email'],
                    photoURL: snap.data.documents[index].data['ProfilePic'] ==
                            ""
                        ? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"
                        : snap.data.documents[index].data['ProfilePic'],
                    currentUserEmail: _currentUserEmail,
                  );
                });
          } else if (snap.connectionState == ConnectionState.waiting) {
            return Container(child: Center(child: CircularProgressIndicator()));
          } else {
            return Container(
              child: Text("No User Found"),
            );
          }
        });
  }

  Widget contactRoomsList() {
    List profilepic;
    return Container(
        // height: 150,
        child: StreamBuilder(
      stream: contacts,
      builder: (context, snap) {
        try {
          if (snap.connectionState == ConnectionState.active) {
            if (snap.data.documents.length == 0) {
              //  print(snapshot.hasData);
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 130,
                      backgroundColor: Colors.white,
                      child: Image.asset("assets/searchpeople2.jpg"),
                    ),
                    Text("Search and add prospects"),
                  ]);
            }
            if (snap.data.documents.length > 0) {
              return ListView.builder(
                  itemCount: snap.data.documents.length,
                  shrinkWrap: true,
                  controller: scrollContact,
                  itemBuilder: (context, index) {
                    try {
                      return ContactRoomsTile(
                        contactName:
                            snap.data.documents[index].data['Name'].toString(),
                        contactEmail:
                            snap.data.documents[index].data['Email'].toString(),
                        photoURL: valuesrealtime[index] == ""
                            ? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"
                            : valuesrealtime[index],
                        chatroomid: snap
                            .data.documents[index].data['ChatRoomID']
                            .toString(),
                        currentUserEmail: _currentUserEmail,
                        contactNumber: snap
                            .data.documents[index].data['Contact Number']
                            .toString(),
                        isAccountType: snap
                            .data.documents[index].data['isHighQualityClient'],
                        jobTitle: snap.data.documents[index].data['jobTitle'],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //   CircleAvatar(),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
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
                  });
            }
          } else if (snap.connectionState == ConnectionState.waiting) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 130,
                    backgroundColor: Colors.white,
                    child: Image.asset("assets/searchpeople2.jpg"),
                  ),
                  Text("Search and add prospects"),
                ]);
          } else {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 130,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "assets/searchpeople2.jpg",
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text("Search and add prospects"),
                ]);
          }
        } catch (e) {
          return Container();
        }
      },
    ));
  }

  /*Widget contactRoomsListV2() {
    return Container(
        // height: 150,
        child: ListView.builder(
            itemCount: valuesrealtime.length,
            shrinkWrap: true,
            controller: scrollContact,
            itemBuilder: (context, index) {
              return contactTileV2(
                  modifieddatalistValues.data['Email'],
                  modifieddatalistValues.data['Name'],
                  modifieddatalistValues.data['ChatRoomID'],
                  modifieddatalistValues.data['ProfilePic'],
                  modifieddatalistValues.data['ContactNumber'],
                  modifieddatalistValues.data['JobTitle']);
            }));
  }*/

  @override
  Widget build(BuildContext context) {
    var mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refreshContactInfo,
          child: SingleChildScrollView(
              child: Stack(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Color(0xFFA41D21),
                  borderRadius: BorderRadius.only(
                    //  topLeft: const Radius.circular(10.0),
                    //      topRight: const Radius.circular(10.0),
                    bottomLeft: const Radius.circular(20.0),
                    bottomRight: const Radius.circular(20.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(25, 15, 0, 15),
                child: Text(
                  "Add Prospects",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0),
                        bottomLeft: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0),
                      ),
                    ),
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 30,
                        ),
                        Flexible(
                            child: TextField(
                          onChanged: (value) {
                            initiateSearchPeople();
                          },
                          controller: searchPeople,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: 'Search name',
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13),
                              border: InputBorder.none),
                        )),
                        Container(
                          margin: EdgeInsets.only(right: 15),
                          child: Icon(Icons.search),
                        )
                      ],
                    ),
                  ),
                  _isSearching
                      ? searchList()
                      : Container(
                          margin: EdgeInsets.all(15),
                          //  height: mediaHeight,
                          child: contactRoomsList()),
                ],
              )
            ],
          )),
        ));
  }
}

class ContactRoomsTile extends StatelessWidget {
  final String contactEmail;
  final String contactName;
  final String chatroomid;
  final BaseAuth auth;
  final String photoURL;
  final String contactNumber;
  final String currentUserEmail;
  final bool isAccountType;
  final String jobTitle;
  ContactRoomsTile({
    this.contactEmail,
    this.auth,
    this.chatroomid,
    @required this.photoURL,
    @required this.contactName,
    this.currentUserEmail,
    this.contactNumber,
    this.isAccountType,
    this.jobTitle,
  });
  Widget _simplePopup(bool accountType, BuildContext context) =>
      PopupMenuButton<String>(
        icon: Icon(
          Icons.arrow_forward_ios,
          color: Colors.black,
          size: 15,
        ),
        onSelected: (value) {
          switch (value) {
            case 'HQ':
              {
                MyDatabaseMethods()
                    .makeHighQualityClient(currentUserEmail, contactEmail);

                // print('hello HW');
                break;
              }
            case 'RHQ':
              {
                MyDatabaseMethods()
                    .makeasProspect(currentUserEmail, contactEmail);
              }
              break;
            case 'Call':
              {
                MyDatabaseMethods().callNumber(contactNumber);
              }
              break;
            case 'Share':
              {
                MyDatabaseMethods()
                    .share(context, '$contactName \n $contactNumber');
              }
              break;
            case 'Schedule a follow up':
              {
                MyDatabaseMethods().selectScheduleDate(
                    context, currentUserEmail, contactEmail, contactName);
              }
              break;
            default:
          }
        },
        itemBuilder: (context) => [
          accountType
              ? PopupMenuItem(
                  value: "RHQ",
                  child: Text("Remove as High Quality Client"),
                )
              : PopupMenuItem(
                  value: "HQ",
                  child: Text("Set as High Quality Client"),
                ),
          PopupMenuItem(
            value: "Schedule a follow up",
            child: Text("Schedule a follow up"),
          ),
          PopupMenuItem(
            value: "Share",
            child: Text("Share"),
          ),
          PopupMenuItem(
            value: "Call",
            child: Text("Call"),
          ),
        ],
      );
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PublicProfilePage(
                        publicProfilePageEmail: contactEmail.toString(),
                        heroTag:
                            "ContactAvatarOther" + contactNumber.toString(),
                      )));
        },
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(50.0),
                  topRight: const Radius.circular(50.0),
                  bottomLeft: const Radius.circular(50.0),
                  bottomRight: const Radius.circular(50.0),
                ),
                /* boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: Offset(0, 7), // changes position of shadow
                  ),
                ],*/
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Hero(
                      tag: "ContactAvatar" + contactNumber.toString(),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFFA41D21),
                        child: photoURL == null && photoURL == ""
                            ? CircleAvatar(
                                radius: 35,
                                backgroundImage: CachedNetworkImageProvider(
                                    "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                              )
                            : CircleAvatar(
                                radius: 35,
                                backgroundImage: CachedNetworkImageProvider(
                                    photoURL == "null" && photoURL == ""
                                        ? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"
                                        : photoURL),
                              ),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Column(children: [
                    Center(
                      child: Text(contactName,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.bold)),
                    ),
                    isAccountType
                        ? Center(
                            child: Text("High Quality Client",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'OverpassRegular',
                                    fontWeight: FontWeight.w400)),
                          )
                        : Container()
                  ]),
                  SizedBox(
                    width: 10,
                  ),
                  Row(children: [_simplePopup(isAccountType, context)])
                ],
              ),
            ),
          ],
        ));
  }
}

class SearchTile extends StatelessWidget {
  final String name;
  final String email;
  final String photoURL;
  final String currentUserEmail;
  SearchTile({
    this.name,
    this.email,
    this.photoURL,
    this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFA41D21),
            child: photoURL == null && photoURL == ""
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: CachedNetworkImageProvider(photoURL ==
                                null &&
                            photoURL == ""
                        ? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"
                        : photoURL))
                : CircleAvatar(
                    radius: 35,
                    backgroundImage: CachedNetworkImageProvider(photoURL ==
                                "null" &&
                            photoURL == ""
                        ? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"
                        : photoURL),
                  ),
          ),
          SizedBox(
            width: 20,
          ),
          Column(children: [
            Text(name,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.bold)),
            Text(email,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))
          ]),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PublicProfilePage(
                            publicProfilePageEmail: email,
                            heroTag: "AvatarSP" + email.toString(),
                          )));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xFFA41D21),
                  borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Text("Profile", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
