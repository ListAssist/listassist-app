import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/models/current-screen.dart';
import 'package:shoppy/services/auth.dart';
import 'package:shoppy/widgets/shoppinglist-view.dart';

//class Sidebar extends StatefulWidget {
//  @override
//  _Sidebar createState() => _Sidebar();
//}

class Sidebar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var user = Provider.of<FirebaseUser>(context);

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
           ),
            accountName: Text(user.displayName),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Einkaufslisten'),
            onTap: () {
              ScreenModel.of(context).setScreen(ShoppingListView(), 'Einkaufslisten');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.insert_chart),
            title: Text('Statistiken'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.local_offer),
            title: Text('Angebote'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Gruppen'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.mail),
            title: Text('Einladungen'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Einstellungen'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text('Logout'),
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