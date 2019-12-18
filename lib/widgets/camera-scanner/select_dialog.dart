import 'package:flutter/material.dart';
import 'package:listassist/models/PossibleItem.dart';

Future<List<PossibleItem>> showSelectDialog(BuildContext context, List<PossibleItem> detectedProducts) async {
  return showDialog<List<PossibleItem>>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Erkannte Produkte"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: ListView.builder(
                  itemCount: detectedProducts.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                        child: CheckboxListTile(
                            value: detectedProducts[index].selected,
                            title: Text("${detectedProducts[index].name.join(" ")} für ${detectedProducts[index].price}€"),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool val) {
                              setState(() {
                                detectedProducts[index].selected = !detectedProducts[index].selected;
                              });
                            }
                        )
                    );
                  }
              ),
            );
          },
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
            child: Text("Akzeptieren"),
            onPressed: () {
                Navigator.of(context).pop(detectedProducts.where((product) => product.selected == true).toList());
            },
          ),
        ],
      );
    },
  );
}