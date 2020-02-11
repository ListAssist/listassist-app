import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/services/date_formatter.dart';
import 'package:photo_view/photo_view.dart';

class BillDetails extends StatefulWidget {
  final StorageReference image;
  final String imageurl;
  BillDetails({this.image, this.imageurl});

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  
  List<dynamic> detectedProducts;
  bool _loaded = false;
  DateTime scanned;

  @override
  Widget build(BuildContext context) {
    if(!_loaded) {
      widget.image.getMetadata().then((val) {
        detectedProducts = json.decode(val.customMetadata["list"] ?? "[]")["items"];
        scanned = DateTime.parse(json.decode(val.customMetadata["list"] ?? "[]")["scanned"]);
        setState(() => { _loaded = true});
      });
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Details"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.image)),
              Tab(icon: Icon(Icons.list))
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                child: ClipRect(
                  child: PhotoView(
                    backgroundDecoration: BoxDecoration(color: Colors.transparent),
                    initialScale: PhotoViewComputedScale.contained,
                    imageProvider: NetworkImage(widget.imageurl),
                  ),
                )
              ),
            ),
            !_loaded ? SpinKitCircle(color: Colors.blueAccent) :
            detectedProducts.length == 0 ? Center(child: Text("Keine Produkte erkannt", style: Theme.of(context).textTheme.title)) :
            ListView.builder(
              itemCount: detectedProducts.length + 1,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: ListTile(
                    title: Text(index == 0 ? "Gescannt am ${DateFormatter.getDateAndTime(scanned)}" : detectedProducts[index - 1]["name"]),
                    trailing: index == 0 ? null : Text("${detectedProducts[index - 1]["price"]}".replaceAllMapped(RegExp("(-?\\d+).(\\d*)"), (match) {
                      return "${match.group(1)},${match.group(2).padRight(2, "0")}€";
                    })),
                  ),
                );
              },
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            )
          ],
        ),
      )
    );
  }
}
