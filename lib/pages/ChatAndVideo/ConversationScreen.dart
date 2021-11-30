import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:chewie/chewie.dart';
import 'package:redfootprintios/pages/ChatAndVideo/ChatVideoinit.dart';
import 'package:redfootprintios/services/CallsAndMessagesServices.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';
import 'package:video_player/video_player.dart';

import 'call.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String recipientEmail;
  final bool isSeen;
  final BaseAuth authToConversationScreen;
  final String lastmessage;

  ConversationScreen(
      {this.recipientEmail,
      this.chatRoomId,
      this.authToConversationScreen,
      this.isSeen,
      this.lastmessage});
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  bool disposed = false;
  TextEditingController messageEditingController = TextEditingController();
  ScrollController _chatcontroller;
  ScrollController _templateController;
  String _recipientname = "";
  Stream<QuerySnapshot> chats;
  Stream<QuerySnapshot> templatesList;
  String _currentUserEmail;
  String _profpic =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg";
  String _recipientjobtitle = "";
  String _company = "";
  String _currentUserName = "";
  String _contactNumberTemplate = "";
  File _sendimage;
  File _sendVideo;
  String sentImageURl;
  String sentVideoURl;
  String _profilepicReciepient;
  String _recipientUserID;
  String _currentUserID;
  String chatToken;
  String _recipientmobileToken;
  String _currentUserCompany;
  String _currentUserJobTitle;
  String _currentUserProfile;
  String _recipientCompany;
  String _reciepientEmail;
  bool isTyping = false;
  bool _recipientisOnline = true;
  String _recipientContactNumber;
  final picker = ImagePicker();
  ClientRole _role = ClientRole.Broadcaster;
  bool showisSeen = true;
  bool inishowisSeen = false;
  String lastUserMessageEmail;
  String callersName;
  String videoRoomID;
  String callersProfile;
  var someoneisCalling = false;
  @override
  void initState() {
    try {
      //  lastmessage = widget.lastmessage;

      _timer();

      _chatcontroller = ScrollController();
      _chatcontroller.addListener(_scrollListener);
      MyDatabaseMethods().getuserInfo(widget.recipientEmail).then((recVal) {
        setState(() {
          _reciepientEmail = recVal.data['Email'];
          _recipientname = recVal.data['Name'];
          _profpic = recVal.data['ProfilePic'];
          _recipientjobtitle = recVal.data['JobTitle'];
          _recipientisOnline = recVal.data['isOnline'];
          _recipientUserID = recVal.data['userID'];
          _recipientmobileToken = recVal.data['mobileToken'];
          // print(_recipientmobileToken);
          _recipientContactNumber = recVal.data['ContactNumber'];
          _recipientCompany = recVal.data['Work'];

          MyDatabaseMethods().getTemplates(_recipientjobtitle).then((template) {
            setState(() {
              templatesList = template;
            });
          });
        });
      });
      MyDatabaseMethods().getChats(widget.chatRoomId).then((val) {
        setState(() {
          chats = val;
        });
      });
      Auth().getCurrentUser().then((value) {
        setState(() {
          _currentUserEmail = value?.email;
          _currentUserName = value?.displayName;
          _currentUserID = value?.uid;
          //  print(_currentUserID);
          MyDatabaseMethods()
              .getuserInfo(_currentUserEmail)
              .then((currentUserValue) {
            setState(() {
              _contactNumberTemplate =
                  currentUserValue.data['ContactNumber'].toString();
              _currentUserProfile =
                  currentUserValue.data['ProfilePic'].toString();
              _currentUserJobTitle =
                  currentUserValue.data['JobTitle'].toString();
              _currentUserCompany = currentUserValue.data['Work'].toString();
            });
          });
        });
      });
    } catch (e) {
      print(e);
    }
    //print(_chatcontroller.position.pixels);

    // _controller.jumpTo(_controller.position.maxScrollExtent);

    super.initState();
  }

  String _timer() {
    Timer(Duration(seconds: 2), () {
      if (!disposed) {
        try {
          MyDatabaseMethods()
              .getlastSender(widget.chatRoomId)
              .then((lastuserMessage) {
            setState(() {
              lastUserMessageEmail = lastuserMessage.data['sendBy'];
              if (lastUserMessageEmail == null) {
                setState(() {
                  inishowisSeen = false;
                });
              }
            });

            //print(lastUserMessageEmail);
          });
          MyDatabaseMethods().activeOnscreenStateSeen(
            _reciepientEmail,
            _currentUserEmail,
          );
          // print("Updating");
          MyDatabaseMethods()
              .getIsSeen(_reciepientEmail, _currentUserEmail)
              .then((seenvalue) {
            setState(() {
              inishowisSeen = seenvalue.data['isSeen'];
              // lastmessage = seenvalue.data['LatestMessage'];

              // print(lastmessage);
            });
          });

          MyDatabaseMethods()
              .getCallStatus(_currentUserEmail)
              .then((callstatus) {
            setState(() {
              someoneisCalling = callstatus.data["usersStatus"];
              callersName = callstatus.data["CallersName"];
              videoRoomID = callstatus.data["Chatroom"];
              callersProfile = callstatus.data['CallersProfilePic'];
            });
          });
        } catch (e) {}

        // MyDatabaseMethods().unSeen(_currentUserEmail, _reciepientEmail);
        /*   MyDatabaseMethods().getCallStatus(_currentUserEmail).then((callstatus) {
          setState(() {
            someoneisCalling = callstatus.data["usersStatus"];
            callersName = callstatus.data["CallersName"];
            videoRoomID = callstatus.data["Chatroom"];
            callersProfile = callstatus.data['CallersProfilePic'];
          });
        });*/

        _timer();
      }
    });
  }

  _scrollListener() {
    if (_chatcontroller.offset != _chatcontroller.position.maxScrollExtent)
      setState(() {
        showisSeen = false;
      });
    if (_chatcontroller.offset == _chatcontroller.position.minScrollExtent) {
      setState(() {
        showisSeen = true;
      });
    }

    ///print(showisSeen);
  }

  final String serverToken =
      "AAAAAHlvQZo:APA91bH0XWDW1ShdKuOXfrebHwW4DYcZjuLdlYp1sQFb8aIsxjjITxTeD0FMRPnwbMs8c4K4ToyS-wXosuosSikXwYMHYGZkVvKDd2uN6xiAm7iIO35WDNPtb4WWWoM033SNpu_2ssZJ";
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future<Map<String, dynamic>> sendAndRetrieveMessage(
      String token, String message, String mobileTokenInput) async {
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': message,
            'title': _currentUserName,
            'sound': 'default'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': mobileTokenInput,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }

  Widget chatMessages() {
    return Stack(
      children: [
        Container(
            margin: EdgeInsets.only(bottom: 130),
            child: StreamBuilder(
              stream: chats,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? ListView.builder(
                        reverse: true,
                        controller: _chatcontroller,
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return MessageTile(
                            message:
                                snapshot.data.documents[index].data['message'],
                            sendByMe: _currentUserEmail ==
                                snapshot.data.documents[index].data['sendBy'],
                            isImage: snapshot
                                .data.documents[index].data['message']
                                .toString()
                                .contains('.jpg'),
                            isVideo: snapshot
                                .data.documents[index].data['message']
                                .toString()
                                .contains('.MP4'),
                            recipientUserProfile: _profpic,
                            isOnline: _recipientisOnline,
                            //   showSeen: widget.isSeen,
                          );
                        })
                    : Container();
              },
            )),
        widget.lastmessage == "You accepted $_recipientname"
            ? Container()
            : widget.lastmessage == "You added $_recipientname"
                ? Container()
                : showisSeen
                    ? inishowisSeen
                        ? showisSeen
                            ? Positioned(
                                right: 10,
                                bottom: 115,
                                child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 5, 10, 0),
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  _profpic),
                                        ),
                                      ],
                                    )),
                              )
                            : Container()
                        : lastUserMessageEmail == widget.recipientEmail
                            ? Container()
                            : Positioned(
                                right: 10,
                                bottom: 115,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
                                  color: Colors.transparent,
                                  child: Row(children: [
                                    Text("Sent"),
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.grey,
                                    )
                                  ]),
                                ),
                              )
                    : Container(),
      ],
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": _currentUserEmail,
        "message": messageEditingController.text,
        'time': FieldValue.serverTimestamp(),
      };
      MyDatabaseMethods().unSeen(_currentUserEmail, widget.recipientEmail);
      MyDatabaseMethods().createChatRoom(widget.chatRoomId, chatMessageMap);
      MyDatabaseMethods().updateSelfchatcard(
          widget.recipientEmail,
          messageEditingController.text,
          DateFormat.yMd('en_US').format(DateTime.now()).toString(),
          DateFormat.jm().format(DateTime.now()).toString(),
            FieldValue.serverTimestamp(),
          _currentUserEmail);
      sendAndRetrieveMessage(
          chatToken, messageEditingController.text, _recipientmobileToken);
      MyDatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
      MyDatabaseMethods().updateLatestMessagetoReciepient(
          widget.recipientEmail,
          messageEditingController.text,
          DateFormat.jm().format(DateTime.now()).toString(),
          _currentUserEmail,
          DateFormat.yMd('en_US').format(DateTime.now()).toString(),
          FieldValue.serverTimestamp());
      setState(() {
        messageEditingController.text = "";
      });
      //  Timer(
      //      Duration(milliseconds: 500),
      //     () =>
      //        _chatcontroller.jumpTo(_chatcontroller.position.maxScrollExtent));
    }
  }

  showAlertDialog(BuildContext context, String errormessage) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text(errormessage),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future getImage(String senderName, String reciepient) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
  await _handleCameraAndMic();
    setState(() {
      _sendimage = File(pickedFile.path);
    });
    String fileName = Path.basename(_sendimage.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('ChatPhotos/$fileName-$senderName-$reciepient');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_sendimage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    sentImageURl = await taskSnapshot.ref.getDownloadURL();
    Map<String, dynamic> chatMessageMap = {
      "sendBy": _currentUserEmail,
      "message": sentImageURl,
      'time': FieldValue.serverTimestamp(),
    };
    MyDatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
  }

  Future getVideo(String senderName, String reciepient) async {
    final file = await ImagePicker.pickVideo(source: ImageSource.gallery);

    setState(() {
      _sendVideo = File(file.path);
    });
    //String fileName = Path.basename(_sendVideo.path);
    if (file.lengthSync() > 5e+7) {
      showAlertDialog(context, "Video size too large");
    } else {
      //  String fileName = Path.basename(_sendVideo.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('ChatVideos/MP4-$senderName-$reciepient-.MP4');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(
          _sendVideo, StorageMetadata(contentType: 'video/mp4'));
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      sentVideoURl = await taskSnapshot.ref.getDownloadURL();
      Map<String, dynamic> chatMessageMap = {
        "sendBy": _currentUserEmail,
        "message": sentVideoURl,
        'time': FieldValue.serverTimestamp(),
      };
      MyDatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  Future<void> onJoin() async {
    // update input validation

    if (widget.chatRoomId.toString().isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: widget.chatRoomId.toString(),
            recipientUser: _reciepientEmail,
            role: _role,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    disposed = true;
    //  print(disposed);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return someoneisCalling
        ? Scaffold(
            body: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    callersName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 30),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: CachedNetworkImageProvider(callersProfile),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Wants to Video Chat",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: 75),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.call_end,
                          size: 50,
                        ),
                        color: Colors.redAccent,
                        onPressed: () async {
                          MyDatabaseMethods()
                              .declinecalltoUser(_currentUserEmail);
                        },
                      ),
                      SizedBox(width: 100),
                      IconButton(
                          icon: Icon(
                            Icons.call,
                            size: 50,
                          ),
                          color: Colors.green,
                          onPressed: () async {
                            await PermissionHandler().requestPermissions(
                              [
                                PermissionGroup.camera,
                                PermissionGroup.microphone
                              ],
                            );
                            // push video page with given channel name
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallPage(
                                  channelName: videoRoomID.toString(),
                                  role: _role,
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Color(0xFFF5F5F5),
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Color(0xFFA41D21),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _recipientisOnline
                      ? Stack(children: [
                          _profpic != null
                              ? CircleAvatar(
                                  radius: 22,
                                  backgroundImage:
                                      CachedNetworkImageProvider(_profpic),
                                  //  backgroundColor: Colors.black,
                                )
                              : CircleAvatar(
                                  radius: 22,
                                  backgroundImage: CachedNetworkImageProvider(
                                      "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                                  //  backgroundColor: Colors.black,
                                ),
                          Positioned(
                            bottom: -1.0,
                            right: -1.0,
                            child: new Icon(
                              Icons.brightness_1,
                              size: 17.0,
                              color: Colors.green,
                            ),
                          )
                        ])
                      : _profpic != null
                          ? CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  CachedNetworkImageProvider(_profpic),
                              //  backgroundColor: Colors.black,
                            )
                          : CircleAvatar(
                              radius: 22,
                              backgroundImage: CachedNetworkImageProvider(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                              //  backgroundColor: Colors.black,
                            ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        _recipientname,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        _recipientjobtitle,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ))
                ],
              ),
              actions: [
                IconButton(
                    icon: Icon(
                      LineIcons.phone,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      MyDatabaseMethods().callNumber(_recipientContactNumber);
                    }),
                IconButton(
                    icon: Icon(
                      LineIcons.video_camera,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      sendAndRetrieveMessage(
                          serverToken, "Video Call", _recipientmobileToken);
                      onJoin();
                      Map<String, dynamic> callAlertMap = {
                        "usersStatus": false,
                        "CallersName": _currentUserName,
                        'Chatroom': widget.chatRoomId,
                        "CallersProfilePic": _currentUserProfile,
                      };
                      MyDatabaseMethods().sendcalltoUser(
                          _reciepientEmail, callAlertMap, _currentUserName);
                    }),
              ],
            ),
            body: Container(
              child: Stack(
                children: [
                  chatMessages(),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      //  color: Color(0xFFFFF5EE),
                      color: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Row(
                        children: <Widget>[
                          isTyping
                              ? Container(
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Color(0xFFA41D21),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isTyping = false;
                                        });
                                      }),
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.image,
                                    color: Color(0xFFA41D21),
                                  ),
                                  onPressed: () {
                                    getImage(_recipientname, _currentUserName);
                                  }),
                          isTyping
                              ? Container(
                                  height: 0,
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.video_library,
                                    color: Color(0xFFA41D21),
                                  ),
                                  onPressed: () {
                                    getVideo(_recipientname, _currentUserName);
                                  }),
                          isTyping
                              ? Container(
                                  height: 0,
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.timeline,
                                    color: Color(0xFFA41D21),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return Scaffold(
                                          appBar: AppBar(
                                              iconTheme: IconThemeData(
                                                  color: Colors.blue),
                                              backgroundColor: Colors.white,
                                              centerTitle: true,
                                              title: Text(
                                                'Templates',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                          body: ChatTemplateMenuTile(
                                            currentUserCompany:
                                                _currentUserCompany,
                                            currentUserEmail: _currentUserEmail,
                                            currentUserJobTitle:
                                                _currentUserJobTitle,
                                            currentUserNumber:
                                                _contactNumberTemplate,
                                            currentUsername: _currentUserEmail,
                                            reciepientCompany:
                                                _recipientCompany,
                                            reciepientContactnumber:
                                                _recipientContactNumber,
                                            reciepientEmail:
                                                widget.recipientEmail,
                                            reciepientJobTitle:
                                                _recipientjobtitle,
                                            recipientname: _recipientname,
                                            templateController:
                                                _templateController,
                                            templatesList: templatesList,
                                            textController:
                                                messageEditingController,
                                          ));
                                    }));
                                  }),
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(15.0),
                                      topRight: const Radius.circular(15.0),
                                      bottomLeft: const Radius.circular(15.0),
                                      bottomRight: const Radius.circular(15.0),
                                    ),
                                  ),
                                  child: TextField(
                                    maxLines: 2,
                                    keyboardType: TextInputType.multiline,
                                    onChanged: (value) {
                                      //   _chatcontroller.jumpTo(
                                      //          _chatcontroller.position.maxScrollExtent);
                                    },
                                    onTap: () {
                                      //   _chatcontroller.jumpTo(
                                      //     _chatcontroller.position.minScrollExtent);
                                      Timer(
                                          Duration(milliseconds: 300),
                                          () => _chatcontroller.jumpTo(
                                              _chatcontroller
                                                  .position.minScrollExtent));
                                      setState(() {
                                        isTyping = true;
                                      });
                                    },
                                    controller: messageEditingController,
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      border: new OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                      filled: true,
                                      hintText: "Type in your text",
                                      fillColor: Colors.white70,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[800]),
                                    ),
                                  ))),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              addMessage();
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Color(0xFFA41D21),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final String recipientUserProfile;
  final bool sendByMe;
  final bool isImage;
  final bool isOnline;
  final bool isVideo;
  final bool showSeen;
  MessageTile({
    @required this.message,
    @required this.sendByMe,
    this.isImage,
    this.recipientUserProfile,
    this.isOnline,
    this.isVideo,
    this.showSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
            margin: EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: sendByMe ? 24 : 0,
                right: sendByMe ? 0 : 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                sendByMe
                    ? Container(
                        height: 40,
                        width: 40,
                      )
                    : isOnline
                        ? Container(
                            margin: EdgeInsets.all(10),
                            child: Stack(children: [
                              CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    recipientUserProfile),
                              ),
                              Positioned(
                                bottom: -1.0,
                                right: -1.0,
                                child: new Icon(
                                  Icons.brightness_1,
                                  size: 17.0,
                                  color: Colors.green,
                                ),
                              )
                            ]))
                        : Container(
                            margin: EdgeInsets.all(10),
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  recipientUserProfile),
                            ),
                          ),
                Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                        alignment: sendByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: sendByMe
                            ? isImage
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return Scaffold(
                                          backgroundColor: Colors.black,
                                          body: Center(
                                              child: PhotoView(
                                            imageProvider:
                                                CachedNetworkImageProvider(
                                                    message),
                                          )),
                                        );
                                      }));
                                    },
                                    child: Container(
                                        width: 150,
                                        height: 250,
                                        child: new ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: message,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ))))
                                : isVideo
                                    ? Container(
                                        child: ChewieVideoInit(
                                            videoPlayerController:
                                                VideoPlayerController.network(
                                                    message)),
                                      )
                                    : Container(
                                        padding: EdgeInsets.only(
                                            top: 17,
                                            bottom: 17,
                                            left: 20,
                                            right: 20),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(23),
                                                topRight: Radius.circular(23),
                                                bottomLeft:
                                                    Radius.circular(23)),
                                            color: const Color(0xFFed4755)),
                                        child: Text(message,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'Arial',
                                                fontWeight: FontWeight.w400)))
                            : isImage
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return Scaffold(
                                          // backgroundColor: Colors.black,
                                          body: Center(
                                              child: PhotoView(
                                            imageProvider:
                                                CachedNetworkImageProvider(
                                                    message),
                                          )),
                                        );
                                      }));
                                    },
                                    child: Container(
                                        width: 150,
                                        height: 250,
                                        child: new ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: message,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ))))
                                : isVideo
                                    ? Container(
                                        child: ChewieVideoInit(
                                            videoPlayerController:
                                                VideoPlayerController.network(
                                                    message)),
                                      )
                                    : Container(
                                        padding: EdgeInsets.only(
                                            top: 17,
                                            bottom: 17,
                                            left: 20,
                                            right: 20),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(23),
                                                topRight: Radius.circular(23),
                                                bottomRight:
                                                    Radius.circular(23)),
                                            color: const Color(0xFFDFEFF2)),
                                        child: Text(message,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w400))))),
                sendByMe
                    ? Container(
                        width: 20,
                      )
                    : Container(),
              ],
            )),
        /*    sendByMe
            ? showSeen
                ? Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Text("Seen"))
                : Container()
            : Container()*/
      ],
    );
  }
}

class ChatTemplateMenuTile extends StatelessWidget {
  // final String currentUserEmail;
  final ScrollController templateController;
  final Stream templatesList;
  final String title;
  final TextEditingController textController;
  final String recipientname;
  final String currentUsername;
  final String currentUserNumber;
  final String currentUserEmail;
  final String currentUserJobTitle;
  final String currentUserCompany;
  final String reciepientEmail;
  final String reciepientContactnumber;
  final String reciepientJobTitle;
  final String reciepientCompany;

  ChatTemplateMenuTile({
    this.title,
    this.textController,
    this.templatesList,
    this.templateController,
    this.recipientname,
    this.currentUsername,
    this.currentUserNumber,
    this.currentUserEmail,
    this.currentUserJobTitle,
    this.currentUserCompany,
    this.reciepientEmail,
    this.reciepientContactnumber,
    this.reciepientJobTitle,
    this.reciepientCompany,
  });
  Widget templateMessageList() {
    return Container(
        child: StreamBuilder(
      stream: templatesList,
      builder: (context, snapper) {
        return snapper.hasData
            ? ListView.builder(
                controller: templateController,
                itemCount: snapper.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatTemplateTile(
                    template: snapper.data.documents[index].data['template'],
                    textController: textController,
                    recipientname: recipientname,
                    currentUsername: currentUsername,
                    currentUserEmail: currentUserEmail,
                    currentUserNumber: reciepientContactnumber,
                    reciepientCompany: reciepientCompany,
                    reciepientJobTitle: reciepientJobTitle,
                    currentUserCompany: currentUserCompany,
                    currentUserJobTitle: currentUserJobTitle,
                  );
                })
            : Container(
                child: Center(
                  child: Text("No Recent Contacts"),
                ),
              );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Row(
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () {
                //   Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                      appBar: AppBar(
                          iconTheme: IconThemeData(color: Colors.blue),
                          backgroundColor: Colors.white,
                          centerTitle: true,
                          title: Text(
                            'Typical Opening Conversation',
                            style: TextStyle(color: Colors.black),
                          )),
                      body: templateMessageList());
                }));
              },
              child: Container(
                height: 150,
                width: 170,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFA41D21),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15.0),
                    topRight: const Radius.circular(15.0),
                    bottomLeft: const Radius.circular(15.0),
                    bottomRight: const Radius.circular(15.0),
                  ),
                ),
                child: Center(
                    child: Text(
                  "Typical Opening Conversation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                )),
              ),
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                      appBar: AppBar(
                          iconTheme: IconThemeData(color: Colors.blue),
                          backgroundColor: Colors.white,
                          centerTitle: true,
                          title: Text(
                            'Sales Oriented Conversation',
                            style: TextStyle(color: Colors.black),
                          )),
                      body: Center(
                        child: Text("Making more templates for you"),
                      ));
                }));
              },
              child: Container(
                height: 150,
                width: 170,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFA41D21),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15.0),
                    topRight: const Radius.circular(15.0),
                    bottomLeft: const Radius.circular(15.0),
                    bottomRight: const Radius.circular(15.0),
                  ),
                ),
                child: Center(
                    child: Text(
                  "Sales Oriented Conversation",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                )),
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () {
                //   Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                      appBar: AppBar(
                          iconTheme: IconThemeData(color: Colors.blue),
                          backgroundColor: Colors.white,
                          centerTitle: true,
                          title: Text(
                            'Guide Templates',
                            style: TextStyle(color: Colors.black),
                          )),
                      body: templateMessageList());
                }));
              },
              child: Container(
                height: 150,
                width: 170,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFA41D21),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15.0),
                    topRight: const Radius.circular(15.0),
                    bottomLeft: const Radius.circular(15.0),
                    bottomRight: const Radius.circular(15.0),
                  ),
                ),
                child: Center(
                    child: Text(
                  "Guide Templates",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                )),
              ),
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                      appBar: AppBar(
                          iconTheme: IconThemeData(color: Colors.blue),
                          backgroundColor: Colors.white,
                          centerTitle: true,
                          title: Text(
                            'Money Related Conversation',
                            style: TextStyle(color: Colors.black),
                          )),
                      body: templateMessageList());
                }));
              },
              child: Container(
                height: 150,
                width: 170,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFA41D21),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15.0),
                    topRight: const Radius.circular(15.0),
                    bottomLeft: const Radius.circular(15.0),
                    bottomRight: const Radius.circular(15.0),
                  ),
                ),
                child: Center(
                    child: Text(
                  "Money Related Conversation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                )),
              ),
            ),
          ),
        ],
      )
    ]));
  }
}

class ChatTemplateTile extends StatelessWidget {
  // final String currentUserEmail;
//  final String jobtitle;
  final String recipientname;
  final String currentUsername;
  final String currentUserNumber;
  final String currentUserEmail;
  final String currentUserJobTitle;
  final String currentUserCompany;
  final String reciepientEmail;
  final String reciepientContactnumber;
  final String reciepientJobTitle;
  final String reciepientCompany;
  final String template;
  final TextEditingController textController;
  ChatTemplateTile({
//this.currentUserEmail,
    //  this.contactNumber,
    // this.jobTitle,
    // this.jobtitle,
    // this.name,
    this.template,
    this.textController,
    this.recipientname,
    this.currentUsername,
    this.currentUserNumber,
    this.currentUserEmail,
    this.reciepientEmail,
    this.reciepientContactnumber,
    this.reciepientJobTitle,
    this.reciepientCompany,
    this.currentUserJobTitle,
    this.currentUserCompany,
  });
  String _textSelect(String str) {
    try {
      if (str.contains("[hisName]")) {
        str = str.replaceFirst("[hisName]", recipientname);
      }
      if (str.contains('[yourName]')) {
        str = str.replaceFirst('[yourName]', currentUsername);
      }
      if (str.contains('[yourEmail]')) {
        str = str.replaceFirst('[yourEmail]', currentUserEmail);
      }
      if (str.contains('[yourContactNumber]')) {
        str = str.replaceFirst('[yourContactNumber]', currentUserNumber);
      }
      if (str.contains('[hisReciepientEmail]')) {
        str = str.replaceFirst('[hisReciepientEmail]', reciepientEmail);
      }
      if (str.contains('[hisReciepientContactNumber]')) {
        str = str.replaceFirst(
            '[hisReciepientContactNumber]', reciepientContactnumber);
      }
      if (str.contains('[hisCompany]')) {
        str = str.replaceFirst('[hisCompany]', reciepientCompany);
      }
      if (str.contains('[hisJobTitle]')) {
        str = str.replaceFirst('[hisJobTitle]', reciepientJobTitle);
      }
      if (str.contains('[yourJobTitle]')) {
        str = str.replaceFirst('[yourJobTitle]', currentUserJobTitle);
      }
      if (str.contains('[yourCompany]')) {
        str = str.replaceFirst('[yourCompany]', currentUserCompany);
      }
    } catch (e) {}
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Flexible(
            child: Container(
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFA0ECFA),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15.0),
                    topRight: const Radius.circular(15.0),
                    bottomLeft: const Radius.circular(15.0),
                    bottomRight: const Radius.circular(15.0),
                  ),
                ),
                child: Container(
                    margin: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Text(
                          _textSelect(template),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        )),
                        SizedBox(
                          width: 15,
                        ),
                        IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              Navigator.pop(context);
                              textController.text = _textSelect(template);
                            }),
                        IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              MyDatabaseMethods()
                                  .share(context, _textSelect(template));
                            })
                      ],
                    ))),
          ),
        ],
      )
    ]);
  }
}
