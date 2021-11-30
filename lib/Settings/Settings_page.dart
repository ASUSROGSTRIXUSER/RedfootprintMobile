
import 'package:flutter/material.dart';
import 'package:redfootprintios/Settings/terms.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

//import 'package:login_minimalist/pages/login.page.dart';
import 'settings_ui.dart';

import 'Settings_page_language.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback logoutCallback;
  final String currentUserSettings;
  const SettingsScreen({Key key, this.logoutCallback, this.currentUserSettings})
      : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  signOut() async {
    try {
      await Auth().signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  showAlertDialog(BuildContext contextalert, BuildContext contextSettingpage) {
    // Create button
    Widget signout = FlatButton(
      child: Text("Signout"),
      onPressed: () {
        MyDatabaseMethods().mobileTokenEmpty(widget.currentUserSettings);
        MyDatabaseMethods().setStatusOffline(widget.currentUserSettings);
        signOut();

        Navigator.of(contextalert).pop();
        Navigator.of(contextSettingpage).pop();
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

  showAlertDialogforResetPassword(
    BuildContext context,
  ) {
    // Create button
    Widget signout = FlatButton(
      child: Container(
          color: Colors.lightBlue,
          child: Container(
              margin: EdgeInsets.all(10),
              child: Text(
                "Confirm Change Password",
                style: TextStyle(color: Colors.white),
              ))),
      onPressed: () {
        Auth().resetPassword(widget.currentUserSettings);
        signOut();
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
      title: Row(children: [
        Icon(
          Icons.warning,
          color: Colors.redAccent,
        ),
        SizedBox(
          width: 5,
        ),
        Text("Alert"),
      ]),
      content: SingleChildScrollView(
        child: Container(
          height: 170,
          child: Column(
            children: [
              Text("A password reset will be sent to your email :"),
              SizedBox(
                height: 5,
              ),
              Icon(Icons.email),
              Text(widget.currentUserSettings),
              SizedBox(
                height: 40,
              ),
              Text(
                "Note: Changing Password will log you out",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.redAccent,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
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

  @override
  Widget build(BuildContext contextSettingpage) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFA41D21),
      ),
      body: SettingsList(
        sections: [
          /* SettingsSection(
            title: 'Common',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => LanguagesScreen()));
                },
              ),
              /*  SettingsTile(
                  title: 'Environment',
                  subtitle: 'Production',
                  leading: Icon(Icons.cloud_queue)),*/
            ],
          ),*/
          /*    SettingsSection(
            title: 'Account',
            tiles: [
              //   SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              // SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(
                title: 'Log out',
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  showAlertDialog(context, contextSettingpage);
                },
              ),
            ],
          ),*/
          SettingsSection(
            title: 'Security',
            tiles: [
              /* SettingsTile.switchTile(
                title: 'Lock app in background',
                leading: Icon(Icons.phonelink_lock),
                switchValue: lockInBackground,
                onToggle: (bool value) {
                  setState(() {
                    lockInBackground = value;
                    notificationsEnabled = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  leading: Icon(Icons.fingerprint),
                  onToggle: (bool value) {},
                  switchValue: false),*/
              SettingsTile(
                title: 'Change password',
                leading: Icon(Icons.lock),
                onTap: () {
                  showAlertDialogforResetPassword(context);
                },
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
                enabled: notificationsEnabled,
                leading: Icon(Icons.notifications_active),
                switchValue: true,
                onToggle: (value) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Misc',
            tiles: [
              SettingsTile(
                onTap:  (){Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => TermsAndCondition()));} ,
                  title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Open source licenses',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          )
        ],
      ),
    );
  }
}
