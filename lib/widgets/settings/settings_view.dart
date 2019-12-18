import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/widgets/settings/notification_settings_view.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/settings/profile_settings_view.dart';
import 'package:listassist/widgets/settings/shopping_list_settings_view.dart';
import 'package:listassist/widgets/shoppinglist/item_counter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String img = "https://www.indiewire.com/wp-content/uploads/2019/05/shutterstock_8999492b.jpg?w=780";

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
              "Abmelden",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
          ),
          content: Text("Möchten Sie sich von Ihrem ListAssist-Konto abmelden?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                  "ABBRECHEN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
              ),
              onPressed: () {
                authService.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _showDialog(context);
              //Navigator.pop(context);
            },
          ),
        ],
      ),
      body:
        Test(),
      );
  }
}

class Test extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    User user  = Provider.of<User>(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Container(
            margin: EdgeInsets.only(bottom: 25.0),
            child:
            Hero(
              tag: "profilePicture",
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 50,
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child:
              Text(
                user.displayName,
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center,
              )
          ),

          Text(
            user.email,
            //style: Theme.of(context).textTheme.headline,
            textAlign: TextAlign.center,
          ),

          Container(
              margin: const EdgeInsets.only(top: 30.0),
              child:
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[

                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Konto'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileSettingsView(),
                          )
                      )
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.view_agenda),
                    title: Text('Ansicht'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShoppinglistsettingsView()
                          )
                      )
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Benachrichtigungen'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Keko()
                          )
                      )
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Datenschutz'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => {
                      _launchURL("https://listassist.gq/impressum.html")
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.bug_report),
                    title: Text('Fehler melden'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => {},
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Info'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => {
                      _launchURL("https://listassist.gq")
                    },
                  ),

                ],
              )
          ),


        ],
      ),
    );
  }



  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}