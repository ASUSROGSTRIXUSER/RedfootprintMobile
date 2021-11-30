import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:redfootprintios/Settings/Settings_page.dart';
import 'package:redfootprintios/pages/ChatAndVideo/ChatsOnly.dart';
import 'package:redfootprintios/pages/Notifications/NotificationPage.dart';
import 'package:redfootprintios/pages/ProfilePages/UserProfilePage.dart';
import 'package:redfootprintios/services/authentication.dart';
import '../../services/database.dart';
import '../ProspectContacts/ContactRoom.dart';
import '../ProspectContacts/ProspectContacts.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MyDatabaseMethods databaseMethods = new MyDatabaseMethods();
  String _userId = "";
  String _userName = "";
  String _photoURL = "";
  bool _verify = false;
  BaseAuth auth;

  QuerySnapshot userInfoSnapchat;
  @override
  void initState() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        _userId = user?.email;
        _userName = user?.displayName;
        _photoURL = user?.photoUrl;
        _verify = user?.isEmailVerified;
      });
    });

    super.initState();
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  Widget appbar() {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Profile'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: signOut)
        ],
      ),
      drawer: new Drawer(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black38,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              accountName: Text('$_userName'),
              accountEmail: Text('$_userId'),
              currentAccountPicture: new Container(
                child: CircleAvatar(
                  backgroundImage: (_photoURL != null)
                      ? NetworkImage(
                          _photoURL,
                        )
                      : NetworkImage(
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg",
                        ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.contacts, color: Colors.white),
              title: Text(
                "Contact",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ContactRoom()));
              },
            ),
            ListTile(
              leading: Icon(Icons.wc, color: Colors.white),
              title: Text(
                'Prospect',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProspectContacts()));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.white),
              title: Text(
                'Chat',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Chatroom()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
              title: Text(
                'Notification',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationPage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.assessment,
                color: Colors.white,
              ),
              title: Text(
                'Trainings',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              //  backgroundColor: Colors.blue[700],
              title: Text(
                'Settings',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
          ],
        ),
      ) // Populate the Drawer in the next step.
          ),
      body: ProfileCustomization(),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return _verify
          ? appbar()
          : new Scaffold(
              appBar: new AppBar(
                title: new Text('Profile'),
                backgroundColor: Colors.deepPurple,
                actions: <Widget>[
                  new FlatButton(
                      child: new Text('Logout',
                          style: new TextStyle(
                              fontSize: 17.0, color: Colors.white)),
                      onPressed: signOut)
                ],
              ),
              body: Center(
                child: Text(
                  'Please Verify Your Email',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            );
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Choice {
  final String title;
  final IconData icon;
  const Choice({this.title, this.icon});
}

const List<Choice> choices = <Choice>[
  Choice(title: 'CAR', icon: Icons.directions_car),
  Choice(title: 'BICYCLE', icon: Icons.directions_bike),
  Choice(title: 'BUS', icon: Icons.directions_bus),
  Choice(title: 'TRAIN', icon: Icons.directions_railway),
  Choice(title: 'WALK', icon: Icons.directions_walk),
  Choice(title: 'BOAT', icon: Icons.directions_boat),
];

class ChoicePage extends StatelessWidget {
  const ChoicePage({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              choice.icon,
              size: 150.0,
              color: textStyle.color,
            ),
            Text(
              choice.title,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
