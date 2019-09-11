import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  @override
  _ExtFileState createState() => _ExtFileState();
}
class _ExtFileState extends State {
  String img = "https://proxy.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.tractionwise.com%2Fwp-content%2Fuploads%2F2016%2F04%2FIcon-Person.png&f=1&nofb=1";
  String name = "Tobias Seczer";
  String email = "tobias.seczer@gmail.com";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
//        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
           ),
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(img),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Einkaufslisten"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.pie_chart),
            title: Text("Statistiken"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.local_offer),
            title: Text("Angebote"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text("Gruppen"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text("Einladungen"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Einstellungen"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text("Logout"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }
}