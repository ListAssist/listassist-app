import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/assets/custom_colors.dart';
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
  List<Achievement> _achievements;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    _achievements = user.achievements;
    print(_achievements);
    _achievements.sort((a, b) => a.compareTo(b));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<User>(context).settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
        title: Text("Erfolge"),
        flexibleSpace: Provider.of<User>(context).settings["theme"] == "Verlauf" ? Container(
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
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 30),
              child: Column(
                children: <Widget>[
                  Text(_achievements.length.toString() + " / " + achievementsService.achievements.length.toString() + " Erfolge freigeschaltet", style: TextStyle(fontSize: 20),),
                  LinearPercentIndicator(
                    padding: EdgeInsets.only(top: 20, left: 50, right: 50),
                    lineHeight: 8.0,
                    percent: _achievements.length/achievementsService.achievements.length,
                    progressColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            _achievements.length != 0 ? Expanded(
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
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
