import 'package:flutter/material.dart';
import 'package:listassist/services/global.dart';
import 'package:listassist/widgets/group-view.dart';
import 'package:listassist/models/current-screen.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/invite-view.dart';
import 'package:listassist/widgets/shoppinglist-view.dart';
import 'package:scoped_model/scoped_model.dart';


class Sidebar extends StatefulWidget {
  @override
  _Sidebar createState() => _Sidebar();
}
class _Sidebar extends State<Sidebar> {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<GlobalService>(
      model: globalService,
      child: ScopedModelDescendant<GlobalService>(
        builder: (context, child, model) => Drawer(
            child: Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  accountName: Text(model.user.displayName ?? ""),
                  accountEmail: Text(model.user.email ?? ""),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(model.user.photoUrl ?? ""),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text("Einkaufslisten"),
                  onTap: () {
                    ScreenModel.of(context).setScreen(ShoppingListView());
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
                    ScreenModel.of(context).setScreen(GroupView());
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mail),
                  title: Text("Einladungen"),
                  onTap: () {
                    ScreenModel.of(context).setScreen(InviteView());
                    Navigator.pop(context);
                  },
                ),
                Divider(),
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
                    authService.signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            )
        ),
      )
    );
  }
}