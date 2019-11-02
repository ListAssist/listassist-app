import 'package:flutter/material.dart';
import 'package:listassist/widgets/shoppinglist-view.dart';
import 'package:scoped_model/scoped_model.dart';

class ScreenModel extends Model {
  Widget _screen = ShoppingListView();

  Widget get screen => _screen;

  void setScreen(Widget newScreen) {
    _screen = newScreen;

    notifyListeners();
  }

  static ScreenModel of(BuildContext context) => ScopedModel.of<ScreenModel>(context);
}