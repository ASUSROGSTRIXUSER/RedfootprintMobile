import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:deivao_drawer/deivao_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:native_updater/native_updater.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redfootprintios/Settings/Settings_page.dart';
import 'package:redfootprintios/pages/ChatAndVideo/ChatVideoroomscreen.dart';
import 'package:redfootprintios/pages/ChatAndVideo/call.dart';

import 'package:redfootprintios/pages/Events/HolderExclusiveSmall.dart';

import 'package:redfootprintios/pages/Events/SmallEventPage.dart';
import 'package:redfootprintios/pages/Forum/ForumsPage.dart';
import 'package:redfootprintios/pages/NewsAndTestimonials/ModifiedNTHolder.dart';
import 'package:redfootprintios/pages/NewsAndTestimonials/NewsPageTestimonialHolder.dart';
import 'package:redfootprintios/pages/ProfilePages/UserProfilePage.dart';
import 'package:redfootprintios/pages/NewsAndTestimonials/PublicNewsPage.dart';
import 'package:redfootprintios/pages/ProspectContacts/ContactRoom.dart';
import 'package:redfootprintios/pages/login_signup_page.dart';
import 'package:redfootprintios/services/CallsAndMessagesServices.dart';
import 'package:redfootprintios/services/animations/TransparentAnimation.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';
import 'package:update_available/update_available.dart';
import 'package:video_player/video_player.dart';

import '../../main.dart';

class NewHomePage extends StatefulWidget {
  NewHomePage({
    this.logoutCallback,
  });

  final VoidCallback logoutCallback;
  @override
  _NewHomePageState createState() => new _NewHomePageState();
}

Future<dynamic> myBackgroundHandler(Map<String, dynamic> message) async {
  return await _NewHomePageState()._showNotification(message);
}

class _NewHomePageState extends State<NewHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<String> _accountType = <String>[
    'Business owner',
    'Former MLM',
    'Supervisor',
    'Manager',
    'Employee',
  ];
  List<String> _status = <String>[
    'Single',
    'Married',
    'Divorced',
    'Engaged',
    'Separated',
  ];

  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();
  TextEditingController addressController = new TextEditingController();
  TextEditingController educationController = new TextEditingController();
  TextEditingController workController = new TextEditingController();
  TextEditingController jobTitleController = new TextEditingController();
  TextEditingController motivationController = new TextEditingController();
  TextEditingController statusController = new TextEditingController();
  TextEditingController recreationController = new TextEditingController();
  TextEditingController mobileNumberController = new TextEditingController();
  TextEditingController birthdateController = new TextEditingController();
  var selectedCivilStatus, selectedTypeJobTitle;
  PageController _pageController;
  Stream<QuerySnapshot> notifications;
  Stream<QuerySnapshot> call;
  String _currentUserName = "";
  String _currentUserProfilePic =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg";
  String callersName;
  String videoRoomID;
  String callersProfile;
  ScrollController notiScroll = new ScrollController();
  int _page = 0;
  ClientRole _role = ClientRole.Broadcaster;
  String currentUser;
  final drawerController = DeivaoDrawerController();
  var isThereUnseenChat = true;
  var isThereNewNoti = true;
  var someoneisCalling = false;
  var numberofUnseenChats = 0;
  var numberofUnseenNoti = 0;
  bool _disposed = false;
  bool isProfileIncomplete = false;
  String initAddress;
  String initEducation;
  String initWork;
  String initJobTitle;
  String initRecreation;
  String initMotivation;
  String initStatus;
  int numberofincompleteDetails;
  bool isThereIncompleteData = false;
  bool isnoprofilepic = false;
  bool isUploading = false;
  String _gender;
  //String _birthdate;
  //String _mobileNumber;
  DateTime selectedbirthdate = DateTime.now();
  List<Asset> images = List<Asset>();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  String initViewEventURL = "";
  String initViewEventLink = "";
  FirebaseMessaging fcm;
  VideoPlayerController _controllerBackgroundVideo;
  Future onSelectNotification(String payload) async {}

  showeventInitState() async {
    await Future.delayed(Duration(seconds: 3));
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
            contentPadding: EdgeInsets.all(0),
            // title: Text("PayLoad"),
            content: Stack(
              children: [
                Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/redfootprints-daf23.appspot.com/o/NewsPhotos%2F1603878152357?alt=media&token=3fe9e226-b67b-40cc-92ff-e2b1cf130451"),
                Positioned(
                    bottom: 10,
                    left: 50,
                    right: 50,
                    child: RaisedButton(
                        color: Color(0xFFA41D21),
                        child: Text(
                          "Join Now",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {}))
              ],
            ));
      },
    );
  }

  Future _showNotification(Map<String, dynamic> message) async {
    var androidDetails = new AndroidNotificationDetails(
        "09234808983", "RedFootprint", "RedFootprintNotification",
        importance: Importance.Max, priority: Priority.High);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(androidDetails, iosDetails);
    await _flutterLocalNotificationsPlugin.show(
        0,
        '${message['notification']['title']}',
        '${message['notification']['body']}',
        generalNotificationDetails);
  }

  @override
  void initState() {
    //showeventInitState();


        // ignore: missing_return
        SystemChannels.lifecycle.setMessageHandler((msg) {
          debugPrint('SystemChannels> $msg');

          if (msg == AppLifecycleState.resumed.toString())
            setState(() {
              WidgetsBinding.instance.addPostFrameCallback((_) async {

                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) {
                    return new AlertDialog(
                        contentPadding: EdgeInsets.all(0),
                        // title: Text("PayLoad"),
                        content: Stack(
                          children: [
                            Image.network(initViewEventURL),
                            Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )),
                            Positioned(
                                bottom: 10,
                                left: 50,
                                right: 50,
                                child: RaisedButton(
                                    color: Color(0xFFA41D21),
                                    child: Text(
                                      "Join Now",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      return CallsAndMessagesService()
                                          .launchWeb(initViewEventLink);

                                      //Navigator.pop(context);
                                    }))
                          ],
                        ));
                  },
                );
              });
            });
        });

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Firestore.instance
        .collection("Events")
        .document("eventalert")
        .get()
        .then((value) async {
      setState(() {
        initViewEventLink = value.data['EventLink'].toString();
        initViewEventURL = value.data['EventURL'].toString();

        print(initViewEventURL);
          });
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              return new AlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  // title: Text("PayLoad"),
                  content: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: initViewEventURL,
                        placeholder: (context, url) =>
                            new CircularProgressIndicator(),
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                      Positioned(
                          bottom: 10,
                          left: 50,
                          right: 50,
                          child: RaisedButton(
                              color: Color(0xFFA41D21),
                              child: Text(
                                "Join Now",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                return CallsAndMessagesService()
                                    .launchWeb(initViewEventLink);

//WebPageView(url: initViewEventURL);
                              }))
                    ],
                  ));
            },
          );
        });
      });

//print(initViewEventLink +"  eventLink");
//print(initViewEventURL  +" eventUrl");

    var androidInitialize =
        new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSinitialize = new IOSInitializationSettings();
    var initializationSettings =
        new InitializationSettings(androidInitialize, iOSinitialize);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _firebaseMessaging.configure(
        onLaunch: (Map<String, dynamic> message) async {
          //  print(message['notification']['body']);
          //  await Future.delayed(const Duration(seconds: 5),);
          //Navigator.push(context, NewHomePage());
          await onSelectNotification("onLaunch");
          //  print("onMessage");
          // print("Else");
        },
        onMessage: (Map<String, dynamic> message) async {
          //  print(message['notification']['body']);
          //  await onSelectNotification(message['notification']['body']);
          await _showNotification(message);
          //  print("onMessage");
          // print("Else");
        },
        onResume: (Map<String, dynamic> message) async {
          await onSelectNotification("onResume");
          //   print("Resume");
        },
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundHandler);

    _firebaseMessaging.getToken().then((tokenValue) {
      MyDatabaseMethods().updateMobileToken(tokenValue);
    });

    //checkVersion();
    _pageController = new PageController();

    Auth().getCurrentUser().then((currentUserValue) async {
      setState(() {
        currentUser = currentUserValue?.email;
        _currentUserName = currentUserValue?.displayName;

        _currentUserProfilePic = currentUserValue?.photoUrl;

        MyDatabaseMethods().getuserInfo(currentUser).then((val) {
          setState(() {
            initAddress = val.data['Address'].toString();
            initEducation = val.data['Education'].toString();
            initWork = val.data['Work'].toString();
            initJobTitle = val.data['JobTitle'].toString();
            //   _currentUserProfilePic = val.data['ProfilePic'].toString();
            initRecreation = val.data['Recreation'].toString();
            initMotivation = val.data['Motivation'].toString();
            initStatus = val.data['Status'].toString();
            _gender = val.data["Gender"].toString();

            addressController.text = val.data['Address'].toString();
            educationController.text = val.data['Education'].toString();
            workController.text = val.data['Work'].toString();
            jobTitleController.text = val.data['JobTitle'].toString();
            motivationController.text = val.data['Motivation'].toString();
            statusController.text = val.data['Status'].toString();
            recreationController.text = val.data['Recreation'].toString();
            mobileNumberController.text = val.data['ContactNumber'].toString();
            birthdateController.text = val.data['Birthday'].toString();

            if (_currentUserProfilePic == null ||
                _currentUserProfilePic == "") {
              setState(() {
                isnoprofilepic = true;
              });
            }

            if (initAddress == "[Set up  address]" || initAddress == "") {
              print(initAddress);
              setState(() {
                isThereIncompleteData = true;
              });
            }
            if (initEducation == "[Set up  Education Degree]" ||
                initEducation == "") {
              setState(() {
                isThereIncompleteData = true;
              });
            }
            if (initWork == "[Set up  work company]" || initWork == "") {
              setState(() {
                isThereIncompleteData = true;
              });
            }
            if (initJobTitle == "[Set up  JobTitle]" || initJobTitle == "") {
              setState(() {
                isThereIncompleteData = true;
              });
            }
            if (initRecreation == "[Set up  Recreation]" ||
                initRecreation == "") {
              setState(() {
                isThereIncompleteData = true;
              });
            }
            if (initMotivation == "[Set up  Motivation]" ||
                initMotivation == "") {
              setState(() {
                isThereIncompleteData = true;
              });
            }
            if (initStatus == "[Set up  Status]" || initStatus == "") {
              setState(() {
                isThereIncompleteData = true;
              });
            }
          });
        });

        MyDatabaseMethods().getNotification(currentUser).then((snapinit) {
          setState(() {
            notifications = snapinit;
          });
        });
      });

      /* MyDatabaseMethods().countUnseenChats(currentUser).then((numberOfUnseen) {
        setState(() {
          //isThereUnseenChat = isUnseenChats;
          //print(numberOfUnseen);
          numberofUnseenChats = numberOfUnseen;

          //   print(numberofUnseenChats);
          //   _showNotification();
          //     print(numberofUnseenChats + "" + currentUser);
        });
      });*/
      //launchUrl();
      MyDatabaseMethods().setStatusOnline(currentUser);
    });
    _controllerBackgroundVideo =
        VideoPlayerController.asset('assets/NTVideo3.mp4')
          ..initialize().then((_) {
            // Once the video has been loaded we play the video and set looping to true.
            _controllerBackgroundVideo.play();
            _controllerBackgroundVideo.setLooping(true);

            _controllerBackgroundVideo.setVolume(0.0);
            //  _controller.setLooping(true);
            // Ensure the first frame is shown after the video is initialized.
          });
    //  setcallState();
    _timer();
    printAvailability();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // _pageController.dispose();
    _controllerBackgroundVideo.dispose();
    _disposed = true;
    // print(_disposed);
  }

  void printAvailability() async {
    final updateAvailability = await getUpdateAvailability();

    updateAvailability.fold(
      available: () => NativeUpdater.displayUpdateAlert(
        context,
        forceUpdate: false,
        appStoreUrl:
            'https://apps.apple.com/us/app/red-footprint-official/id1539867618',
        playStoreUrl:
            'https://play.google.com/store/apps/details?id=com.redfootprint.BackendPhaseRedfootprints',
        iOSDescription: 'A new version available',
        iOSUpdateButtonLabel: 'Update',
        iOSIgnoreButtonLabel: 'Later',
      ),
      notAvailable: () => null,
      unknown: () => "It was not possible to determine if there is or not "
          "an update for your app.",
    );
  }

  Future<void> checkVersion() async {
    int statusCode = 412;
    int localVersion = 20;
    int serverLatestVersion = 10;

    Future.delayed(Duration.zero, () {
      if (statusCode == 412) {
        NativeUpdater.displayUpdateAlert(
          context,
          forceUpdate: false,
          appStoreUrl:
              'https://apps.apple.com/us/app/red-footprint-official/id1539867618',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.redfootprint.BackendPhaseRedfootprints',
          iOSDescription: 'A new version available',
          iOSUpdateButtonLabel: 'Upgrade',
          iOSCloseButtonLabel: 'Exit',
        );
      } else if (serverLatestVersion > localVersion) {
        //  showAlertAppisUpdated(context);
        NativeUpdater.displayUpdateAlert(
          context,
          forceUpdate: false,
          appStoreUrl:
              'https://apps.apple.com/us/app/red-footprint-official/id1539867618',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.redfootprint.BackendPhaseRedfootprints',
          iOSDescription: 'A new version available',
          iOSUpdateButtonLabel: 'Upgrade',
          iOSIgnoreButtonLabel: 'Next Time',
        );
      }
    });
  }

  _timer() async {
    Timer(Duration(seconds: 1), () async {
      if (!_disposed) {
        // MyDatabaseMethods().unSeen(prospectEmail, currentUser);
        await MyDatabaseMethods()
            .countUnseenNotification(currentUser)
            .then((isUnseenNotification) {
          setState(() {
            //    print(isUnseenNotification);
            numberofUnseenNoti = isUnseenNotification;
          });
        });
        await MyDatabaseMethods()
            .countUnseenChats(currentUser)
            .then((numberOfUnseen) {
          setState(() {
            //    print(numberOfUnseen);
            numberofUnseenChats = numberOfUnseen;
          });
        });
        await MyDatabaseMethods().getCallStatus(currentUser).then((callstatus) {
          setState(() {
            someoneisCalling = callstatus.data["usersStatus"];
            callersName = callstatus.data["CallersName"];
            videoRoomID = callstatus.data["Chatroom"];
            callersProfile = callstatus.data['CallersProfilePic'];
            if (someoneisCalling) {
              FlutterRingtonePlayer.play(
                android: AndroidSounds.alarm,
                ios: IosSounds.glass,
                looping: true,
                volume: 1.0,
              );
            } else {
              FlutterRingtonePlayer.stop();
            }
          });
        });
        await _timer();
      }
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedbirthdate,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedbirthdate)
      setState(() {
        selectedbirthdate = picked;
        birthdateController.text =
            selectedbirthdate.toLocal().toString().split(' ')[0];
      });
  }

  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child("ProfilesPictures/$fileName");
    StorageUploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    if (uploadTask.isInProgress == true) {
      setState(() {
        isUploading = true;
      });
    }
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    _currentUserProfilePic = await storageTaskSnapshot.ref.getDownloadURL();
    if (uploadTask.isSuccessful == true) {
      setState(() {
        Auth().getCurrentUser().then((value) {
          MyDatabaseMethods().uploadProfilePic(
              '$_currentUserProfilePic', value?.email.toString());
          // Auth update
          UserUpdateInfo info = new UserUpdateInfo();
          info.photoUrl = '$_currentUserProfilePic';
          value.updateProfile(info);
          // print('$_downUrl' + 'Upload pic process');
        });
        isUploading = false;
      });
    }
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  Widget notificationTile(
    String notificationMessage,
    String senderEmail,
    String senderName,
    String chatroomid,
    String photoURL,
    bool notificationStatus,
    String contactNumber,
    String timeSent,
    String currentuserProfilePic,
    String currentUserEmail,
    String currentUsername,
    String jobTitle,
  ) {
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.all(5),
      child: new ListTile(
          leading: photoURL != null
              ? CircleAvatar(
                  radius: 28,
                  backgroundImage: CachedNetworkImageProvider(photoURL),
                )
              : CircleAvatar(
                  radius: 28,
                  backgroundImage: CachedNetworkImageProvider(
                      "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                ),
          title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    child: Text('$notificationMessage',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                new Text(
                  timeSent,
                  style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                ),
              ]),
          subtitle: notificationStatus
              ? Row(children: [
                  new InkWell(
                    onTap: () {
                      Map<String, dynamic> notificationInfoMap = {
                        "Email": currentUser,
                        "Name": currentUsername,
                        "ChatRoomID": chatroomid,
                        "NotificationType": "ConfirmProspect",
                        "NotificationStatus": false,
                        "NotificationMessage": "$currentUsername accepted you ",
                        "timeNotificationSent":
                            DateFormat.jm().format(DateTime.now()).toString(),
                        "ProfilePicture": currentuserProfilePic,
                      };

                      Map<String, dynamic> prospectInfoMap = {
                        "Email": senderEmail,
                        "Contact Number": contactNumber,
                        "Name": senderName,
                        "ProfilePic": photoURL,
                        "isOnChat": 'true',
                        "ChatRoomID": chatroomid,
                        "LatestMessage": "You accepted $senderName",
                        "timeLastSent": "",
                        "isSeen": false,
                        "isHighQualityClient": false,
                        "jobTitle": jobTitle,
                        "Schedule": "",
                        "timeLastSentTimeStamp": FieldValue.serverTimestamp()
                      };
                      MyDatabaseMethods().addasProspect(
                          currentUserEmail, prospectInfoMap, senderEmail);

                      MyDatabaseMethods().updateCurrentUserNotficationAccept(
                          currentUserEmail, senderEmail, senderName);
                      MyDatabaseMethods().sendNotification(
                          senderEmail, notificationInfoMap, currentUserEmail);
                    },
                    child: new Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: new BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirm',
                            style:
                                TextStyle(fontSize: 10.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  new InkWell(
                    onTap: () {
                      MyDatabaseMethods().updateCurrentUserNotficationIgnore(
                          currentUserEmail, senderEmail, senderName);
                    },
                    child: new Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: new BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Text(
                            'Ignore',
                            style: new TextStyle(
                                fontSize: 10.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                ])
              : Container()),
    );
  }

  save() async {
    try {
      MyDatabaseMethods().updateAccountDetails(
        currentUser,
        addressController.text,
        educationController.text,
        jobTitleController.text,
        workController.text,
        recreationController.text,
        motivationController.text,
        statusController.text,
        _gender,
        birthdateController.text,
        mobileNumberController.text,
      );
      setState(() {
        isThereIncompleteData = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget buildGridView() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: images.length,
      shrinkWrap: true,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        // print(images[index].);

        return AssetThumb(
          quality: 80,
          asset: asset,
          width: 100,
          height: 100,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      await PermissionHandler().requestPermissions([PermissionGroup.camera]);
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        // enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#A41D21",
          actionBarTitle: "Gallery",
          allViewTitle: "All Photos",
          useDetailsView: true,
          // selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
    postImage(images[0]);
    setState(() {
      images.clear();
    });
  }

  Widget notificationPageTileList() {
    try {
      return StreamBuilder(
        stream: notifications,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.active) {
            return ListView.builder(
                itemCount: snap.data.documents.length,
                shrinkWrap: true,
                controller: notiScroll,
                itemBuilder: (context, index) {
                  return notificationTile(
                    snap.data.documents[index].data['NotificationMessage']
                        .toString(),
                    snap.data.documents[index].data['Email'].toString(),
                    snap.data.documents[index].data['Name'].toString(),
                    snap.data.documents[index].data['ChatRoomID'].toString(),
                    snap.data.documents[index].data['ProfilePicture'],
                    snap.data.documents[index].data['NotificationStatus'],
                    snap.data.documents[index].data['ContactNumber'],
                    snap.data.documents[index].data['timeNotificationSent'],
                    _currentUserProfilePic,
                    currentUser,
                    _currentUserName,
                    snap.data.documents[index].data['jobTitle'],
                  );
                });
          } else if (snap.connectionState == ConnectionState.waiting) {
            return Container(child: Center(child: CircularProgressIndicator()));
          } else {
            return Container(
              child: Text("No Recent Notification"),
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

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void navigationTapped(int page) {
    if (page == 5) {
      setState(() {
        //     isThereNewNoti = false;
      });
    } else if (page == 4) {
      //    isThereUnseenChat = false;
    }
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 5), curve: Curves.linear);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  signOut() async {
    try {
      await Auth().signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  showAlertDialogLogout(BuildContext context) {
    // Create button
    Widget signout = FlatButton(
      child: Text("Signout"),
      onPressed: () {
        MyDatabaseMethods().mobileTokenEmpty(currentUser);
        MyDatabaseMethods().setStatusOffline(currentUser);
        signOut();
        setState(() {
          _disposed = true;
        });
        //   widget.logoutCallback();\

        Navigator.of(context).pop();
        /*   Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginSignupPage(
                      logoutCallback: widget.logoutCallback,
                    )));*/
      },
    );
    Widget cancelSignout = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Are you sure you want to Logout?"),
      actions: [signout, cancelSignout],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertAppisUpdated(BuildContext context) {
    // Create button

    Widget cancelSignout = FlatButton(
      child: Text("Close"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Up to date"),
      actions: [cancelSignout],
    );

    // show the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: isThereIncompleteData
            ? Scaffold(
                appBar: AppBar(
                  title: Text("Account Setup"),
                  backgroundColor: Color(0xFFA41D21),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: () => showAlertDialogLogout(context))
                  ],
                ),
                body: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    CircleAvatar(
                      backgroundColor: Color(0xFFA41D21),
                      radius: 80,
                      child: Image.asset("assets/new_logo.png"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome to Redfootprint Mobile",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Complete your Account"),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Form(
                      key: _formKeyValue,
                      autovalidateMode: AutovalidateMode.always,
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20.0),
                        children: <Widget>[
                          Text(
                            'Civil Status',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          DropdownButton(
                            items: _status
                                .map((civilValues) => DropdownMenuItem(
                                      child: Center(
                                        child: Text(
                                          civilValues,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      value: civilValues,
                                    ))
                                .toList(),
                            onChanged: (selectedCivilStatus) {
                              //    print('$selectedAccountType');
                              setState(() {
                                selectedCivilStatus = selectedCivilStatus;
                                statusController.text = selectedCivilStatus;
                              });
                            },
                            value: selectedCivilStatus,
                            isExpanded: false,
                            hint: Text(
                              statusController.text.toString() == null
                                  ? ""
                                  : statusController.text.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            'Recreation',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextFormField(
                              controller: recreationController,
                              decoration: const InputDecoration(
                                hintText: 'Ex. Biking, Hiking,Driving',
                              ),
                              keyboardType: TextInputType.text),
                          SizedBox(height: 20.0),
                          Text(
                            'Motivation',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextFormField(
                              controller: motivationController,
                              decoration: const InputDecoration(
                                hintText: 'Ex. My Family',
                              ),
                              keyboardType: TextInputType.text),
                          SizedBox(height: 20.0),
                          Text(
                            'Address',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                hintText: 'Address',
                              ),
                              keyboardType: TextInputType.text),
                          SizedBox(height: 20.0),
                          Text(
                            'Education Degree',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextFormField(
                              controller: educationController,
                              decoration: const InputDecoration(
                                hintText: 'Degree : Bachelor of Science',
                              ),
                              keyboardType: TextInputType.text),
                          SizedBox(height: 20.0),
                          Text(
                            'Organization',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextFormField(
                            controller: workController,
                            decoration: const InputDecoration(
                              hintText: 'Company Name',
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            'Occupation',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(height: 15.0),
                          DropdownButton(
                            items: _accountType
                                .map((value) => DropdownMenuItem(
                                      child: Center(
                                        child: Text(
                                          value,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      value: value,
                                    ))
                                .toList(),
                            onChanged: (selectedAccountType) {
                              //    print('$selectedAccountType');
                              setState(() {
                                selectedTypeJobTitle = selectedAccountType;
                                jobTitleController.text = selectedTypeJobTitle;
                              });
                            },
                            value: selectedTypeJobTitle,
                            isExpanded: false,
                            hint: Text(
                              jobTitleController.text.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            "Gender",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              LabeledRadio(
                                label: 'Male',
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                value: 'Male',
                                groupValue: _gender,
                                onChanged: (newValue) {
                                  setState(() {
                                    _gender = newValue;
                                  });
                                },
                              ),
                              LabeledRadio(
                                label: 'Female',
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 20),
                                value: 'Female',
                                groupValue: _gender,
                                onChanged: (newValue) {
                                  setState(() {
                                    _gender = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            "Mobile Number",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextFormField(
                            controller: mobileNumberController,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            autofocus: false,
                            decoration: new InputDecoration(
                                hintText: 'Mobile Number',
                                icon: new Icon(
                                  Icons.format_list_numbered,
                                  color: Colors.black,
                                )),
                            validator: (value) =>
                                mobileNumberController.text.isEmpty
                                    ? 'Please enter your mobile number'
                                    : null,
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            "Birthday",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextFormField(
                            maxLines: 1,
                            autofocus: false,
                            controller: birthdateController,
                            showCursor: false,
                            readOnly: true,
                            onTap: () {
                              _selectDate(context);
                            },
                            decoration: new InputDecoration(
                                hintText: 'Birthdate ',
                                icon: new Icon(
                                  Icons.date_range,
                                  color: Colors.black,
                                )),
                            validator: (value) =>
                                selectedbirthdate.toString().isEmpty
                                    ? 'Please enter your Birthdate'
                                    : null,
                          ),
                        ],
                      ),
                    )
                  ],
                )),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => save(),
                  label: Row(
                    children: [
                      Text("Done", style: TextStyle(color: Colors.white)),
                      Icon(Icons.check)
                    ],
                  ),
                  backgroundColor: Color(0xFFA41D21),
                ),
              )
            : isnoprofilepic
                ? Scaffold(
                    extendBody: true,
                    appBar: AppBar(
                      title: Text("Account Setup"),
                      backgroundColor: Color(0xFFA41D21),
                      actions: [
                        IconButton(
                            icon: Icon(Icons.logout),
                            onPressed: () => showAlertDialogLogout(context))
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 150,
                                backgroundImage: _currentUserProfilePic !=
                                            null &&
                                        _currentUserProfilePic != ""
                                    ? CachedNetworkImageProvider(
                                        _currentUserProfilePic)
                                    : CachedNetworkImageProvider(
                                        "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                                backgroundColor: Color(0xFFA41D21),
                                child: isUploading
                                    ? CircularProgressIndicator()
                                    : Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("To be easily recognize and know you more"),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Text("Pick your best photo")],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RaisedButton(
                              color: Color(0xFFA41D21),
                              onPressed: loadAssets,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Text(
                                      "Choose",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: FloatingActionButton.extended(
                      backgroundColor: Color(0xFFA41D21),
                      label: Row(
                        children: [Text("Done"), Icon(Icons.check)],
                      ),
                      onPressed: () {
                        //   postImage(images[0]);
                        setState(() {
                          isnoprofilepic = false;
                        });
                      },
                    ),
                  )
                : someoneisCalling
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
                                backgroundImage:
                                    CachedNetworkImageProvider(callersProfile),
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
                                          .declinecalltoUser(currentUser);
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
                                        await PermissionHandler()
                                            .requestPermissions(
                                          [
                                            PermissionGroup.camera,
                                            PermissionGroup.microphone
                                          ],
                                        );

                                        MyDatabaseMethods()
                                            .declinecalltoUser(currentUser);
                                        // push video page with given channel name
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CallPage(
                                              channelName:
                                                  videoRoomID.toString(),
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
                    :
                    //backgroundColor: Color(0xFFA41D21),
                    DeivaoDrawer(
                        controller: drawerController,
                        drawer: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          // Important: Remove any padding from the ListView.
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            UserAccountsDrawerHeader(
                              decoration: BoxDecoration(
                                color: Color(0xFFA41D21),
                              ),
                              //    margin: EdgeInsets.all(20),
                              accountName: Text(_currentUserName == null
                                  ? ""
                                  : _currentUserName),
                              accountEmail: Text(
                                  initJobTitle == null ? "" : initJobTitle),
                              currentAccountPicture: CircleAvatar(
                                  backgroundColor: Theme.of(context).platform ==
                                          TargetPlatform.iOS
                                      ? Color(0xFFA41D21)
                                      : Color(0xFFA41D21),
                                  backgroundImage: CachedNetworkImageProvider(
                                      _currentUserProfilePic)),
                            ),
                            Container(
                              height: 50,
                            ),
                            ListTile(
                              //tileColor: Color(0xFFA41D21),
                              title: Container(
                                margin: EdgeInsets.all(30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text('Profile',
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                              onTap: () {
                                //  drawerController.close();
                                Navigator.of(context).push(TransparentRoute(
                                    builder: (BuildContext context) =>
                                        ProfileCustomization(
                                          tag: _currentUserName,
                                        )));
                              },
                            ),
                            ListTile(
                              //  tileColor: Color(0xFFA41D21),
                              title: Container(
                                margin: EdgeInsets.all(30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.settings_applications,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text('Settings'),
                                  ],
                                ),
                              ),

                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SettingsScreen(
                                              logoutCallback:
                                                  widget.logoutCallback,
                                              currentUserSettings: currentUser,
                                            )));
                              },
                            ),
                            ListTile(
                              //    tileColor: Color(0xFFA41D21),
                              title: Container(
                                margin: EdgeInsets.all(30),
                                //  color: Color(0xFFA41D21),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                // Update the state of the app.
                                // ...
                                showAlertDialogLogout(context);
                              },
                            ),
                            Container(
                              //    color: Colors.white,
                              height: 120,
                            ),
                            ListTile(
                                //  tileColor: Color(0xFFA41D21),
                                title: Container(
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.close,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Close',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap:
                                    // Update the state of the app.
                                    // ...
                                    drawerController.toggle),
                          ],
                        ),
                        child: Scaffold(
                            extendBodyBehindAppBar: true,
                            extendBody: true,
                            backgroundColor: Colors.transparent,
                            appBar: AppBar(
                              backgroundColor:
                                  Color(0xFFA41D21).withOpacity(0.9),
                              shape: ContinuousRectangleBorder(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(50.0),
                                  bottomRight: Radius.circular(50.0),
                                ),
                              ),
                              centerTitle: true,
                              title: Pulse(
                                delay: Duration(seconds: 2),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/redfootprint.png',
                                        fit: BoxFit.fitWidth,
                                        height: 105,
                                      ),
                                    ]),
                              ),
                              // backgroundColor: Color(0xFFFFF5EE),
                              leading: SlideInLeft(
                                child: Builder(builder: (context) {
                                  return Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: FlatButton(
                                        onPressed: drawerController.toggle,
                                        //   Scaffold.of(context).openDrawer();
                                        padding: EdgeInsets.all(0.0),
                                        child: CircleAvatar(
                                          radius: 55,
                                          backgroundColor: Color(0xFFA41D21),
                                          child: _currentUserProfilePic !=
                                                      null &&
                                                  _currentUserProfilePic != ""
                                              ? CircleAvatar(
                                                  radius: 28,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          _currentUserProfilePic),
                                                )
                                              : CircleAvatar(
                                                  //   radius: 50,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg"),
                                                ),
                                        )),
                                  );
                                }),
                              ),

                              actions: <Widget>[
                                SlideInRight(
                                  child: IconButton(
                                    icon: Stack(
                                      children: [
                                        Stack(children: <Widget>[
                                          Icon(
                                            Icons.notifications_active,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          isThereNewNoti
                                              ? Positioned(
                                                  top: 1.0,
                                                  right: -1.0,
                                                  child: new Stack(
                                                    children: <Widget>[
                                                      Container(
                                                          //    width: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .redAccent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: const Radius
                                                                      .circular(
                                                                  20.0),
                                                              topRight: const Radius
                                                                      .circular(
                                                                  20.0),
                                                              bottomLeft:
                                                                  const Radius
                                                                          .circular(
                                                                      20.0),
                                                              bottomRight:
                                                                  const Radius
                                                                          .circular(
                                                                      20.0),
                                                            ),
                                                          ),

                                                          //   color: Colors.black,
                                                          child: (numberofUnseenNoti ==
                                                                  0)
                                                              ? Container()
                                                              : Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  child: Text(
                                                                    "$numberofUnseenNoti",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )))

                                                      //  size: 12.0,
                                                      //  color: Colors.red,
                                                    ],
                                                  ))
                                              : Positioned(
                                                  top: -1.0,
                                                  right: -1.0,
                                                  child: new Stack(
                                                    children: <Widget>[
                                                      Container()
                                                    ],
                                                  ))
                                        ]),
                                      ],
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                /*       Navigator.of(context).push(TransparentRoute(
                                    builder: (BuildContext context) =>
                                        ExclusiveEventsSubPage()));*/
                                      Navigator.of(context).push(
                                         TransparentRoute( builder: (BuildContext context)  {
                                        return Scaffold(

                                          appBar: AppBar(
                                             shape: ContinuousRectangleBorder(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(50.0),
                                  bottomRight: Radius.circular(50.0),
                                ),
                              ),
                                            leading: Container(),
                                            iconTheme: IconThemeData(
                                                color: Colors.white),
                                                centerTitle: true,
                                            title: Text(
                                              "Notifications",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Color(0xFFA41D21).withOpacity(0.8),
                                          ),
                                          backgroundColor: Colors.black.withOpacity(0.8),
                                          body: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                child:
                                                    notificationPageTileList(),
                                              ),
                                            ],
                                          ),
                                          floatingActionButtonLocation:
                                              FloatingActionButtonLocation
                                                  .centerFloat,
                                          floatingActionButton:
                                              FloatingActionButton(
                                                  backgroundColor:
                                                      Color(0xFFA41D21),
                                                  child: Icon(
                                                      Icons.delete_forever),
                                                  onPressed: () {
                                                    MyDatabaseMethods()
                                                        .deleteNotification(
                                                            currentUser);
                                                  }),
                                        );
                                      }));
                                    },
                                  ),
                                )
                              ],
                            ),
                            body: Stack(
                              children: [
                                Scaffold(
                                  body: Image.asset(
                                    'assets/logo2.jpg',
                                    height: MediaQuery.of(context).size.height,
                                  ),
                                ),
                                new PageView(
                                  children: [
                                    new ModifiedNTHolder(),
                                    //   new NewsTestimonialHolder(),
                                    //  new PublicNewsPage(),
                                    /*     new WebPageView(
                  url:
                      "https://www.facebook.com/redfootprintbusinessconsultancy",
                ),*/
                                    //  new EventsPageHolder1(),
                                    new ExclusiveSmallEventsHolderPage(),
                                    // new ProspectContacts(),
                                    new ContactRoom(),
                                    new ChatVideoroom(),
                                    //     new NotificationPage(),
                                    new ForumPage(),
                                    //     new Calls('Contacts'),
                                  ],
                                  // pageSnapping: false,
                                  onPageChanged: onPageChanged,
                                  controller: _pageController,
                                  physics: BouncingScrollPhysics(),
                                ),
                              ],
                            ),
                            bottomNavigationBar: Theme(
                              data: Theme.of(context)
                                  .copyWith(canvasColor: Colors.transparent),
                              child: CurvedNavigationBar(
                                //  buttonBackgroundColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                color: Color(0xFFA41D21),
                                height: 60,
                                // height: 30,
                                //  type: BottomNavigationBarType.fixed,
                                //  fixedColor: Colors.red,
                                items: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.topic,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Topics",
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.assessment,
                                          color: Colors.white),
                                      Text(
                                        "Events",
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  /*   Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.wc, color: Colors.white),
                                  Text(
                                    "Prospect",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),*/
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.contacts, color: Colors.white),
                                      Text(
                                        "Prospects",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(children: <Widget>[
                                        Icon(
                                          Icons.chat,
                                          color: Colors.white,
                                        ),
                                        isThereUnseenChat
                                            ? Positioned(
                                                top: -1.0,
                                                right: -1.0,
                                                child: new Stack(
                                                  children: <Widget>[
                                                    Container(
                                                        //    width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft: const Radius
                                                                .circular(20.0),
                                                            topRight: const Radius
                                                                .circular(20.0),
                                                            bottomLeft:
                                                                const Radius
                                                                        .circular(
                                                                    20.0),
                                                            bottomRight:
                                                                const Radius
                                                                        .circular(
                                                                    20.0),
                                                          ),
                                                        ),

                                                        //   color: Colors.black,
                                                        child: (numberofUnseenChats ==
                                                                0)
                                                            ? Container()
                                                            : Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: Text(
                                                                  "$numberofUnseenChats",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )))

                                                    //  size: 12.0,
                                                    //  color: Colors.red,
                                                  ],
                                                ))
                                            : Positioned(
                                                top: -1.0,
                                                right: -1.0,
                                                child: new Stack(
                                                  children: <Widget>[
                                                    Container()
                                                  ],
                                                ))
                                      ]),
                                      Text(
                                        "Chat",
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.forum, color: Colors.white),
                                      Text(
                                        "Forum",
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.white),
                                      ),
                                    ],
                                  ),

                                  /*    new BottomNavigationBarItem(
              icon: new Stack(children: <Widget>[
                Icon(Icons.chat),
                isThereUnseenChat
                    ? Positioned(
                        top: -1.0,
                        right: -1.0,
                        child: new Stack(
                          children: <Widget>[
                            new Icon(
                              Icons.brightness_1,
                              size: 12.0,
                              color: Colors.red,
                            ),
                          ],
                        ))
                    : Positioned(
                        top: -1.0,
                        right: -1.0,
                        child: new Stack(
                          children: <Widget>[Container()],
                        ))
              ]),
              title: new Text(
                "Chat",
                style: TextStyle(fontSize: 10),
              ),
            ),*/
                                ],
                                index: _page,
                                onTap: (value) {
                                  setState(() {
                                    navigationTapped(value);
                                    //   onPageChanged(value);
                                  });
                                },
                                //   currentIndex: _page,
                              ),
                            ))));
  }
}
