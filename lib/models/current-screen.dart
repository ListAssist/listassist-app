import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ScreenModel extends Model {
  int _index = 0;

  int get index => _index;

  void setIndex(int id) {
    // First, increment the counter
    _index = id;

    // Then notify all the listeners.
    notifyListeners();
  }

  static ScreenModel of(BuildContext context) => ScopedModel.of<ScreenModel>(context);
}