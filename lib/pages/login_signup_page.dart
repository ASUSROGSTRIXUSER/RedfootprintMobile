
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:redfootprintios/Admin/AdminPage.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';
import 'package:splashscreen/splashscreen.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage(
      {this.auth, this.loginCallback, this.logoutCallback, this.loginAdmin});

  final BaseAuth auth;
  final VoidCallback loginCallback, logoutCallback, loginAdmin;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  TextEditingController adminkeyController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  MyDatabaseMethods databaseMethods = new MyDatabaseMethods();
  TextEditingController _nameController = new TextEditingController();
  DateTime selectedDate = DateTime.now();
  TextEditingController _birthdayController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmpasswordController =
      new TextEditingController();
  TextEditingController _contactNumberController = new TextEditingController();
  String _isVerified = "false";
  String _gender;
  String _errorMessage;
  bool _isLoginForm;
  bool _isLoading;
  bool createisclickable = false;
  int tapcounttoAdmin = 0;
  bool showAdminText = false;
  QuerySnapshot snapshotUserInfo;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;

    super.initState();
  }

  @override
  void dispose() {
    resetForm();

    super.dispose();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _birthdayController.text =
            selectedDate.toLocal().toString().split(' ')[0];
      });
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    String userId = "";

    try {
      if (_isLoginForm) {
        userId = await widget.auth.signIn(
            _emailController.text.trim(), _passwordController.text.trim());
      } else {
        if (_passwordController.text != _confirmpasswordController.text) {
          _isLoading = false;
          showAlertDialog(context, "Password not match");
        } else if (_emailController.text == "" &&
            _birthdayController.text == "" &&
            _contactNumberController.text == "") {
          showAlertDialog(context, "Please Fill all fields");
          _isLoading = false;
        } else {
          userId = await widget.auth.signUp(
            _emailController.text,
            _nameController.text,
            _passwordController.text,
          );
        }
      }
      if (tapcounttoAdmin >= 10) {
        if (userId.length > 2 && _isLoginForm) {
          //     _firebaseMessaging.getToken().then((tokenValue) {
          //     MyDatabaseMethods().updateMobileToken(tokenValue);
          //   });

          widget.loginAdmin();
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminPage(
                        logout: widget.logoutCallback,
                      )));
        } else if (userId == "2") {
          showAlertDialog(context, 'Link has been sent to your email');
          Map<String, dynamic> userInfoMap = {
            "Email": _emailController.text,
            "Name": _nameController.text,
            "Birthday": selectedDate.toLocal().toString().split(' ')[0],
            "Gender": _gender,
            "isVerified": _isVerified,
            "ProfilePic": "",
            "ContactNumber": _contactNumberController.text,
            "Bio": "",
            "FacebookID": "",
            "NewMessages": "",
            "Address": "[Set up  address]",
            "Education": "[Set up  Education Degree]",
            "Work": "[Set up  work company]",
            "JobTitle": "[Set up  JobTitle]",
            "Recreation": "[Set up  Recreation]",
            "Motivation": "[Set up  Motivation]",
            "Status": "[Set up  Status]",
            "isOnline": false,
            "userID": "",
            "mobileToken": ""
          };

        await  MyDatabaseMethods().uploadUserinfo(userInfoMap);

          widget.logoutCallback();
          widget.auth.signOut();
          resetForm();
        } else if (userId == "1") {
          showAlertDialog(context, 'Please verify your email');

          widget.logoutCallback();
          widget.auth.signOut();

          _isLoading = false;
        }
      } else {
        if (userId.length > 2 && _isLoginForm) {
          _firebaseMessaging.getToken().then((tokenValue) {
            MyDatabaseMethods().updateMobileToken(tokenValue);
          });
          widget.loginCallback();
        } else if (userId == "2") {
          showAlertDialog(context, 'Link has been sent to your email');
          Map<String, dynamic> userInfoMap = {
            "Email": _emailController.text,
            "Name": _nameController.text,
            "Birthday": selectedDate.toLocal().toString().split(' ')[0],
            "Gender": _gender,
            "isVerified": _isVerified,
            "ProfilePic": "",
            "ContactNumber": _contactNumberController.text,
            "Bio": "",
            "FacebookID": "",
            "NewMessages": "",
            "Address": "[Set up  address]",
            "Education": "[Set up  Education Degree]",
            "Work": "[Set up  work company]",
            "JobTitle": "[Set up  JobTitle]",
            "Recreation": "[Set up  Recreation]",
            "Motivation": "[Set up  Motivation]",
            "Status": "[Set up  Status]",
            "isOnline": false,
            "userID": "",
            "mobileToken": ""
          };
          Map<String, dynamic> callAlertMap = {
            "usersStatus": false,
            "CallersName": "",
            'Chatroom': "",
            "CallersProfilePic": "",
          };
          databaseMethods.setCallMap(callAlertMap);
          databaseMethods.uploadUserinfo(userInfoMap);
          widget.logoutCallback();
          widget.auth.signOut();
          resetForm();
        } else if (userId == "1") {
          showAlertDialog(context, 'Please verify your email');

          widget.logoutCallback();
          widget.auth.signOut();

          _isLoading = false;
        }
      }
    } catch (e) {
      if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
        showAlertDialog(context, "Wrong Password");
      } else if (e.toString().contains('Given String is empty')) {
        showAlertDialog(context, "Required Fields Empty");
      } else if (e.toString().contains('The email address is already in use')) {
        showAlertDialog(context, "Email address already registered");
      } else if (e.toString().contains('formatted.')) {
        showAlertDialog(context, "Something is wrong with the email format");
      } else if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
        showAlertDialog(context, "User not found");
      } else if (e.toString().contains('ERROR_TOO_MANY_REQUESTS')) {
        showAlertDialog(context,
            "We have blocked all requests from this device due to unusual activity. Too many unsuccessful login attempts. Please try again later . Try again later");
      }
      _errorMessage = e.toString();
      print(_errorMessage);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void resetForm() {
    _emailController.text = "";
    _nameController.text = "";
    _passwordController.text = "";
    _birthdayController.text = "";
    _confirmpasswordController.text = "";
    _contactNumberController.text = "";
    _errorMessage = "";
    _gender = "";
    _isLoading = false;
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            child: Stack(
          children: [
            _isLoading
                ? _showCircularProgress()
                : _isLoginForm
                    ? _showLoginForm(context)
                    : _showRegisterForm(context),
          ],
        )));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Container(
        child: Center(child: new Image.asset('assets/new_logo.png')),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  showAlertDialog(BuildContext context, String errormessage) {
    if (errormessage == "Wrong Password") {
      Widget sendReset = FlatButton(
        child: Text("Send Password reset"),
        onPressed: () {
          Auth().resetPassword(_emailController.text);
        },
      );
      Widget cancel = FlatButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      // Create AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Forgot password?"),
        content: Text("Send password reset to email"),
        actions: [sendReset, cancel],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      // show the dialog

    }
  }

  showAdminModeActivated(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("Enter"),
      onPressed: () {
        if (adminkeyController.text != "adminkey123") {
          showAlertDialog(context, "Access Denied");
        } else {
          setState(() {
            showAdminText = true;
          });
          Navigator.of(context).pop();
          showAlertDialog(context, "You can now logged in as Admin");
        }

        // Navigator.of(context).pop();
      },
    );
    Widget turnoff = FlatButton(
      child: Text("leave Admin Mode"),
      onPressed: () {
        setState(() {
          showAdminText = false;
          tapcounttoAdmin = 0;
        });
        Navigator.of(context).pop();
      },
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Admin Mode Activated"),
      content: TextField(
        maxLines: 2,
        keyboardType: TextInputType.multiline,
        onChanged: (value) {
          //   _chatcontroller.jumpTo(
          //          _chatcontroller.position.maxScrollExtent);
        },
        onTap: () {
          setState(() {
            //   isTyping = true;
          });
        },
        controller: adminkeyController,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          filled: true,
          hintText: "Admin Key",
          fillColor: Colors.white70,
          hintStyle: TextStyle(color: Colors.grey[800]),
        ),
      ),
      actions: [okButton, turnoff],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    // show the dialog
  }

  Widget _showLoginForm(context) {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              SizedBox(
                height: 80,
              ),
              showAdminText
                  ? Center(
                      child: Text(
                        "Admin Mode",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : Container(),
              showEmailInput(),
              showPasswordInput(),
              SizedBox(
                height: 50,
              ),
              showPrimaryButton(),
              showAdminText ? Container() : showSecondaryButton(),
              //    showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showRegisterForm(context) {
    return new Container(
        padding: EdgeInsets.all(10.0),
        child: new Form(
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showFullNameInput(),
              showEmailInput(),
              showPasswordInput(),
              showConfirmPasswordInput(),
            //  showBirthdayInput(),
            //  showContactNumberInput(),
             // showGenderRadioButton(),
              showPrimaryButton(),
              showSecondaryButton(),
              // showErrorMessage(),
            ],
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
  Widget showLogo() {
    return GestureDetector(
        onTap: () {
          //  tapcounttoAdmin = 1;

          setState(() {
            print(tapcounttoAdmin);
            tapcounttoAdmin++;
            if (tapcounttoAdmin >= 10) {
              showAdminModeActivated(context);
            }
          });
        },
        child: Hero(
          tag: 'hero',
          child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 80.0,
              child: Image.asset('assets/new_logo.png'),
            ),
          ),
        ));
  }

  Widget showBirthdayInput() {
    return Column(children: <Widget>[
      Padding(padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0)),
      TextFormField(
        maxLines: 1,
        autofocus: false,
        controller: _birthdayController,
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
        validator: (value) => selectedDate.toString().isEmpty
            ? 'Please enter your Birthdate'
            : null,
      ),
    ]);
  }

  Widget showFullNameInput() {
    return Column(children: <Widget>[
      Padding(padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0)),
      TextFormField(
        controller: _nameController,
        maxLines: 1,
        keyboardType: TextInputType.name,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Full name',
            icon: new Icon(
              Icons.person,
              color: Colors.black,
            )),
        validator: (value) =>
            _nameController.text.isEmpty ? 'Please enter your name' : null,
      ),
    ]);
  }

  Widget showContactNumberInput() {
    return Column(children: <Widget>[
      Padding(padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0)),
      TextFormField(
        controller: _contactNumberController,
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Contact Number',
            icon: new Icon(
              Icons.format_list_numbered,
              color: Colors.black,
            )),
        validator: (value) => _contactNumberController.text.isEmpty
            ? 'Please enter your mobile number'
            : null,
      ),
    ]);
  }

  Widget showEmailInput() {
    return Column(children: <Widget>[
      TextFormField(
        controller: _emailController,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.black,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _emailController.text = value.trim(),
      ),
    ]);
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _passwordController,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.black,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _passwordController.text = value.trim(),
      ),
    );
  }

  Widget showConfirmPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _confirmpasswordController,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Confirm Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.black,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _confirmpasswordController.text = value.trim(),
      ),
    );
  }

  Widget showGenderRadioButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.wc,
          color: Colors.black,
        ),
        LabeledRadio(
          label: 'Male',
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20),
          value: 'Female',
          groupValue: _gender,
          onChanged: (newValue) {
            setState(() {
              _gender = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            child: new Text(_isLoginForm ? 'Login' : 'Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    this.label,
    this.padding,
    this.groupValue,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final String groupValue;
  final String value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) onChanged(value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Radio<String>(
              groupValue: groupValue,
              value: value,
              onChanged: (newValue) {
                onChanged(newValue);
              },
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
