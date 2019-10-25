import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/Invite.dart' as model;
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/global.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'invite.dart';

class InviteView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<GlobalService>(
      model: globalService,
      child: ScopedModelDescendant<GlobalService>(
        builder: (ctx, child, model) => Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text("Einladungen"),
            leading: IconButton(
              icon: Icon(Icons.menu),
              tooltip: "Open navigation menu",
              onPressed: () => mainScaffoldKey.currentState.openDrawer(),
            ),
          ),
          body: StreamProvider.value(
            value: databaseService.streamInvites(model.user.uid),
            child: InviteItems()
          )
        ),
      )
    );

  }
}

class InviteItems extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    List<model.Invite> invites = Provider.of<List<model.Invite>>(context);
    return invites != null ?
      ListView.builder(
          itemCount: invites.length,
          itemBuilder: (BuildContext ctx, int index) {
            return Invite(creator: invites[index].from, title: invites[index].groupname);
          }
      ) : SpinKitDoubleBounce(color: Colors.blueAccent);
  }
}