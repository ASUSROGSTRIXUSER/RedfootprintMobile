
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:async';


import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:redfootprintios/pages/ProspectContacts/HighQualityClientModel.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

import 'HighQualityClientTiles.dart';
import 'ProspectsTiles.dart';

class ProspectContacts extends StatefulWidget {
  BaseAuth prospectcontactsauth;
  ProspectContacts({this.prospectcontactsauth});
  State<StatefulWidget> createState() => new _ProspectContactsState();
}

class _ProspectContactsState extends State<ProspectContacts> {
  List<HighQualityClientModel> highQualityList;
  Stream<QuerySnapshot> snapInit;
  Stream<QuerySnapshot> snapInitHQ;
  MyDatabaseMethods databaseMethods = new MyDatabaseMethods();
  TextEditingController searchPeople = new TextEditingController();
  Stream<QuerySnapshot> searchSnapshot;
  bool _isSearching = false;
  String _currentuser;
  ScrollController scrollsearch = new ScrollController();
  var dateTime;
  var time;
  var intoOne;
  bool _disposed = false;
  initiateSearchPeople() async {
    try {
      if (searchPeople.text.isNotEmpty) {
        await MyDatabaseMethods()
            .searchUserByName(searchPeople.text)
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

  @override
  void dispose() {
    //  searchSnapshot.drain();
    _disposed = true;
    super.dispose();
  }

  @override
  void initState() {
    // print(_timer());
    dateTime = DateTime.now().toString();
    time = TimeOfDay.fromDateTime(DateTime.now());
    intoOne = convertDateTimeDisplay(dateTime).trim() +
        time.toString().replaceAll("TimeOfDay", "");
    try {
      if(mounted){
setState(() {
        searchPeople.text = "";
      });
      Auth().getCurrentUser().then((value) {
        setState(() {
          _currentuser = value?.email;

          MyDatabaseMethods()
              .getHighQualityClients(_currentuser)
              .then((highqualityValues) {
            setState(() {
              snapInitHQ = highqualityValues;
            });
          });
          MyDatabaseMethods()
              .getScheduledProspects(_currentuser, intoOne)
              .then((value) {
            setState(() {
              snapInit = value;
            });
          });
        });
      });
      }
      
    } catch (e) {
      print(e.toString());
    }

    super.initState();
  }

  String _timer() {
    Timer(Duration(seconds: 1), () {
      if (!_disposed) {
        setState(() {
          dateTime = DateTime.now().toString();

          //startTimer();
          //var date = dateTime.Date;
          //  String convertedDate = new DateFormat("yyyy-MM-dd").format({date});
          time = TimeOfDay.fromDateTime(DateTime.now());
          intoOne = convertDateTimeDisplay(dateTime).trim() +
              time.toString().replaceAll("TimeOfDay", "");
        });
      }
      _timer();
    });
    // return intoOne + "timer";
  }

  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Color(0xFFA41D21),
        // backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Container(
                // height: 750,
                child: Column(children: <Widget>[
          Container(
              decoration: BoxDecoration(
                //    color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0),
                  bottomLeft: const Radius.circular(10.0),
                  bottomRight: const Radius.circular(10.0),
                ),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 5,
                    ),
                    //    Container(height: 2, color: Colors.grey),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text('Prospects to follow up',
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 2,
                    ),

                    SizedBox(
                      height: 3,
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
                        height:  MediaQuery.of(context).size.height/2,
                        margin: EdgeInsets.all(2),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: StreamBuilder(
                          stream: snapInit,
                          builder: (context, snapshot) {
                            try {
                              if (snapshot.data.documents.length == 0) {
                                //  print(snapshot.hasData);
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 130,
                                        child: Image.asset(
                                            "assets/Noschedule.jpg"),
                                      ),
                                      Text("No schedules"),
                                    ]);
                              }
                              if (snapshot.data.documents.length > 0) {
                                return ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return ProspectsTilesWidget(
                                        imgAssetPath: snapshot.data
                                            .documents[index].data['ProfilePic']
                                            .toString(),
                                        prospectName: snapshot
                                            .data.documents[index].data['Name']
                                            .toString(),
                                        number: snapshot.data.documents[index]
                                            .data['Contact Number']
                                            .toString(),
                                        email: snapshot
                                            .data.documents[index].data['Email']
                                            .toString(),
                                        prospectTilesWidgetAuth:
                                            widget.prospectcontactsauth,
                                        schedule: snapshot.data.documents[index]
                                            .data['Schedule']
                                            .toString(),
                                        currentUser: _currentuser,
                                      );
                                    });
                              }
                            } catch (e) {}
                            return Container();
                          },
                        )),
                    //    Container(height: 2, color: Colors.grey),

                    Container(
                      //   color: Color(0xFFF5F5F5),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text('High Quality Client',
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      height: 5,
                    ),
                    Container(
                        height:  MediaQuery.of(context).size.height/2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(10.0),
                            topRight: const Radius.circular(10.0),
                            bottomLeft: const Radius.circular(10.0),
                            bottomRight: const Radius.circular(10.0),
                          ),
                        ),
                        margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: StreamBuilder(
                            stream: snapInitHQ,
                            builder: (context, snapshotHQ) {
                              try {
                                if (snapshotHQ.data.documents.length == 0) {
                                  //    print(snapshotHQ.hasData);
                                  return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child:
                                              Image.asset("assets/HQback.png"),
                                        ),
                                        Text("No High Quality Clients"),
                                      ]);
                                }
                                if (snapshotHQ.data.documents.length > 0) {
                                  return ListView.builder(
                                      itemCount:
                                          snapshotHQ.data.documents.length,
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        return HighQualityClientWidgetTiles(
                                          imgAssetPath: snapshotHQ
                                                      .data
                                                      .documents[index]
                                                      .data['ProfilePic'] ==
                                                  null
                                              ? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"
                                              : snapshotHQ.data.documents[index]
                                                  .data['ProfilePic']
                                                  .toString(),
                                          highQualityProspectname: snapshotHQ
                                              .data
                                              .documents[index]
                                              .data['Name']
                                              .toString(),
                                          contactNumber: snapshotHQ
                                              .data
                                              .documents[index]
                                              .data['Contact Number']
                                              .toString(),
                                          highQualityClientEmail: snapshotHQ
                                              .data
                                              .documents[index]
                                              .data['Email']
                                              .toString(),
                                          highQualityTilesAuth:
                                              widget.prospectcontactsauth,
                                          jobTitle: snapshotHQ.data
                                              .documents[index].data['jobTitle']
                                              .toString(),
                                        );
                                      });
                                }
                              } catch (e) {}
                              return Container();
                            })),
                  ])),
        ]))));
  }
}
