import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/Product.dart';
import 'package:listassist/models/ShoppingList.dart';
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

class _StatisticsView extends State<StatisticsView> {
  @override
  Widget build(BuildContext context) {
    List<ShoppingList> lists = Provider.of<List<ShoppingList>>(context);
    return Scaffold(
        appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text("Statistiken"),
      leading: IconButton(
        icon: Icon(Icons.menu),
        tooltip: "Open navigation menu",
        onPressed: () => mainScaffoldKey.currentState.openDrawer(),
      ),
    ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "Meistgekaufte Produkte",
              style: TextStyle(
                fontSize: 18
            ),),
          ),
          lists != null ? Container(
            height: 250,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            //width: MediaQuery.of(context).size.width/1.5,
            child: BarChart(_getMostBoughtProductData(lists), animate: true,),
          ) : ShoppyShimmer(),
          Divider(),
          Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 10),
            child: Text(
              "Ausgaben pro Kategorie",
              style: TextStyle(
                  fontSize: 18
              ),),
          ),
          Container(
            height: 300,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: DonutPieChart(_getMoneyPerCategoryData(lists), animate: true,),
          )
        ],
      )



    );
  }

  List<charts.Series<Item, String>> _getMostBoughtProductData(List<ShoppingList> lists){
    List<Item> items = [new Item(name:"kekomat", count: 2, bought: true)];
    lists.forEach((shoppingList) {
      for(var i = 0; i < shoppingList.items.length; i++){
        for(var j = 0; j < items.length; j++) {
          print(shoppingList.items[i].name + items[j].name);
          if(shoppingList.items[i].name == items[j].name){
            //Wenn dieses Item bereits in items ist
            print(i.toString() + " Hab " + shoppingList.items[i].name + " " + shoppingList.items[i].count.toString() + " mal hinzugefügt " + j.toString());
            items[j].count += shoppingList.items[i].count;
          }
          if (j == items.length-1) {
            //Wenn dieses Item noch nicht in items ist
            print(i.toString() + " Hab " + shoppingList.items[i].name + " " + shoppingList.items[i].count.toString() + " mal neu hinzugefügt " + j.toString());
            items.add(new Item(name: shoppingList.items[i].name, count: shoppingList.items[i].count, bought: true));
            break;
          }
        }
      }
    });

    items.sort((a, b) => b.count - a.count);
    items.forEach((i) => print(i.name + "  " + i.count.toString()));
    items = items.sublist(0, 3);

    return [
      new charts.Series<Item, String>(
        id: 'Items',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Item item, _) => item.name,
        measureFn: (Item item, _) => item.count,
        data: items,
        labelAccessorFn: (Item item, _) => item.count.toString()
      )
    ];
  }

  List<charts.Series<CategoryMoney, String>> _getMoneyPerCategoryData(List<ShoppingList> lists) {

    List<CategoryMoney> data = [new CategoryMoney("kekomat", 0.5)];
    lists.forEach((shoppingList) {
      for(var i = 0; i < shoppingList.items.length; i++){
        for(var j = 0; j < data.length; j++) {
          if(shoppingList.items[i].prize == null) break;
          //print(shoppingList.items[i].category + data[j].category);
          if(shoppingList.items[i].category == data[j].category){
            //Wenn diese Kategorie bereits in data ist
            print(i.toString() + " Hab " + shoppingList.items[i].category + " " + shoppingList.items[i].count.toString() + " mal hinzugefügt " + j.toString());
            data[j].value += shoppingList.items[i].prize;
            break;
          }
          if (j == data.length-1) {
            //Wenn dieses Item noch nicht in items ist
            print(i.toString() + " Hab " + shoppingList.items[i].category + " " + shoppingList.items[i].count.toString() + " mal neu hinzugefügt " + j.toString());
            data.add(new CategoryMoney(shoppingList.items[i].category, shoppingList.items[i].prize));
            break;
          }
        }
      }
    });
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

class CategoryMoney {
  final String category;
  double value;

  CategoryMoney(this.category, this.value);
}
