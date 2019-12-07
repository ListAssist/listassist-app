import 'package:carousel_slider/carousel_slider.dart';
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
  int _current = 0;

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

    CarouselSlider slider = CarouselSlider(
      onPageChanged: (index) {
        setState(() {
          _current = index;
        });
      },
      enableInfiniteScroll: false,
      height: MediaQuery.of(context).size.height / 100 * 70,
      items: urls != null ? urls.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Image(image: NetworkImage(i)),
                onTap: () {
                    //TODO: Show recognized products and prices
                    print(i);
                  },
              )
            );
          },
        );
      }).toList() : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Rechnungen von ${list.name}"),
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

