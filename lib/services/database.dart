import 'package:achievement_view/achievement_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redfootprintios/services/CallsAndMessagesServices.dart';
import 'package:redfootprintios/services/authentication.dart';

import 'package:share/share.dart';

class MyDatabaseMethods {
  List<String> strings = [];
  List<String> stringsfinal = [];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  uploadUserinfo(usermap) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    Firestore.instance
        .collection('users')
        .document(user.email)
        .setData(usermap);
  }

  uploadProfilePic(String profilepath, String userEmail) async {
    Firestore.instance
        .collection('users')
        .document(userEmail)
        .updateData({"ProfilePic": profilepath});
  }

  updateBio(String bioDescription, String userEmail) async {
    Firestore.instance
        .collection('users')
        .document(userEmail)
        .updateData({"Bio": bioDescription});
  }

  share(BuildContext context, String name) {
    final RenderBox box = context.findRenderObject();
    Share.share(name,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  searchUserByName(String name) async {
    return Firestore.instance
        .collection('users')
        .where('Name', isGreaterThanOrEqualTo: name.toUpperCase())
        .where('Name', isLessThan: name.toLowerCase() + 'z')
        //   .where('isVerified', isEqualTo: "true")
        .snapshots();
  }

  searchExistingContactByName(String name, String currentuserEmail) async {
    return Firestore.instance
        .collection('users')
        .document(currentuserEmail)
        .collection("MyProspects")
        .where('Name', isGreaterThanOrEqualTo: name.toUpperCase())
        .where('Name', isLessThan: name.toLowerCase() + 'z')
        //   .where('isVerified', isEqualTo: "true")
        .snapshots();
  }

  searchUserByNameAntiCrash(String email) async {
    return Firestore.instance
        .collection('users')
        .orderBy('Name')
        .startAt([email.toUpperCase()]).endAt([email.toLowerCase() + '\uf8ff'])
        //   .where('Name', isGreaterThanOrEqualTo: email.toUpperCase())
        //.where('Name', isLessThan: email.toLowerCase() + 'z')
        //   .where('isVerified', isEqualTo: "true")
        .snapshots();
  }

  searchRoom(String roomName) async {
    return Firestore.instance
        .collection('VideoRooms')
        .where('RoomName', isGreaterThanOrEqualTo: roomName.toUpperCase())
        .where('RoomName', isLessThan: roomName.toLowerCase() + 'z')
        //   .where('isVerified', isEqualTo: "true")
        .snapshots();
  }

  getuserInfo(String email) async {
    return Firestore.instance.collection('users').document(email).get();
  }

  getuserInfoName(String name) async {
    return Firestore.instance
        .collection('users')
        .where("Name", isEqualTo: name)
        .getDocuments();
  }

  getUserChats(String itIsMyName) async {
    return Firestore.instance
        .collection('Chatroom')
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }

  getUserDashboard() async {
    return Firestore.instance
        .collection('users')
        .where('isVerified', isEqualTo: 'true')
        .snapshots();
  }

  getVideoRooms() async {
    return Firestore.instance
        .collection('VideoRooms')
        //  .where('isVerified', isEqualTo: 'true')
        .snapshots();
  }

  getNews() async {
    return Firestore.instance
        .collection('Events')
        .document("News")
        .collection("NewsData")
        .orderBy("Timeby", descending: true)
        .snapshots();
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    Firestore.instance
        .collection('Chatroom')
        .document(chatRoomId)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getIsOnChats(String currentuser) async {
    return Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        //  .where('isOnChat', isEqualTo: 'true')
        .orderBy('timeLastSentTimeStamp', descending: true)
        .snapshots();
  }

  getlastSender(String chatroomid) async {
    return Firestore.instance.collection('Chatroom').document(chatroomid).get();
  }

  getIsSeen(String currentuser, String contactEmail) async {
    return Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .document(contactEmail)
        .get();
  }

  searchOnChats(String currentUser, String entrySearch) async {
    return Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .where('Name', isGreaterThanOrEqualTo: entrySearch)
        .where('Name', isLessThan: entrySearch + 'z')
        .snapshots();
  }

  searchAlignProfilePic(String currentUser, String entrySearch) async {
    QuerySnapshot profileAlignSearch = await Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .where('Name', isGreaterThanOrEqualTo: entrySearch.toUpperCase())
        .where('Name', isLessThan: entrySearch.toLowerCase() + 'z')
        .getDocuments();
    List<DocumentSnapshot> _myDocContacts = profileAlignSearch.documents;
    for (var i = 0; i < _myDocContacts.length; i++) {
      await Firestore.instance
          .collection('users')
          .document(_myDocContacts[i].data["Email"])
          .get()
          .then((value) async {
        strings.add(value.data['ProfilePic']);
        //     print(value.data['ProfilePic']);
      });
      // returnee = strings;

      //   List<DocumentSnapshot> _myDocContactsList = _myDocList.documents;
    }
    return strings;
  }

  getContactsisAddable(String currentuserEmail, String prospectEmail) async {
    return Firestore.instance
        .collection('users')
        .document(currentuserEmail)
        .collection('MyProspects')
        .document(prospectEmail)
        .get()
        .catchError((e) {
      print(e.toString() + 'Database Error');
    });
  }

  getChatsUnseen(String prospectEmail) async {
    return Firestore.instance
        .collection('users')
        .document(prospectEmail)
        .collection('MyProspects')
        .where('isSeen', isEqualTo: false)
        .snapshots();
  }

  countUnseenChats(String currentUser) async {
    // bool unseen;
    QuerySnapshot _myDoc = await Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .where('isSeen', isEqualTo: false)
        .getDocuments();
    List<DocumentSnapshot> _myDocCount = _myDoc.documents;
    //print(_myDocCount.length);
    return _myDocCount.length; // Count of Documents in Collection
    /*if (_myDocCount.length == 0) {
      return unseen = false;
    } else {
      return unseen = true;
    }*/
  }

  getViewEventList() async {
    return Firestore.instance
        .collection('Events')
        .document("SpecialEvents")
        .collection('SpecialEventsData')
        .getDocuments();
  }

  countUnseenNotification(String currentUser) async {
    //  bool unseen;
    QuerySnapshot _myDoc = await Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('Notifications')
        .where('NotificationStatus', isEqualTo: true)
        //   .where('NotificationType', isEqualTo: 'LikedyourQuestion')
        .getDocuments();
    List<DocumentSnapshot> _myDocCount = _myDoc.documents;
    // _myDocCount.length; // Count of Documents in Collection
    return _myDocCount.length;
  }

  countProspects(String currentUser) async {
    //  bool unseen;
    QuerySnapshot _myDoc = await Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .getDocuments();
    List<DocumentSnapshot> _myDocCount = _myDoc.documents;
    // _myDocCount.length; // Count of Documents in Collection
    print(_myDocCount.length);
    return _myDocCount.length;
  }

  getContactsisOnline(String prospectEmail) async {
    return Firestore.instance
        .collection('users')
        .document(prospectEmail)
        .get()
        .catchError((e) {
      print(e.toString() + 'Database Error');
    });
  }

  isAlreadySentCurrentUserRequest(
      String currentuserEmail, String prospectEmail) async {
    return Firestore.instance
        .collection('users')
        .document(currentuserEmail)
        .collection('Notifications')
        .document(prospectEmail)
        .get()
        .catchError((e) {
      print(e.toString() + 'Database Error');
    });
  }

  getContacts(String currentuser) async {
    return Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .orderBy("Name", descending: false)
        .snapshots();
  }

  getContactsRealtime(String currentuser) async {
    QuerySnapshot _myDocList;
    var returnee;
    //strings.clear();
    Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .orderBy("Name", descending: false)
        .snapshots()
        .listen((event) async {
      for (var i = 0; i < event.documents.length; i++) {
        await Firestore.instance
            .collection('users')
            .document(event.documents[i].data["Email"])
            .get()
            .then((value) async {
          strings.insert(i, value.data['ProfilePic']);
        });
      }
    });
    // List<DocumentSnapshot> _myDocContacts = _myDoc.documents;

    return strings;
  }

  getContactsProfileChat(String currentuser) async {
    Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        //  .where('isOnChat', isEqualTo: 'true')
        .orderBy('timeLastSentTimeStamp', descending: true)
        .snapshots()
        .listen((event) async {
      for (var i = 0; i < event.documents.length; i++) {
        print(event.documents[i].data["Name"]);

        await Firestore.instance
            .collection('users')
            .document(event.documents[i].data["Email"])
            .get()
            .then((value) async {
          //print(value.data["Name"]  + "  add to  list order");
          //  strings.removeAt(i);
          // strings[i] =value.data['ProfilePic'];
          strings.insert(i, value.data['ProfilePic']);
          // strings.add(value.data['ProfilePic']);
        });
      }

      /* event.documents.forEach((result)async {

     
      
    Firestore.instance
          .collection('users')
          .document(result.data["Email"])
          .get()
          .then((value)  {
            
 print(value.data["Name"]);

        strings.add(value.data['ProfilePic']);
          strings.reversed;
      });
    
    
    //  print(result.data["Email"]);
    });*/
    });

    /* QuerySnapshot _myDocList;
    var returnee;   
   QuerySnapshot _myDoc = await Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        //  .where('isOnChat', isEqualTo: 'true')
        .orderBy('timeLastSentTimeStamp', descending: true)
      
        .getDocuments();
    List<DocumentSnapshot> _myDocContacts = _myDoc.documents;

    for (var i = 0; i < _myDocContacts.length; i++) {
      await Firestore.instance
          .collection('users')
          .document(_myDocContacts[i].data["Email"])
          .get()
          .then((value) async {
        strings.add(value.data['ProfilePic']);
        //     print(value.data['ProfilePic']);
      });
      // returnee = strings;

      //   List<DocumentSnapshot> _myDocContactsList = _myDocList.documents;
    }*/

    //  print(strings.length);
    // strings.forEach((element) {
    //   print(element);
    //  });
    return strings;
  }

  getProspects(String currentuser) async {
    return Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .where('isHighQualityClient', isEqualTo: false)
        .snapshots();
  }

  getScheduledProspects(
      String currentuser, String currentdateAndTimeNow) async {
    return Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .where('Schedule', isGreaterThanOrEqualTo: "2")
        .snapshots();
  }

  getTemplates(String jobTitle) async {
    return Firestore.instance
        .collection('ChatTemplate')
        .document('template')
        .collection(jobTitle)
        .snapshots();
  }

  getHighQualityClients(String currentuser) async {
    return Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .where('isHighQualityClient', isEqualTo: true)
        .snapshots();
  }

  getChatRoomId(String currentUser, String recipientUser) {
    if (currentUser.hashCode <= recipientUser.hashCode) {
      return '$currentUser-$recipientUser';
    } else {
      return '$currentUser-$recipientUser';
    }
  }

  callNumber(String contactnumber) {
    _service.call(contactnumber);
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection('Chatroom')
        .document(chatRoomId)
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots();
  }

  getNotification(String currentuserEmail) async {
    return Firestore.instance
        .collection('users')
        .document(currentuserEmail)
        .collection('Notifications')
        .orderBy("NotificationStatus", descending: true)
        .snapshots();
  }

  getForumRooms() async {
    return Firestore.instance
        .collection('ForumRooms')
        .where("isAdminApproved", isEqualTo: true)
       // .orderBy(descending: true)
       
        .snapshots();
  }

  getPendingQuestion() async {
    return Firestore.instance
        .collection("ForumRooms")
        .where("isPending", isEqualTo: true)
        .snapshots();
  }

  getVideoRoomUsersList(String roomName) async {
    print(roomName);
    return Firestore.instance
        .collection('VideoRooms')
        .where('RoomName', isEqualTo: roomName)
        .snapshots();
  }

  getForumRoomsSorting(String category) async {
    return Firestore.instance
        .collection('ForumRooms')
        .where("tags", arrayContains: category)
        .snapshots();
  }

  getMyQuestion(String currentUser) async {
    return Firestore.instance
        .collection('ForumRooms')
        .where("QuestioneeUserEmail", isEqualTo: currentUser)
        .snapshots();
  }

  viewEventsList() async {
    return Firestore.instance
        .collection('Events')
        .document("SpecialEvents")
        .collection("SpecialEventsData")
        .snapshots();
  }

  getCallStatus(String userEmail) async {
    return Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection("CallStatus")
        .document("status")
        .get();
    // return Firestore.instance.collection('users').document(email).get();
  }

  setCallMap(callMap) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    Firestore.instance
        .collection('users')
        .document(user.email)
        .collection('CallStatus')
        .document("status")
        .setData(callMap);
  }

  Future<void> sendcalltoUser(
      String prospectEmail, callMap, String currentUser) {
    Firestore.instance
        .collection('users')
        .document(prospectEmail)
        .collection('CallStatus')
        .document("status")
        .setData(callMap);

    Firestore.instance
        .collection('users')
        .document(prospectEmail)
        .collection('CallStatus')
        .document("status")
        .updateData(
            {'usersStatus': true, 'CallersName': currentUser}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> declinecalltoUser(String currentEmail) {
    Firestore.instance
        .collection('users')
        .document(currentEmail)
        .collection('CallStatus')
        .document("status")
        .updateData({
      'usersStatus': false,
      'CallersName': "",
      'Chatroom': ""
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> approvedQuestion(String nameQuestion) {
    Firestore.instance
        .collection('ForumRooms')
        .document(nameQuestion)
        .updateData({
      'isAdminApproved': true,
      'isPending': false,
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> disapprovedQuestion(String nameQuestion) {
    Firestore.instance
        .collection('ForumRooms')
        .document(nameQuestion)
        .updateData({
      'isAdminApproved': false,
      'isPending': false,
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> deleteEvent(String eventname) {
    Firestore.instance
        .collection('Events')
        .document("SpecialEvents")
        .collection('SpecialEventsData')
        .document(eventname)
        .delete();
  }

  Future<void> updateLink(String eventname, String eventlink) {
    Firestore.instance
        .collection('Events')
        .document("SpecialEvents")
        .collection('SpecialEventsData')
        .document(eventname)
        .updateData({
      "EventLink": eventlink,
    });
  }

  getForumAnswer(String questioneeEmail, String question) async {
    return Firestore.instance
        .collection("ForumRooms")
        .document(questioneeEmail + question)
        .collection("Answers")
        .orderBy('timestamps')
        .snapshots();
  }

  Future<void> sendNotification(
      String prospectEmail, notificationMap, String currentUser) {
    Firestore.instance
        .collection('users')
        .document(prospectEmail)
        .collection('Notifications')
        .document(currentUser)
        .setData(notificationMap)
        .catchError((e) {
      print(e.toString());
    });
  }

// ignore: missing_return
  Future<void> deleteNotification(String currentUser) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('Notifications')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
  }

  Future<void> setStatusOnline(String currentUser) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .updateData({'isOnline': true}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> setStatusOffline(String currentUser) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .updateData({'isOnline': false}).catchError((e) {
      print(e.toString());
    });
  }

  void showSuccessffulSchedule(
      String name, String timeSched, BuildContext context) {
    AchievementView(
      context,
      duration: Duration(seconds: 5),
      icon: Icon(
        Icons.alarm_add,
        color: Colors.black,
      ),
      color: Colors.white, //Color(0xFFA41D21)
      textStyleTitle: TextStyle(color: Colors.black),
      textStyleSubTitle: TextStyle(color: Colors.black),
      title: "$name scheduled at $timeSched ",
      subTitle: "Schedule set successfully",
      isCircle: true,
      listener: (status) {
        print(status);
      },
    )..show();
  }

  Future<Null> selectScheduleDate(BuildContext context, String currentUser,
      String prospectEmail, String prospectName) async {
    var date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(3000, 8));
    if (date != null) {
      print(date);
      var time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (time != null) {
        print(time);
        var intoOne = date.toString().replaceAll("00:00:00.000", '').trim() +
            time.toString().replaceAll("TimeOfDay", "");
        addSchedule(currentUser, prospectEmail, intoOne);
        showSuccessffulSchedule(prospectName, intoOne, context);
      }
    }
  }

  Future<void> addSchedule(
      String currentUser, String prospectEmail, String schedule) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .document(prospectEmail)
        .updateData({'Schedule': schedule});
  }

  Future<void> doneSchedule(String currentUser, String prospectEmail) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .document(prospectEmail)
        .updateData({'Schedule': ""});
  }

  Future<void> setSeen(String prospectEmail, String currentUser) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .document(prospectEmail)
        .updateData({'isSeen': true}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> unSeen(String prospectEmail, String currentUser) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .document(prospectEmail)
        .updateData({'isSeen': false}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> activeOnscreenStateSeen(
      String prospectEmail, String currentUser) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .document(prospectEmail)
        .updateData({'isSeen': true}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> makeHighQualityClient(String currentuser, String contactEmail) {
    Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .document(contactEmail)
        .updateData({'isHighQualityClient': true}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> makeasProspect(String currentuser, String contactEmail) {
    Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .document(contactEmail)
        .updateData({'isHighQualityClient': false}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> updateAccountDetails(
    String currentUser,
    String address,
    String education,
    String jobtitle,
    String work,
    String recreation,
    String motivation,
    String status,
    String gender,
    String birthdate,
    String mobileNumber,
  ) {
    Firestore.instance.collection('users').document(currentUser).updateData(
      {
        "Recreation": recreation,
        "Motivation": motivation,
        "Status": status,
        "Address": address,
        "Education": education,
        "Work": work,
        "JobTitle": jobtitle,
        "Gender": gender,
        "Birthday": birthdate,
        "ContactNumber": mobileNumber
      },
    ).catchError((e) {
      print(e.toString());
    });
  }

  // ignore: missing_return
  Future<void> updateLatestMessagetoReciepient(
      String prospectEmail,
      String message,
      String timeSent,
      String currentUser,
      String yMMMD,
      timeLastSentTimestamp) {
    Firestore.instance
        .collection('users')
        .document(prospectEmail)
        .collection('MyProspects')
        .document(currentUser)
        .updateData(
      {
        "LatestMessage": message,
        "timeLastSent": timeSent,
        "isOnChat": 'true',
        'yMMMD': yMMMD,
        "timeLastSentTimeStamp": timeLastSentTimestamp
      },
    ).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> updateMobileToken(String valueToken) {
    Auth().getCurrentUser().then((valueCurrentUser) {
      Firestore.instance
          .collection('users')
          .document(valueCurrentUser?.email)
          .updateData({"mobileToken": valueToken});
    });
  }

  // ignore: missing_return
  Future<void> getNotificationStatus(String currentuser, String prospectEmail) {
    Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('Notifications')
        .document(prospectEmail)
        .updateData({"NotificationStatus": false}).catchError((e) {
      print(e.toString());
    });
  }

  // ignore: missing_return
  Future<void> addasProspect(
      String currentUser, prospectInfo, String prospectEmail) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('MyProspects')
        .document(prospectEmail)
        .setData(prospectInfo)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> createVideoRoom(String roomname, videoroomMap) {
    Firestore.instance
        .collection('VideoRooms')
        .document(roomname)
        .setData(videoroomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> mobileTokenEmpty(String currentUser) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .updateData({"mobileToken": ""});
  }

  Future<void> updateCurrentUserNotficationAccept(
      String currentUser, String prospectEmail, String prospectName) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('Notifications')
        .document(prospectEmail)
        .updateData({
      "NotificationMessage": 'You accepted $prospectName',
      "NotificationStatus": false
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> updateCurrentUserNotficationIgnore(
      String currentUser, String prospectEmail, String prospectName) {
    Firestore.instance
        .collection('users')
        .document(currentUser)
        .collection('Notifications')
        .document(prospectEmail)
        .updateData({
      "NotificationMessage": 'You ignored $prospectName',
      "NotificationStatus": false
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> liked(String liker, String forumRoom) {
    Firestore.instance.collection('ForumRooms').document(forumRoom).updateData({
      "Likes": FieldValue.arrayUnion([liker])
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> answered(String liker, String forumRoom) {
    Firestore.instance.collection('ForumRooms').document(forumRoom).updateData({
      "usersthatanswered": FieldValue.arrayUnion([liker])
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> registerroomuserslist(
      String occupation, String userName, String videoRoomName) {
    Firestore.instance
        .collection('VideoRooms')
        .document(videoRoomName)
        .updateData({
      "UsersThatJoined": FieldValue.arrayUnion([userName]),
      "UsersThatJoinedOccupation": FieldValue.arrayUnion([occupation])
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> leaveRoomDeleteRegister(
      String occupation, String userName, String videoRoomName) {
    Firestore.instance
        .collection('VideoRooms')
        .document(videoRoomName)
        .updateData({
      "UsersThatJoined": FieldValue.arrayRemove([userName]),
      "UsersThatJoinedOccupation": FieldValue.arrayUnion([occupation])
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> questionMarkAsAnswered(String forumRoom) {
    Firestore.instance
        .collection('ForumRooms')
        .document(forumRoom)
        .updateData({"isAnswered": true}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> questionMarkAsUnAnswered(String forumRoom) {
    Firestore.instance
        .collection('ForumRooms')
        .document(forumRoom)
        .updateData({"isAnswered": false}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> unliked(String liker, String forumRoom) {
    Firestore.instance.collection('ForumRooms').document(forumRoom).updateData({
      "Likes": FieldValue.arrayRemove([liker])
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> deleteRoom(String roomName) {
    Firestore.instance.collection('VideoRooms').document(roomName).delete();
  }

  Future<bool> checkIfRoomExist(String roomName) async {
    bool exists = false;
    try {
      await Firestore.instance
          .collection("VideoRooms")
          .document(roomName)
          .get()
          .then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> addAnswerQuestion(
      answerfromUser, String questionUser, String question) async {
    // FirebaseUser user = await _firebaseAuth.currentUser();
    Firestore.instance
        .collection('ForumRooms')
        .document(questionUser + question)
        .collection('Answers')
        .add(answerfromUser)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addForumQuestion(questionfromUser, String question) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    Firestore.instance
        .collection('ForumRooms')
        .document(user.email + question)
        //   .collection('chats')
        .setData(questionfromUser)
        .catchError((e) {
      print(e.toString());
    });
  }

  // ignore: missing_return
  Future<void> addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection('Chatroom')
        .document(chatRoomId)
        .collection('chats')
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // ignore: missing_return
  Future<void> updateSelfchatcard(
      String recipient,
      String chatMessageData,
      String yMMD,
      String latestTimeSent,
      fieldvalueTimestamp,
      String currentuser) {
    Firestore.instance
        .collection('users')
        .document(currentuser)
        .collection('MyProspects')
        .document(recipient)
        .updateData(
      {
        "LatestMessage": chatMessageData,
        "timeLastSent": latestTimeSent,
        "isOnChat": 'true',
        "timeLastSentTimeStamp": fieldvalueTimestamp,
        "yMMMD": yMMD
      },
    ).catchError((e) {
      print(e.toString());
    });
  }
}
