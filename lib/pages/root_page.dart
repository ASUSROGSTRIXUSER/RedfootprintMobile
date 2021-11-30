import 'package:flutter/material.dart';
import 'package:redfootprintios/Admin/AdminPage.dart';
import 'package:redfootprintios/services/authentication.dart';

import 'HomePage/NewHomePage.dart';
import 'login_signup_page.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
  LOGGED_ADMIN,
}

class RootPage extends StatefulWidget {
  RootPage({
    this.auth,
  });

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          setState(() {
            _userId = user?.uid;
          });
        }
        authStatus = user?.uid == null
            ? AuthStatus.NOT_LOGGED_IN
            : _userId.contains("Admin")
                ? AuthStatus.LOGGED_ADMIN
                : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void loginCallbackAdmin() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString() + " Admin";
      });
    });
    //print("LoginAdmin Called");
    setState(() {
      authStatus = AuthStatus.LOGGED_ADMIN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Scaffold(backgroundColor: Colors.yellow,);
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        widget.auth.signOut();
        return new LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
          logoutCallback: logoutCallback,
          loginAdmin: loginCallbackAdmin,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new NewHomePage(
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      case AuthStatus.LOGGED_ADMIN:
        if (_userId.length > 0 && _userId != null) {
          return new AdminPage(
              //   logoutCallback: logoutCallback,
              );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
