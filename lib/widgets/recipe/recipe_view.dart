import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/Recipe.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/recipe/create_recipe_view.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view_new.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeView createState() => _RecipeView();
}

class _RecipeView extends State<RecipeView> {
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  ProgressDialog progressDialog;

  @override
  void initState() {
    _nameController = new TextEditingController();
    _descriptionController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes = Provider.of<List<Recipe>>(context);
    User user = Provider.of<User>(context);
    return Scaffold(
        //backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: user.settings["theme"] == "Grün" ? CustomColors.shoppyGreen : Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRecipeView()));
          },
        ),
        appBar: AppBar(
          backgroundColor: user.settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
          title: Text("Rezepte"),
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
                              title: Row(
                                children: <Widget>[
                                  Text(
                                    recipes[index].name,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  recipes[index].items.length > 0
                                      ? Container()
                                      : Icon(
                                          Icons.warning,
                                          color: Colors.red,
                                        )
                                ],
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
                                          _showEditDialog(user, recipes[index]);
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

  _showEditDialog(User user, Recipe recipe) async {
    _nameController.text = recipe.name;
    _descriptionController.text = recipe.description;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Rezept bearbeiten"),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: 'Name',
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
//                    maxLength: 100,
//                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      labelText: "Beschreibung",
                      //counterText: "Beschreibung",
                      hintText: 'Beschreibung',
                      //errorText: _errorText.isNotEmpty ? _errorText : null,
                      //icon: Icon(Icons.description),
                    ),
                  ),
                  RaisedButton(
                    child: Text("Speichern"),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () async {
                      progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
                      progressDialog.style(
                          message: "Rezept wird aktualisiert...",
                          borderRadius: 10.0,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
                          progressWidget: SpinKitDoubleBounce(
                            color: Colors.blue,
                          ),
                          elevation: 10.0,
                          insetAnimCurve: Curves.easeInOut,
                          progress: 0.0,
                          maxProgress: 100.0,
                          progressTextStyle: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
                          messageTextStyle: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600));
                      progressDialog.show();
                      recipe.name = _nameController.text;
                      recipe.description = _descriptionController.text;
                      await databaseService
                          .updateRecipe(user.uid, recipe)
                          .then((_) => {
                            Navigator.pop(context),
                            InfoOverlay.showInfoSnackBar("Rezept " + recipe.name + " gelöscht"),
                            progressDialog.hide()
                          })
                          .catchError((_) => {
                            InfoOverlay.showErrorSnackBar("Fehler beim aktualisieren des Rezepts"),
                            progressDialog.dismiss()
                          });
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _showDeleteDialog(Recipe recipe) async {
    return showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
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
                progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
                progressDialog.style(
                    message: "Rezept wird gelöscht...",
                    borderRadius: 10.0,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
                    progressWidget: SpinKitDoubleBounce(
                      color: Colors.blue,
                    ),
                    elevation: 10.0,
                    insetAnimCurve: Curves.easeInOut,
                    progress: 0.0,
                    maxProgress: 100.0,
                    progressTextStyle: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
                    messageTextStyle: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600));
                progressDialog.show();
                print(recipe.id);
                String name = recipe.name;
                databaseService.deleteRecipe(Provider.of<User>(context).uid, recipe.id).catchError((_) {
                  InfoOverlay.showErrorSnackBar("Fehler beim Löschen des Rezepts");
                  progressDialog.hide();
                }).then((_) {
                  progressDialog.dismiss();
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
