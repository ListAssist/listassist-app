import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Achievement.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/achievements.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class AchievementsView extends StatefulWidget {
  @override
  _AchievementsView createState() => _AchievementsView();
}

class _AchievementsView extends State<AchievementsView> {
  List<Achievement> _achievements = [];

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    _achievements = user.achievements;
    _achievements.sort((a, b) => a.compareTo(b));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Errungenschaften"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: "Open navigation menu",
          onPressed: () => mainScaffoldKey.currentState.openDrawer(),
        ),
      ),
      body: _achievements.length != 0 ? Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 30),
              child: Column(
                children: <Widget>[
                  Text(_achievements.length.toString() + " / " + achievementsService.achievements.length.toString() + " Erfolge", style: TextStyle(fontSize: 20),),
                  LinearPercentIndicator(
                    padding: EdgeInsets.only(top: 20, left: 50, right: 50),
                    lineHeight: 8.0,
                    percent: _achievements.length/achievementsService.achievements.length,
                    progressColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _achievements.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 8,
                    color: Colors.green,
                    child: ListTile(
                      title: Text(_achievements[index].name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      subtitle: AutoSizeText(_achievements[index].description, style: TextStyle(color: Colors.white), maxLines: 2,),
                      trailing: Text(_achievements[index].points.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      contentPadding: EdgeInsets.only(left: 15, right: 15),
                      //leading: Icon(Icons.stars, color: Colors.yellowAccent,),
                      //isThreeLine: true,
                      //dense: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ) : ShoppyShimmer(),
    );
  }
}
