import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:redfootprintios/pages/login_signup_page.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

class DropdownSamplePage extends StatefulWidget {
  @override
  _DropdownSamplePageState createState() => _DropdownSamplePageState();
}

class _DropdownSamplePageState extends State<DropdownSamplePage> {
  var selectedCivilStatus, selectedTypeJobTitle;
  String _currentUserEmail;
  String _gender;

  DateTime selectedbirthdate = DateTime.now();
  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();
  TextEditingController addressController = new TextEditingController();
  TextEditingController educationController = new TextEditingController();
  TextEditingController workController = new TextEditingController();
  TextEditingController jobTitleController = new TextEditingController();
  TextEditingController motivationController = new TextEditingController();
  TextEditingController statusController = new TextEditingController();
  TextEditingController recreationController = new TextEditingController();
  TextEditingController mobilenumberController = new TextEditingController();
  TextEditingController birthdayController = new TextEditingController();
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
  @override
  void initState() {
    super.initState();

    Auth().getCurrentUser().then((currentUserData) {
      _currentUserEmail = currentUserData?.email;
      MyDatabaseMethods().getuserInfo(_currentUserEmail).then((otherDetails) {
        setState(() {
          addressController.text = otherDetails.data['Address'].toString();
          educationController.text = otherDetails.data['Education'].toString();
          statusController.text = otherDetails.data['Status'].toString();
          workController.text = otherDetails.data['Work'].toString();
          recreationController.text =
              otherDetails.data['Recreation'].toString();
          motivationController.text =
              otherDetails.data['Motivation'].toString();
          jobTitleController.text = otherDetails.data['JobTitle'].toString();
          _gender = otherDetails.data['Gender'].toString();
          birthdayController.text = otherDetails.data['Birthday'].toString();
          mobilenumberController.text =
              otherDetails.data['ContactNumber'].toString();
        });
      });
    });
  }

  save() {
    try {
      MyDatabaseMethods().updateAccountDetails(
        _currentUserEmail,
        addressController.text,
        educationController.text,
        jobTitleController.text,
        workController.text,
        recreationController.text,
        motivationController.text,
        statusController.text,
        _gender,
        birthdayController.text,
        mobilenumberController.text,
      );
      Navigator.pop(context);
      print(addressController.text +
          " " +
          educationController.text +
          " " +
          jobTitleController.text +
          " " +
          workController.text +
          " " +
          recreationController.text +
          " " +
          motivationController.text +
          " " +
          statusController.text +
          " " +
          _gender +
          " " +
          birthdayController.text +
          " " +
          mobilenumberController.text +
          " ");
    } catch (e) {
      print(e);
    }
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
        birthdayController.text =
            selectedbirthdate.toLocal().toString().split(' ')[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Account Details",
              style: GoogleFonts.roboto(fontSize: 17, color: Colors.white)),
          backgroundColor: Color(0xFFA41D21),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.save, color: Colors.white),
                color: Colors.black,
                onPressed: save),
          ],
        ),
        body: Form(
          key: _formKeyValue,
          autovalidate: true,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              Text(
                'Customize Your Intro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 20.0),
              Text(
                'Details you select will be public.',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Civil Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                  statusController.text.toString(),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Recreation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
              SizedBox(
                height: 10,
              ),
              Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
              SizedBox(
                height: 10,
              ),
              Text(
                "Mobile Number",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextFormField(
                controller: mobilenumberController,
                maxLines: 1,
                keyboardType: TextInputType.number,
                autofocus: false,
                decoration: new InputDecoration(
                    hintText: 'Mobile Number',
                    icon: new Icon(
                      Icons.format_list_numbered,
                      color: Colors.black,
                    )),
                validator: (value) => mobilenumberController.text.isEmpty
                    ? 'Please enter your mobile number'
                    : null,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Birthday",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextFormField(
                maxLines: 1,
                autofocus: false,
                controller: birthdayController,
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
                validator: (value) => selectedbirthdate.toString().isEmpty
                    ? 'Please enter your Birthdate'
                    : null,
              ),

              /*   StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("currency").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      const Text("Loading.....");
                    else {
                      List<DropdownMenuItem> currencyItems = [];
                      for (int i = 0; i < snapshot.data.documents.length; i++) {
                        DocumentSnapshot snap = snapshot.data.documents[i];
                        currencyItems.add(
                          DropdownMenuItem(
                            child: Text(
                              snap.documentID,
                              style: TextStyle(color: Color(0xff11b719)),
                            ),
                            value: "${snap.documentID}",
                          ),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 50.0),
                          DropdownButton(
                            items: currencyItems,
                            onChanged: (currencyValue) {
                              final snackBar = SnackBar(
                                content: Text(
                                  'Selected Currency value is $currencyValue',
                                  style: TextStyle(color: Color(0xff11b719)),
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              setState(() {
                                selectedCurrency = currencyValue;
                              });
                            },
                            value: selectedCurrency,
                            isExpanded: false,
                            hint: new Text(
                              "Choose Currency Type",
                              style: TextStyle(color: Color(0xff11b719)),
                            ),
                          ),
                        ],
                      );
                    }
                  }),*/
            ],
          ),
        ));
  }
}
