import 'package:flutter/material.dart';
import 'package:listassist/widgets/profilesettings-view.dart';
import 'package:listassist/widgets/notificationsettings-view.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/shoppinglistsettings-view.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatelessWidget {
  String img = "https://www.indiewire.com/wp-content/uploads/2019/05/shutterstock_8999492b.jpg?w=780";


  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
              "Abmelden",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
          ),
          content: new Text("Möchten Sie sich von Ihrem ListAssist-Konto abmelden?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                  "ABBRECHEN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new FlatButton(
              child: new Text(
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

  _launchURL() async {
    print("keko");
    const url = 'https://listassist.gq/impressum.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      //backgroundColor: Colors.transparent,
      appBar: new AppBar(
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Container(
              margin: const EdgeInsets.only(bottom: 25.0),
              child:
              CircleAvatar(
                backgroundImage: NetworkImage(img),
                radius: 50,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child:
              Text(
                "Tobias Seczer",
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center,
              )
            ),

            Text(
              "tobias.seczer@gmail.com",
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
                            builder: (context) => ProfilesettingsView()
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
                        _launchURL()
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
                      onTap: () => {},
                    ),

                  ],
                )
            ),


          ],
        ),
      ),
    );
  }
}