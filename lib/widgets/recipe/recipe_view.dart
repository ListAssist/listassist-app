import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Recipe.dart';
import 'package:listassist/widgets/recipe/create_recipe_view.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeView createState() => _RecipeView();
}

class _RecipeView extends State<RecipeView> {
  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes = Provider.of<List<Recipe>>(context);
    return Scaffold(
        //backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateRecipeView()));
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
          child: recipes != null ? ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0, bottom: 6.0),
                  child: ExpansionTile(
                    title: Text(
                      recipes[index].name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: <Widget>[
                      recipes[index].description != null ? Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 250,
                                child: Text(
                                  recipes[index].description,
                                  //softWrap: true,
                                  textAlign: TextAlign.center,
                                )),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {},
                            )
                          ],
                        ),
                      ) : Container(height: 0, width: 0,),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0, bottom: 8.0),
                        child: ListTile(
                          title: Text("Zutaten"),
                          subtitle: Text(
                            "Eis, KEko, Argeta, Semmel, Senf, Soße, Bohnen, weiße Bohnen, Kekomat, Zwiebel",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {},
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
              );
            },
          ) : ShoppyShimmer(),
        ));
  }
}
