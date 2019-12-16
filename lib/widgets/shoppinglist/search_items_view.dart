import 'package:algolia/algolia.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'add_shopping_list.dart';

class SearchItemsView extends StatefulWidget {
  final int listId;

  SearchItemsView({this.listId});

  @override
  _SearchItemsView createState() => _SearchItemsView();
}

class _SearchItemsView extends State<SearchItemsView> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TextEditingController _searchController = TextEditingController();

  Algolia algolia = Application.algolia;
  bool _searching = false;

  List<dynamic> _products = [];

  _searchProducts(String search) async {
    _searching = true;
    setState(() {});
    AlgoliaQuery query = algolia.instance.index('products').search(search);

    AlgoliaQuerySnapshot snap = await query.getObjects();
    //print(snap.hits[0].data);
    List<dynamic> hits = List<dynamic>();
    snap.hits.forEach((h) => {print(h.data), hits.add(h.data)});
    _searching = false;
    setState(() {});
    return hits;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          key: _scaffoldKey,
          body: Column(children: <Widget>[
            Container(
              height: 120.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                  ),
                  Positioned(
                    top: 50.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(45.0), color: Colors.white),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(fontSize: 20),
                                onChanged: (text) async {
                                  _products.clear();
                                  setState(() {});
                                  if(text.length == 0) {return;}
                                  _products = await _searchProducts(text);
                                  setState(() {});
                                },
                                decoration: InputDecoration(border: InputBorder.none, hintText: "Produkt Suchen", contentPadding: EdgeInsets.all(17)),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                print("your menu action here");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            _searchController.text.length == 0
                ? Container(
                    color: Theme.of(context).primaryColor,
                    child: TabBar(
                      indicatorColor: Colors.white,
                      tabs: [Tab(text: "Zuletzt"), Tab(text: "Beliebt"), Tab(text: "Kategorien")],
                    ),
                  )
                : Container(),
            _searchController.text.length == 0
                ? Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: ListView.separated(
                              itemCount: 10,
                              separatorBuilder: (ctx, i) => Divider(
                                indent: 70,
                                endIndent: 10,
                                color: Colors.grey,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 60,
                                  child: ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.local_dining),
                                    ),
                                    title: Text("Produkt"),
                                    subtitle: Text("Kategorie"),
                                  ),
                                );
                              },
                            )),
                        Text("kek2"),
                        Text("kek3")
                      ],
                    ),
                  )
                : Expanded(
                    child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: _searching == false
                            ? _products.length > 0
                                ? ListView.separated(
                                    itemCount: _products.length,
                                    separatorBuilder: (ctx, i) => Divider(
                                      indent: 70,
                                      endIndent: 10,
                                      color: Colors.grey,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        height: 60,
                                        child: ListTile(
                                          leading: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(Icons.local_dining),
                                          ),
                                          title: Text(_products[index]["name"]),
                                          subtitle: Text(_products[index]["category"]),
                                          onTap: () {},
                                        ),
                                      );
                                    },
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 15.0),
                                          child: Icon(Icons.sentiment_dissatisfied, size: 50),
                                        ),
                                        Text(
                                          "Keine Produkte gefunden",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                            : Shimmer.fromColors(
                                baseColor: Colors.grey[300],
                                highlightColor: Colors.grey[100],
                                enabled: true,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [0, 1, 2, 3]
                                        .map((_) => Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 48.0,
                                                    height: 48.0,
                                                    color: Colors.white,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width: double.infinity,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                        ),
                                                        Container(
                                                          width: double.infinity,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                        ),
                                                        Container(
                                                          width: 40.0,
                                                          height: 8.0,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              )),
                  )
          ])),
    );
  }
}
