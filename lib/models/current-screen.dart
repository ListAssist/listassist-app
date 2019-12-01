import 'package:custom_navigator/custom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shoppinglist/shopping_list_view.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

class ScreenModel extends Model {

  Widget _screen = FirstView();

  Widget get screen => _screen;

  void setScreen(Widget newScreen) {
    _screen = newScreen;

    notifyListeners();
  }

  static ScreenModel of(BuildContext context) => ScopedModel.of<ScreenModel>(context);
}

class FirstView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return MultiProvider(
      providers: [
        StreamProvider.value(value: databaseService.streamLists(user.uid)),
        StreamProvider.value(value: databaseService.streamListsHistory(user.uid))
      ],
      child: CustomNavigator(
        home: ShoppingListView(),
        pageRoute: PageRoutes.materialPageRoute,
      )
    );
  }
}
