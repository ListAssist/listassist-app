import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/statistics/bar_chart.dart';
import 'package:listassist/widgets/statistics/donut_pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../main.dart';

class StatisticsView extends StatefulWidget {
  @override
  _StatisticsView createState() => _StatisticsView();
}

//TODO: Statistiken Overflow bottom
//TODO: Launcher icon einbinden
//TODO: Screen falls noch nichts gekauft wurde

class _StatisticsView extends State<StatisticsView> {

  bool nothingBought = false;

  @override
  Widget build(BuildContext context) {
    List<ShoppingList> lists = Provider.of<List<ShoppingList>>(context);
    List<CompletedShoppingList> completedLists = Provider.of<List<CompletedShoppingList>>(context);
    User user = Provider.of<User>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: user.settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
          title: Text("Statistiken"),
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
            tooltip: "Open navigation menu",
            onPressed: () => mainScaffoldKey.currentState.openDrawer(),
          ),
        ),
        body: nothingBought ? SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "Meistgekaufte Produkte",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              lists != null
                  ? Container(
                      height: 250,
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      //width: MediaQuery.of(context).size.width/1.5,
                      child: BarChart(
                        _getMostBoughtProductData(lists, completedLists),
                        animate: true,
                      ),
                    )
                  : ShoppyShimmer(),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 10),
                child: Text(
                  "Ausgaben pro Kategorie",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              lists != null
                  ? Container(
                      height: 300,
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: DonutPieChart(
                        _getMoneyPerCategoryData(lists, completedLists),
                        animate: true,
                      ),
                    )
                  : Container(),
            ],
          ),
        ) : Center(child: Text("Noch keine Einkäufe abgeschlossen", style: Theme.of(context).textTheme.title,))
    );
  }

  List<charts.Series<Item, String>> _getMostBoughtProductData(List<ShoppingList> lists, List<CompletedShoppingList> completedLists) {
    Item helper = new Item(name: "kekomat", count: 2, bought: true);
    List<Item> items = [helper];
    lists.forEach((shoppingList) {
      for (var i = 0; i < shoppingList.items.length; i++) {
        if (shoppingList.items[i].bought == false) break;
        for (var j = 0; j < items.length; j++) {
          if (shoppingList.items[i].name == items[j].name) {
            //Wenn dieses Item bereits in items ist
            items[j].count += shoppingList.items[i].count;
            break;
          }
          if (j == items.length - 1) {
            //Wenn dieses Item noch nicht in items ist
            items.add(new Item(name: shoppingList.items[i].name, count: shoppingList.items[i].count, bought: true));
            break;
          }
        }
      }
    });

    completedLists.forEach((shoppingList) {
      for (var i = 0; i < shoppingList.completedItems.length; i++) {
        if (shoppingList.completedItems[i].bought == false) break;
        for (var j = 0; j < items.length; j++) {
          if (shoppingList.completedItems[i].name == items[j].name) {
            //Wenn dieses Item bereits in items ist
            items[j].count += shoppingList.completedItems[i].count;
            break;
          }
          if (j == items.length - 1) {
            //Wenn dieses Item noch nicht in items ist
            items.add(new Item(name: shoppingList.completedItems[i].name, count: shoppingList.completedItems[i].count, bought: true));
            break;
          }
        }
      }
    });
    items.remove(helper);

    if(items.length == 0) {
      setState(() {
        nothingBought = true;
      });
      return [];
    }

    items.sort((a, b) => b.count - a.count);
    if (items.length > 3) items = items.sublist(0, 3);

    return [
      new charts.Series<Item, String>(
          id: 'Items',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (Item item, _) => item.name,
          measureFn: (Item item, _) => item.count,
          data: items,
          labelAccessorFn: (Item item, _) => item.count.toString())
    ];
  }

  List<charts.Series<CategoryMoney, String>> _getMoneyPerCategoryData(List<ShoppingList> lists, List<CompletedShoppingList> completedLists) {
    CategoryMoney helper = new CategoryMoney("test", 100);
    List<CategoryMoney> data = [helper];
    if (lists == null || completedLists == null) {
      print("ist null");
      return null;
    } else {
      lists.forEach((shoppingList) {
        for (var i = 0; i < shoppingList.items.length; i++) {
          for (var j = 0; j < data.length; j++) {
            if(shoppingList.items[i].category == null) break;
            if (shoppingList.items[i].category == data[j].category && shoppingList.items[i].bought) {
              print(data[j].category.toString() + " ist gleich wie " + shoppingList.items[i].category.toString());
              data[j].value += shoppingList.items[i].price;
              break;
            }
            if (j == data.length - 1 && shoppingList.items[i].bought) {
              data.add(new CategoryMoney(shoppingList.items[i].category, shoppingList.items[i].price));
              break;
            }
          }
        }
      });

      completedLists.forEach((shoppingList) {
        print(shoppingList.name);
        for (var i = 0; i < shoppingList.completedItems.length; i++) {
          for (var j = 0; j < data.length; j++) {
            if (shoppingList.completedItems[i].category == data[j].category) {
              data[j].value += shoppingList.completedItems[i].price;
              break;
            }
            if (j == data.length - 1) {
              data.add(new CategoryMoney(shoppingList.completedItems[i].category, shoppingList.completedItems[i].price));
              break;
            }
          }
        }
      });
      data.remove(helper);

      //Sort funktioniert nur mit int, deswegen nicht b.value - a.value
      data.sort((a, b) {
        if (b.value - a.value == 0) {
          return 0;
        }
        return b.value > a.value ? 1 : -1;
      });

      //remove categories with 0€
      data.removeWhere((a) => a.value == 0);

      return [
        new charts.Series<CategoryMoney, String>(
          id: 'MoneyPerCategory',
          domainFn: (CategoryMoney categoryMoney, _) => categoryMoney.category,
          measureFn: (CategoryMoney categoryMoney, _) => categoryMoney.value,
          data: data,
          // Set a label accessor to control the text of the arc label.
          //labelAccessorFn: (CategoryMoney row, _) => '${row.year}',
          //colorFn: (_, __) => charts.MaterialPalette.red.,
        )
      ];
    }
  }
}

class CategoryMoney {
  final String category;
  double value;

  CategoryMoney(this.category, this.value);
}
