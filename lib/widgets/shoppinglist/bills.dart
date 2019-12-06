import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/services/storage.dart';
import 'package:provider/provider.dart';

class Bills extends StatefulWidget {
  final int index;
  Bills({this.index});

  @override
  _BillsState createState() => _BillsState();
}

class _BillsState extends State<Bills> {

  List<dynamic> urls;
  bool hasChanged = true;
  CompletedShoppingList list;

  @override
  Widget build(BuildContext context) {
    if(list != Provider.of<List<CompletedShoppingList>>(context)[widget.index]) {
      list = Provider.of<List<CompletedShoppingList>>(context)[widget.index];
      hasChanged = true;
    }
    if(hasChanged) {
      storageService.getImages(list.bills).then((val) {
        if (mounted) {
          print(val);
          setState(() {
            urls = val;
            hasChanged = false;
          });
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Rechnungen von ${list.name}"),
      ),
      body: urls != null ? ListView.builder(
        itemCount: urls.length,
        itemBuilder: (context, index) {
          return Container(
            height: 300,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Image(image: NetworkImage(urls[index]))
            ),
          );
        }
      ) : SpinKitDoubleBounce(color: Colors.blue),
    );
  }
}
