import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/storage.dart';
import 'package:listassist/widgets/shoppinglist/bill_details.dart';
import 'package:provider/provider.dart';

class Bills extends StatefulWidget {
  final int index;
  Bills({this.index});

  @override
  _BillsState createState() => _BillsState();
}

class _BillsState extends State<Bills> {

  List<dynamic> urls;
  List<StorageReference> images;
  bool hasChanged = false;
  CompletedShoppingList list;
  int _current = 0;

  //FIXME: The getter 'length' was called on null. when opening bills

  @override
  Widget build(BuildContext context) {
    if(list != Provider.of<List<CompletedShoppingList>>(context)[widget.index]) {
      list = Provider.of<List<CompletedShoppingList>>(context)[widget.index];
      images = storageService.getImages(list.bills);
      hasChanged = true;
    }
    if(hasChanged) {
      Future.wait(images.map((im) => im.getDownloadURL())).then((val) {
        if (mounted) {
          print(val);
          setState(() {
            urls = val;
            hasChanged = false;
          });
        }
      });
    }

    CarouselSlider slider = CarouselSlider(
      onPageChanged: (index) {
        setState(() {
          _current = index;
        });
      },
      enableInfiniteScroll: false,
      height: MediaQuery.of(context).size.height / 100 * 70,
      items: urls != null ? urls.asMap().map((i, url) {
          return MapEntry(i,
            Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Image(image: NetworkImage(url)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BillDetails(image: images[i], imageurl: url)));
                    print(i);
                  },
                )
            )
          );
      }).values.toList() : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Rechnungen von ${list.name}"),
        backgroundColor: Provider.of<User>(context).settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
        flexibleSpace: Provider.of<User>(context).settings["theme"] == "Verlauf" ? Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: <Color>[
                      CustomColors.shoppyBlue,
                      CustomColors.shoppyLightBlue,
                    ])
            )) : Container(),
      ),
      body: urls != null ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Für Details Bild anklicken"),
          Stack(
            children: <Widget>[
              slider,
              Container(
                height: MediaQuery.of(context).size.height / 100 * 70,
                child: Center(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        color: _current == 0 ? Color.fromRGBO(0, 0, 0, 0.4) : Colors.black,
                        onPressed: _current != 0 ? () => slider.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease) : null,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        color: _current == urls.length - 1 ? Color.fromRGBO(0, 0, 0, 0.4) : Colors.black,
                        onPressed: _current != urls.length - 1 ? () => slider.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease) : null,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(urls, (index, _) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4)
                ),
              );
            }).toList(),
          )
        ],
      ) : SpinKitDoubleBounce(color: Colors.blue),
    );
  }
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

