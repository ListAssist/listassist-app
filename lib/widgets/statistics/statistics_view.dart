import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/Product.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/statistics/bar_chart.dart';
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
            padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
            child: Text(
              "Meistgekaufte Produkte",
              style: TextStyle(
                fontSize: 18
            ),),
          ),
          lists != null ? Container(
            height: 300,
            //width: MediaQuery.of(context).size.width/1.5,
            child: BarChart(_getMostBoughtProductData(lists), animate: true,),
          ) : ShoppyShimmer(),
        ],
      )



    );
  }

  List<charts.Series<Item, String>> _getMostBoughtProductData(List<ShoppingList> lists){
    List<Item> items = [new Item(name:"kekomat", count: 2, bought: true)];
    bool contains = false;
    lists.forEach((shoppingList) => {
      for(var i = 0; i < shoppingList.items.length; i++){
        contains = false,
        for(var j = 0; j < items.length; j++) {
          if(shoppingList.items[i].name == items[j].name){
            //Wenn dieses Item bereits in items ist
            items[j].count += shoppingList.items[i].count,
            contains = true
          },
          if (j == items.length-1 && !contains) {
            //Wenn dieses Item noch nicht in items ist
            items.add(new Item(name: shoppingList.items[i].name, count: shoppingList.items[i].count, bought: true))
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
}
