import 'package:flutter/material.dart';

class Keko extends StatefulWidget{
  NotificationsettingsView createState()=> NotificationsettingsView();
}

class NotificationsettingsView extends State<Keko> {

  String img = "https://www.indiewire.com/wp-content/uploads/2019/05/shutterstock_8999492b.jpg?w=780";
  bool _notifications = true;
  bool _group = true;
  bool _autolist = true;
  bool _offer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
        appBar: new AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                        SwitchListTile(
                          title: const Text('Benachrichtigungen'),
                          value: _notifications,
                          onChanged: (bool value) {
                            setState(() {
                              _notifications = value;
                            });
                          },
                          secondary: const Icon(Icons.notifications),
                        ),
                        Divider(),

                        SwitchListTile(
                          title: const Text('Gruppeneinladungen'),
                          value: _group,
                          onChanged: (bool value) {
                            setState(() {
                              _group = value;
                            });
                          },
                          secondary: const Icon(Icons.mail),
                        ),

                        SwitchListTile(
                          title: const Text('Automatische Einkaufsliste'),
                          value: _autolist,
                          onChanged: (bool value) {
                            setState(() {
                              _autolist = value;
                            });
                          },
                          secondary: const Icon(Icons.autorenew),
                        ),

                        SwitchListTile(
                          title: const Text('Angebote'),
                          value: _offer,
                          onChanged: (bool value) {
                            setState(() {
                              _offer = value;
                            });
                          },
                          secondary: const Icon(Icons.local_offer),
                        ),


                      ]
                  )
                ])
        )
    );
  }
}