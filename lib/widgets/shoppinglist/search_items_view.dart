import 'package:algolia/algolia.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  List<dynamic> _products = [];

  _searchProducts(String search) async {
    AlgoliaQuery query = algolia.instance.index('products').search(search);

    AlgoliaQuerySnapshot snap = await query.getObjects();
    //print(snap.hits[0].data);
    List<dynamic> hits = List<dynamic>();
    snap.hits.forEach((h) => {print(h.data), hits.add(h.data)});
    return hits;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          key: _scaffoldKey,
//        appBar: AppBar(
//          leading: Container(),
//          bottom:
//            TabBar(
//              tabs: [
//                Tab(text: "Zu erledigen",),
//                Tab(text: "Erledigt")
//              ],
//            ),
//        ),
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
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(45.0),
                            color: Colors.white),
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
                                  _products = await _searchProducts(text);
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Produkt Suchen",
                                    contentPadding: EdgeInsets.all(17)),
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
                      tabs: [
                        Tab(text: "Zuletzt"),
                        Tab(text: "Beliebt"),
                        Tab(text: "Kategorien")
                      ],
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
                      child: ListView.separated(
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
                      ),
                    ),
                  )
          ])),
    );
  }
}
