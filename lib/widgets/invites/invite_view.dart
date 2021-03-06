import 'package:flutter/material.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/Invite.dart' as model;
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:provider/provider.dart';
import 'invite.dart';

class InviteView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: user.settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
        title: Text("Einladungen"),
        flexibleSpace: user.settings["theme"] == "Verlauf" ? Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: <Color>[
                        CustomColors.shoppyBlue,
                        CustomColors.shoppyLightBlue,
                      ])
              )) : Container(),
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: "Open navigation menu",
          onPressed: () => mainScaffoldKey.currentState.openDrawer(),
        ),
      ),
      body: StreamProvider.value(
        value: databaseService.streamInvites(user.uid),
        child: InviteItems()
      )
    );

  }
}

class InviteItems extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    List<model.Invite> invites = Provider.of<List<model.Invite>>(context);
    return invites != null ? invites.length == 0 ? Center(child: Text("Keine Einladungen", style: Theme.of(context).textTheme.title,)) :
      ListView.builder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: invites.length,
        itemBuilder: (BuildContext ctx, int index) {
          return Invite(invite: invites[index]);
        }
      ) : ShoppyShimmer();
  }
}