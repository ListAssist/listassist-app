import 'package:flutter/material.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/widgets/group/add_group.dart';
import 'package:listassist/widgets/group/group_item.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:provider/provider.dart';

class GroupView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<User>(context);
    List<Group> groups = Provider.of<List<Group>>(context);
    print(groups);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: _user.settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
        title: Text("Gruppen"),
        flexibleSpace: _user.settings["theme"] == "Verlauf" ? Container(
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
      body: groups != null ? groups.length == 0 ? Center(child: Text("Keine Gruppen", style: Theme.of(context).textTheme.title)) :
      ListView.separated(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          separatorBuilder: (ctx, i) => Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
        ),
        itemCount: groups.length,
        itemBuilder: (BuildContext ctx, int index) => GroupItem(index: index)
      ) : ShoppyShimmer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "Neue Gruppe erstellen",
        backgroundColor: _user.settings["theme"] == "Grün" ? CustomColors.shoppyGreen : Theme.of(context).primaryColor,
        onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGroup(user: _user,)),
          ),
      ),
    );
  }
}
