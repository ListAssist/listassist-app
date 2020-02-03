import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeView createState() => _RecipeView();
}

class _RecipeView extends State<RecipeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {

        },
      ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Rezepte"),
          leading: IconButton(
            icon: Icon(Icons.menu),
            tooltip: "Sidebar öffnen",
            onPressed: () => mainScaffoldKey.currentState.openDrawer(),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Card(
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0, bottom: 6.0),
              child: ExpansionTile(
                title: Text(
                  'Liptaueraufstrich',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: 250,
                            child: Text(
                              "Dies ist ein tolles Gericht für 3 Leudfies ist ein tolles Gericht für Dies ist ein tolles Gericht für 3 sdfsdfasdf, Dies ist ein tolles Gericht für 3 Leute, Dies ist ein tolles Gericht für 3 Leute, ",
                              softWrap: true,
                              textAlign: TextAlign.center,
                            )),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0, bottom: 8.0),
                    child: ListTile(
                      title: Text("Zutaten"),
                      subtitle: Text("Eis, KEko, Argeta, Semmel, Senf, Soße, Bohnen, weiße Bohnen, Kekomat, Zwiebel", maxLines: 1, overflow: TextOverflow.ellipsis,),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () {

                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: FloatingActionButton.extended(
                      icon: Icon(Icons.check),
                      label: Text("Liste erstellen"),
                      backgroundColor: Colors.green,
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
