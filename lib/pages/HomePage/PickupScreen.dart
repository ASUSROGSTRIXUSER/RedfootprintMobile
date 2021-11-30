import 'package:flutter/material.dart';


class PickupScreen extends StatelessWidget {
  String callersName;
  String role;
  String chatroomID;
  PickupScreen({this.callersName, this.role, this.chatroomID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            //  CachedImage(
            //   call.callerPic,
            //    isRound: true,
            //   radius: 180,
            // ),
            SizedBox(height: 15),
            Text(
              callersName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    //      await callMethods.endCall(call: call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                    icon: Icon(Icons.call),
                    color: Colors.green,
                    onPressed: () {
                      //    Navigator.push(
                      ///         context,
                      //       MaterialPageRoute(
                      //           builder: (context) => CallPage(
                      //   channelName: chatroomID, role: Video_Call)));
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
