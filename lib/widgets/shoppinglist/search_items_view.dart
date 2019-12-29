import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/Product.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/item_counter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'add_shopping_list.dart';

class SearchItemsView extends StatefulWidget {
  final String listId;

  SearchItemsView(this.listId);

  @override
  _SearchItemsView createState() => _SearchItemsView();
}

class _SearchItemsView extends State<SearchItemsView> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TextEditingController _searchController = TextEditingController();
  LocalStorage _storage = new LocalStorage("popular_products.json");

  User _user;
  ShoppingList _list;

  Algolia algolia = Application.algolia;
  bool _searching = false;

  Timer _debounce;
  int _debounceTime = 2000;

  List<dynamic> _products = [];
  List<Product> _popularProducts = [];

  List<Product> _recentProducts = [];
  bool initialized = false;

  _searchProducts(String search) async {
    _searching = true;
    setState(() {});
    AlgoliaQuery query = algolia.instance.index('products').search(search);

    AlgoliaQuerySnapshot snap = await query.getObjects();
    List<dynamic> hits = List<dynamic>();
    snap.hits.forEach((h) => {print(h.data), hits.add(h.data)});
    _searching = false;
    setState(() {});
    return hits;
  }

  _addItem(Product product) {
    _list.addItem(product.name);
    _addToRecentProducts(product);
    setState(() {});
    _requestListUpdate();
  }

  _addCount(String itemName) {
    _list.changeItemCount(itemName, 1);
    setState(() {});
    _requestListUpdate();
  }

  _subtractCount(String itemName) {
    if (_list.getItemCount(itemName) == 1) {
      _list.removeItem(itemName);
      setState(() {});
      _requestListUpdate();
    } else {
      _list.changeItemCount(itemName, -1);
      setState(() {});
      _requestListUpdate();
    }
  }

  // Updated mit Debounce die Einkaufsliste in der Datenbank
  _requestListUpdate() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (_list != null && _user.uid != null || _user.uid.length > 0) {
        databaseService.updateList(_user.uid, _list).then((value) => {print("Liste wurde erfolgreich upgedated")}).catchError((_) => {print(_.toString())});
      }
    });
  }

  _subtractCountUserInput() {
    if (_list.getItemCount(_searchController.text) == 1) {
      databaseService.removeItemFromList(_user.uid, widget.listId, _searchController.text);
    } else {
      databaseService.changeItemCount(_user.uid, widget.listId, _searchController.text, -1);
    }
  }

  _addToRecentProducts(Product product) {
    _recentProducts.removeWhere((p) => p.name == product.name);
    _recentProducts.length >= 10 ? _recentProducts.removeLast() : {};
    _recentProducts.insert(0, product);
    _storage.setItem(
        'list',
        _recentProducts.map((product) {
          return product.toJson();
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
    List lists = Provider.of<List<ShoppingList>>(context);
    int index = lists.indexWhere((e) => e.id == widget.listId);
    _list = lists[index];

    print(_list.name);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          key: _scaffoldKey,
          floatingActionButton: FloatingActionButton(child: Icon(Icons.check), onPressed: (){Navigator.pop(context);}, backgroundColor: Colors.green,),
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
                                  if (text.length == 0) {
                                    return;
                                  }
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
                        FutureBuilder(
                            future: _storage.ready,
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return ShoppyShimmer();
                              }

                              _recentProducts = (_storage.getItem("list") ?? []).map((product) {
                                return new Product(name: product["name"], category: product["category"]);
                              }).cast<Product>().toList();

                              if (_recentProducts.isNotEmpty != null) {
                                return MediaQuery.removePadding(
                                    removeTop: true,
                                    context: context,
                                    child: ListView.separated(
                                      itemCount: _recentProducts.length,
                                      separatorBuilder: (ctx, i) => Divider(
                                        indent: 70,
                                        endIndent: 10,
                                        color: Colors.grey,
                                      ),
                                      itemBuilder: (context, index) {
                                        _subtract() {
                                          _subtractCount(_recentProducts[index].name);
                                        }
                                        int count;
                                        if (_list.hasItem(_recentProducts[index].name)) {
                                          count = _list.items.firstWhere((i) => i.name == _recentProducts[index].name).count;
                                        }
                                        return Container(
                                          height: 60,
                                          child: ListTile(
                                            leading: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.local_dining),
                                            ),
                                            title: Text(_recentProducts[index].name),
                                            subtitle: Text(_recentProducts[index].category),
                                            trailing: _list.hasItem(_recentProducts[index].name)
                                                ? ItemCounter(count: count, subtractCount: _subtract)
                                                : Container(
                                              width: 0,
                                              height: 0,
                                            ),
                                            onTap: () {
                                              if (!_list.hasItem(_recentProducts[index].name)) {
                                                _addItem(new Product(name: _recentProducts[index].name, category: _recentProducts[index].category));
                                              } else {
                                                _addCount(_recentProducts[index].name);
                                              }
                                            }
                                          ),
                                        );
                                      },
                                    ));
                              }

                              return FutureBuilder(
                                  future: databaseService.getPopularProducts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return ShoppyShimmer();
                                    }

                                    return MediaQuery.removePadding(
                                        removeTop: true,
                                        context: context,
                                        child: ListView.separated(
                                          itemCount: snapshot.data.length,
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
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.local_dining),
                                                ),
                                                title: Text(snapshot.data[index].name),
                                                subtitle: Text(snapshot.data[index].category),
                                              ),
                                            );
                                          },
                                        ));
                                  });
                            }),
                        FutureBuilder(
                            future: databaseService.getPopularProducts(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return ShoppyShimmer();
                              }

                              return MediaQuery.removePadding(
                                  removeTop: true,
                                  context: context,
                                  child: ListView.separated(
                                    itemCount: snapshot.data.length,
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
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.local_dining),
                                          ),
                                          title: Text(snapshot.data[index].name),
                                          subtitle: Text(snapshot.data[index].category),
                                        ),
                                      );
                                    },
                                  ));
                            }),
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
                                    // length + 1, weil noch ein Listtile erstellt wird mit der Eingabe vom Benutzer
                                    itemCount: _products.length + 1,
                                    separatorBuilder: (ctx, i) => Divider(
                                      indent: 70,
                                      endIndent: 10,
                                      color: Colors.grey,
                                    ),
                                    itemBuilder: (context, index) {
                                      _subtract() {
                                        index > 0 ? _subtractCount(_products[index - 1]["name"]) : _subtractCount(_searchController.text);
                                      }

                                      int count;
                                      if (index == 0) {
                                        if (_list.hasItem(_searchController.text)) {
                                          count = _list.items.firstWhere((i) => i.name == _searchController.text).count;
                                        }
                                      } else {
                                        if (_list.hasItem(_products[index - 1]["name"])) {
                                          count = _list.items.firstWhere((i) => i.name == _products[index - 1]["name"]).count;
                                        }
                                      }

                                      if (index == 0) {
                                        return Container(
                                          height: 60,
                                          child: ListTile(
                                            leading: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.local_dining, color: _list.hasItem(_searchController.text) ? Theme.of(context).primaryColor : null),
                                            ),
                                            title: Text(_searchController.text),
                                            subtitle: Text("Kategorie"),
                                            trailing: _list.hasItem(_searchController.text)
                                                ? ItemCounter(count: count, subtractCount: _subtract)
                                                : Container(
                                                    width: 0,
                                                    height: 0,
                                                  ),
                                            onTap: () {
                                              if (!_list.hasItem(_searchController.text)) {
                                                _addItem(new Product(name: _searchController.text, category: "Selbst erstellt"));
                                              } else {
                                                _addCount(_searchController.text);
                                              }
                                            },
                                          ),
                                        );
                                      }

                                      return Container(
                                        height: 60,
                                        child: ListTile(
                                          leading: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.local_dining, color: _list.hasItem(_products[index - 1]["name"]) ? Theme.of(context).primaryColor : null),
                                          ),
                                          title: Text(_products[index - 1]["name"]),
                                          subtitle: Text(_products[index - 1]["category"]),
                                          trailing: _list.hasItem(_products[index - 1]["name"])
                                              ? ItemCounter(count: count, subtractCount: _subtract)
                                              : Container(
                                                  width: 0,
                                                  height: 0,
                                                ),
                                          onTap: () {
                                            if (!_list.hasItem(_products[index - 1]["name"])) {
                                              _addItem(new Product(name: _products[index - 1]["name"], category: _products[index - 1]["category"]));
                                            } else {
                                              _addCount(_products[index - 1]["name"]);
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  )
                                : Column(
                                    children: <Widget>[
                                      Container(
                                        height: 60,
                                        child: ListTile(
                                          leading: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.local_dining, color: _list.hasItem(_searchController.text) ? Theme.of(context).primaryColor : null),
                                          ),
                                          title: Text(_searchController.text),
                                          subtitle: Text("Kategorie"),
                                          trailing: _list.hasItem(_searchController.text)
                                              ? ItemCounter(
                                                  count: _list.items.firstWhere((i) => i.name == _searchController.text).count,
                                                  subtractCount: _subtractCountUserInput,
                                                )
                                              : Container(
                                                  width: 0,
                                                  height: 0,
                                                ),
                                          onTap: () {
                                            if (!_list.hasItem(_searchController.text)) {
                                              _addItem(new Product(name: _searchController.text, category: "Selbst erstellt"));
                                            } else {
                                              _addCount(_searchController.text);
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 50.0, bottom: 15.0),
                                        child: Icon(
                                          Icons.sentiment_dissatisfied,
                                          size: 50,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        "Keine Produkte gefunden",
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  )
                            : ShoppyShimmer()),
                  )
          ])),
    );
  }
}
