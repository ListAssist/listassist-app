import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BillDetails extends StatefulWidget {
  final StorageReference image;
  BillDetails({this.image});

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  
  List<dynamic> detectedProducts;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    if(!_loaded) {
      widget.image.getMetadata().then((val) {
        print(val.customMetadata["detected_products"]);
        //TODO: Replace with actual metadata
        detectedProducts = [
          {"name": "Milchlaible", "price": 2.59},
          {"name": "Lieblingsartike]", "price": -0.65},
          {"name": "Clever Sauerrahm", "price": 0.59},
          {"name": "Frankfurter er", "price": 2.99},
          {"name": "Lieblingsartike]", "price": -0.75},
          {"name": "BLÜTENHONIG G", "price": 6.99},
          {"name": "Lieblingsartikel", "price": -1.75},
          {"name": "Detk Torte Wr Art", "price": 2.99},
          {"name": "Lieblingsartikel", "price": -0.75},
          {"name": "Maltesers Maxi", "price": 4.49},
          {"name": "*HITPARADE", "price": -0.8},
          {"name": "Perfect Fit Sensitiv", "price": 4.49},
          {"name": "AKTIONSNACHLASS", "price": -1.3},
          {"name": "", "price": 0.0},
          {"name": "BILLA LIEBLINGSARTIK", "price": 0.0}
        ];
        setState(() => { _loaded = true});
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Details"),
        ),
        body: !_loaded ? SpinKitCircle(color: Colors.blueAccent) :
        ListView.builder(
          itemCount: detectedProducts.length,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: ListTile(
                title: Text(detectedProducts[index]["name"]),
                trailing: Text("${detectedProducts[index]["price"]}".replaceAllMapped(RegExp("(-?\\d+).(\\d*)"), (match) {
                  return "${match.group(1)},${match.group(2).padRight(2, "0")}€";
                })),
              ),
            );
          }
        )
    );
  }
}
