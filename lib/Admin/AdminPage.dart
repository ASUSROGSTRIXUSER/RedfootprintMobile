
import 'package:flutter/material.dart';
import 'package:redfootprintios/Admin/AddEvents.dart';
import 'package:redfootprintios/Admin/AddNews.dart';
import 'package:redfootprintios/Admin/Moderator.dart';
import 'package:redfootprintios/services/authentication.dart';


class AdminPage extends StatefulWidget {
  // This will contain the URL/asset path which we want to play
  final VoidCallback logout;
  AdminPage({this.logout});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    // Wrapper on top of the videoPlayerController
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
                onTap: () {
                  Auth().signOut();
                  Navigator.of(context).pop(true);
                },
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: Color(0xFFA41D21),
              appBar: PreferredSize(
                preferredSize: Size(0, 90),
                child: AppBar(
                  centerTitle: true,
                  title: Text("Admin Page"),
                  backgroundColor: Color(0xFFA41D21),
          /*
                  actions: [IconButton(icon: Icon(Icons.logout),
                  onPressed: (){
                    Auth().signOut();
                  },)],*/
                  bottom: TabBar(
                    tabs: [
                      Tab(
                          icon: Column(
                        children: [
                          Icon(
                            Icons.chat,
                            color: Colors.white,
                          ),
                          Text("News"),
                        ],
                      )),
                      Tab(
                          icon: Column(
                        children: [
                          Icon(
                            Icons.videocam,
                            color: Colors.white,
                          ),
                          Text("Events"),
                        ],
                      )),
                      Tab(
                          icon: Column(
                        children: [
                          Icon(
                            Icons.chat,
                            color: Colors.white,
                          ),
                          Text("Moderator"),
                        ],
                      ))
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                  children: [NewsPage(), AddEvent(), ModeratorPage()]),
            )));
  }

  @override
  void dispose() {
    super.dispose();
    // IMPORTANT to dispose of all the used resources

    // _chewieController.dispose();
  }
}
