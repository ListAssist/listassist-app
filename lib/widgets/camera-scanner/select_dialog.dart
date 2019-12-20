import 'package:flutter/material.dart';
import 'package:listassist/models/PossibleItem.dart';

Future<List<PossibleItem>> showSelectDialog(BuildContext context, List<PossibleItem> detectedProducts) async {
  return showDialog<List<PossibleItem>>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        title: Text("Erkannte Produkte"),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return DataTable(
                    columns: [
                      DataColumn(label: Text("Produkt Name")),
                      DataColumn(label: Text("Preis")),
                    ],
                    rows: getRows(detectedProducts, setState),
                );
              },
            ),
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

List<DataRow> getRows(List<PossibleItem> detectedProducts, Function setState) {
  List<DataRow> rows = [];

  detectedProducts.forEach((item) => rows.add(DataRow(
    onSelectChanged: (value) => setState(() {
      item.selected = value;
    }),
    selected: item.selected,
    cells: [
      DataCell(
        Text(item.name.join(" "))
      ),
      DataCell(
        Text(item.price.toString())
      )
    ]
  )));

  return rows;
}
