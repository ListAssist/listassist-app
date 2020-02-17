import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/ScannedShoppinglist.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/models/Recipe.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view_new.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:provider/provider.dart';

class CreateRecipeView extends StatefulWidget {
  @override
  _CreateRecipeView createState() => _CreateRecipeView();
}

class _CreateRecipeView extends State<CreateRecipeView> {
  List<ScannedShoppingList> scannedLists = [];

  bool buttonDisabled = false;

  @override
  Widget build(BuildContext context) {
    Color _backgroundColor = Colors.blueAccent;

    User _user = Provider.of<User>(context);
    List<Recipe> recipes = Provider.of<List<Recipe>>(context);

    RegExp defaultListName = new RegExp(r"Einkaufsliste #[0-9]+");

    TextEditingController _nameController = new TextEditingController();
    TextEditingController _descriptionController = new TextEditingController();

    Random rng = new Random();
    int colorNumber = rng.nextInt(3);

    List<Color> _backgroundColors = [
      Colors.blueAccent,
      Colors.deepOrange,
      Colors.green
    ];
    List<Color> _buttonColors = [
      Colors.blueAccent,
      Colors.deepOrangeAccent,
      Colors.lightGreen
    ];

    _backgroundColor = _backgroundColors[colorNumber];


    return Scaffold(
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    color: _backgroundColor,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                  ),
                  Container(
                    height: 220,
                    margin: EdgeInsets.only(left: 20, right: 20, top: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 190,
                    right: 40,
                    height: 40,
                    child: Container(
                      width: 140,
                      height: 40,
                      child: ProgressButton(
                        child: Text(
                          "Rezept erstellen",
                          style: TextStyle(color: Colors.white),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        //color: Theme.of(context).primaryColor,
                        color: _buttonColors[colorNumber],
                        progressIndicatorColor: Colors.white,
                        progressIndicatorSize: 20,
                        onPressed: (AnimationController controller) async {
                          controller.forward();
                          bool connected = await connectivityService.testInternetConnection();
                          if (!connected) {
                            //I am NOT connected
                            controller.reverse();
                            InfoOverlay.showErrorSnackBar("Keine Internetverbindung");
                          } else if (!buttonDisabled && _nameController.text.length > 0) {
                            //I am connected to the Internet

                            buttonDisabled = true;

                            String name = _nameController.text;
                            String description = _descriptionController.text;
                            Recipe _newRecipe = new Recipe(
                              name: name,
                              description: description,
                              items: new List(),
                            );

                            DocumentReference docRef = await databaseService.createRecipe(_user.uid, _newRecipe);
                            controller.reverse();
                            Navigator.pop(context);

                            /*print("DOCREFFFF  " + docRef.documentID);
                            lists.forEach((l) => {
                              print(l.id)
                            });*/

                            //Navigator.push(context, MaterialPageRoute(builder: (context) => SearchItemsView(docRef.documentID)));

/*
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShoppingListDetail(index: lists.indexWhere((l) => l.id == docRef.))));
                                    */

                            Recipe _newRecipeWithNewID = new Recipe(
                              id: docRef.documentID,
                              name: _newRecipe.name,
                              description: _newRecipe.description,
                              items: _newRecipe.items
                            );
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SearchItemsViewNew(recipe: _newRecipeWithNewID,)));
                          } else {
                            controller.reverse();
                            InfoOverlay.showErrorSnackBar("Bitte gib einen Namen ein");
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: EdgeInsets.only(top: 10, left: 50.0, right: 50.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.0), color: Colors.white),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(border: UnderlineInputBorder(), hintText: "Name", contentPadding: EdgeInsets.only(top: 17, left: 5, right: 17, bottom: 10)),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 15),
                              child: TextField(
                                controller: _descriptionController,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(border: UnderlineInputBorder(), hintText: "Beschreibung", contentPadding: EdgeInsets.only(top: 17, left: 5, right: 17, bottom: 10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          /*Expanded(
            child: Container(
              color: _backgroundColor,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Stack(children: []),
            ),
          )*/
        ]));
  }
}
