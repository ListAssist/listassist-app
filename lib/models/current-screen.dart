import 'package:flutter/material.dart';
import 'package:listassist/widgets/shoppinglist-view.dart';
import 'package:scoped_model/scoped_model.dart';

class ScreenModel extends Model {
  Widget _screen = ShoppingListView();

  Widget get screen => _screen;

  String _title = "Einkaufslisten";

  String get title => _title;

  void setScreen(Widget newScreen, String title) {
    _screen = newScreen;
    _title = title;

    notifyListeners();
  }

  static ScreenModel of(BuildContext context) => ScopedModel.of<ScreenModel>(context);
}