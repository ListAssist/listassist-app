import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/Product.dart';
import 'package:listassist/models/Recipe.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/recipe/create_recipe_view.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view_new.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeView createState() => _RecipeView();
}

class _RecipeView extends State<RecipeView> {

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes = Provider.of<List<Recipe>>(context);
    User user = Provider.of<User>(context);
    return Scaffold(
        //backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRecipeView()));
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
          child: recipes != null
              ? recipes.length == 0
                  ? Center(
                      child: Text(
                      "Noch keine Rezepte erstellt",
                      style: Theme.of(context).textTheme.title,
                    ))
                  : ListView.builder(
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
                                recipes[index].description != null
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 5, left: 15.0, right: 15.0, bottom: 5),
                                        child: Container(
                                            width: 250,
                                            child: Text(
                                              recipes[index].description,
                                              //softWrap: true,
                                              textAlign: TextAlign.center,
                                            )),
                                      )
                                    : Container(
                                        height: 0,
                                        width: 0,
                                      ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 8.0),
                                  child: ListTile(
                                    title: Text(
                                      "Zutaten",
                                      style: TextStyle(
                                        color: recipes[index].items.length > 0 ? Colors.black : Colors.red,
                                      ),
                                    ),
                                    subtitle: Text(
                                      recipes[index].items.length > 0 ? getItemsAsString(recipes[index].items) : "Keine Zutaten hinzugefügt",
                                      style: TextStyle(
                                        color: recipes[index].items.length > 0 ? Colors.grey : Colors.red,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: recipes[index].items.length > 0 ? null : Colors.red,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SearchItemsViewNew(
                                                    recipe: recipes[index],
                                                  )));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        color: Colors.blueGrey,
                                        onPressed: () {
                                          _showEditDialog(recipes[index]);
                                        },
                                      ),
                                      FloatingActionButton.extended(
                                        icon: Icon(Icons.check),
                                        label: Text("Liste erstellen"),
                                        backgroundColor: recipes[index].items.length > 0 ? Colors.green : Colors.grey,
                                        onPressed: recipes[index].items.length > 0
                                            ? () async {
                                                await databaseService.createList(
                                                    user.uid, new ShoppingList(created: Timestamp.now(), name: "Rezept: ${recipes[index].name}", items: recipes[index].items, type: "pending"));
                                                InfoOverlay.showInfoSnackBar("Einkaufsliste für ${recipes[index].name} erstellt");
                                              }
                                            : null,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () {
                                          _showDeleteDialog(recipes[index]);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
              : ShoppyShimmer(),
        ));
  }

  String getItemsAsString(List<Item> items) {
    String erg = "";
    items.forEach((i) => erg += ", " + i.name);
    return erg.substring(2);
  }

  _showEditDialog(Recipe recipe) {
    _nameController.text = recipe.name;
    _descriptionController.text = recipe.description;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Rezept bearbeiten"),
            content: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      //counterText: "Name",
                      hintText: 'Name',
                      //errorText: _errorText.isNotEmpty ? _errorText : null,
                      //icon: Icon(Icons.book),
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: "Beschreibung",
                      //counterText: "Beschreibung",
                      hintText: 'Beschreibung',

                      //errorText: _errorText.isNotEmpty ? _errorText : null,
                      //icon: Icon(Icons.description),
                    ),
                  ),

                  /*ProgressButton(
                    child: Text("Speichern"),
                    onPressed: (AnimationController animation) {
                    },
                  )*/
                ],
              ),
            ),
          );
        });
  }

  Future<void> _showDeleteDialog(Recipe recipe) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rezept löschen"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                    text: TextSpan(
                        style: new TextStyle(
                          color: Theme.of(context).textTheme.title.color,
                        ),
                        children: <TextSpan>[
                      TextSpan(text: "Sind Sie sicher, dass Sie das Rezept "),
                      TextSpan(text: "${recipe.name}", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " löschen möchten?")
                    ]))
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Löschen"),
              onPressed: () {
                print(recipe.id);
                String name = recipe.name;
                databaseService.deleteRecipe(Provider.of<User>(context).uid, recipe.id).catchError((_) {
                  InfoOverlay.showErrorSnackBar("Fehler beim Löschen des Rezepts");
                }).then((_) {
                  InfoOverlay.showInfoSnackBar("Rezept $name gelöscht");
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
