import 'package:flutter/material.dart';
import 'package:listassist/widgets/group-view.dart';
import 'package:provider/provider.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/models/current-screen.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/settings-view.dart';
import 'package:listassist/widgets/shoppinglist-view.dart';


class Sidebar extends StatefulWidget {
  @override
  _Sidebar createState() => _Sidebar();
}
class _Sidebar extends State<Sidebar> {

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(user.displayName),
            accountEmail: Text(user.email),
            currentAccountPicture: Hero(
              tag: "profilePicture",
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Einkaufslisten"),
            onTap: () {
              ScreenModel.of(context).setScreen(ShoppingListView(), "Einkaufslisten");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.insert_chart),
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
          Divider(),
          ListTile(
            leading: Icon(Icons.group),
            title: Text("Gruppen"),
            onTap: () {
              ScreenModel.of(context).setScreen(GroupView(), "Gruppen");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.mail),
            title: Text("Einladungen"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Einstellungen"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsView()));
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text("Logout"),
            onTap: () {
              authService.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }
}