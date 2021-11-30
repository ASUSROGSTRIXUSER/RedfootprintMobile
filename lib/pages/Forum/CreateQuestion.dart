
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

class CreateQuestionPage extends StatefulWidget {
  //
  CreateQuestionPage() : super();

  // final String title = "Charts Demo";

  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  String _currentUserEmail;
  String _currentUserName;
  String _currentUserProfilePic;
  ScrollController scrollForum = new ScrollController();
  String _currentphotoUrl;
  //var mediaHeight;
  List _myActivities;
  List _like;
  String _myActivitiesResult;
  TextEditingController questionTextController = new TextEditingController();
  TextEditingController answerTextController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    _myActivities = [];
    _like = [];
    _myActivitiesResult = '';

    Auth().getCurrentUser().then((user) {
      setState(() {
        _currentUserEmail = user?.email;
        _currentUserName = user?.displayName;
        _currentUserProfilePic = user?.photoUrl;
        //  _like = [_currentUserName];
      });
    });
  }

  showAlertDialogPending(BuildContext context) {
    // Create AlertDialog

    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Your Question is Pending until Approved by the Admins"),
      // content: Text(errormessage),
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

  _saveForm() {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivitiesResult = _myActivities.toString();
        for (var i = 0; i < _myActivities.length; i++) {
          print(_myActivities[i]);
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(30.0),
              topRight: const Radius.circular(30.0),
              bottomLeft: const Radius.circular(30.0),
              bottomRight: const Radius.circular(30.0),
            ),
          ),
          //  color: Colors.white,
          margin: EdgeInsets.fromLTRB(5, 20, 5, 5),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset("assets/Question.jpg"),
                TextField(
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  controller: questionTextController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    filled: true,
                    hintText: "Whats your Question?",
                    fillColor: Colors.white70,
                    hintStyle: TextStyle(color: Colors.grey[800]),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(16),
                          child: MultiSelectFormField(
                            autovalidate: false,
                            chipBackGroundColor: Colors.red,
                            chipLabelStyle:
                                TextStyle(fontWeight: FontWeight.bold),
                            dialogTextStyle:
                                TextStyle(fontWeight: FontWeight.bold),
                            checkBoxActiveColor: Colors.redAccent,
                            checkBoxCheckColor: Colors.white,
                            dialogShapeBorder: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0))),
                            title: Text(
                              "Tags",
                              style: TextStyle(fontSize: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.length == 0) {
                                return 'Please select one or more options';
                              }
                              return null;
                            },
                            dataSource: [
                              {
                                "display": "Review Related",
                                "value": "Review Related",
                              },
                              {
                                "display": "Approach Related",
                                "value": "Approach Related",
                              },
                              {
                                "display": "Strategy Related",
                                "value": "Strategy Related",
                              },
                              {
                                "display": "Guide Related",
                                "value": "Guide Related",
                              },
                              {
                                "display": "Problem Related",
                                "value": "Problem Related",
                              },
                              {
                                "display": "Health Related",
                                "value": "Health Related",
                              },
                              {
                                "display": "Testimony Related",
                                "value": "Testimony Related",
                              },
                            ],
                            textField: 'display',
                            valueField: 'value',
                            okButtonLabel: 'OK',
                            cancelButtonLabel: 'CANCEL',
                            hintWidget: Text('Please choose one or more'),
                            initialValue: _myActivities,
                            onSaved: (value) {
                              if (value == null) return;
                              setState(() {
                                _myActivities = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                    child: RaisedButton.icon(
                  color: Color(0xFFA41D21),
                  onPressed: () {
                    _saveForm();
                    if (questionTextController.text == "") {
                    } else if (_myActivities.length == 0) {
                    } else {
                      Map<String, dynamic> questionMap = {
                        "Question": questionTextController.text,
                        "QuestioneeUserProfile": _currentUserProfilePic,
                        "QuestioneeUserEmail": _currentUserEmail,
                        "QuestioneeName": _currentUserName,
                        "Likes": _like,
                        "tags": _myActivities,
                        "usersthatanswered": _like,
                        "isAnswered": false,
                        'isPending': true,
                        "isAdminApproved": false,
                         "QuestionCreatedtimestamp": FieldValue.serverTimestamp(),
                      };
                      MyDatabaseMethods().addForumQuestion(
                          questionMap, questionTextController.text);

                      showAlertDialogPending(
                        context,
                      );

                      //  Navigator.pop(context);
                    }
                  },
                  icon: Icon(
                    Icons.add_box,
                    color: Colors.white,
                  ),
                  label: Text("Post Question",
                      style: TextStyle(color: Colors.white)),
                ))
              ],
            ),
          )),
    );
  }
}
