import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_math/extended_math.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:provider/provider.dart';

class AddShoppinglist extends StatefulWidget {
  @override
  _AddShoppinglist createState() => _AddShoppinglist();
}

class _AddShoppinglist extends State<AddShoppinglist> {

  User user;

  final _productTextController = TextEditingController();
  final _nameTextController = TextEditingController();

  bool _nameIsValid = false;
  bool _productsIsNotEmpty = true;
  bool _productIsValid = true;
  bool _listIsValid = false;

  var rng = new Random();

  var _products = [
    new Item(name: "Apfel", bought: false),
    new Item(name: "Kekse", bought: false),
    new Item(name: "Seife", bought: false),
    new Item(name: "Öl", bought: false)
  ];

  void itemChange(bool val, int index){
    setState(() {
      _products[index].bought = val;
    });
  }

  _addProduct(product) {
    _productsIsNotEmpty = true;
    _productIsValid = true;
    for(var i = 0; i < _products.length; i++){
      if(_products[i].name == product){
        _productIsValid = false;
        return;
      }
    }
    if(_nameIsValid){
      _listIsValid = true;
    }

    setState(() {
      _productTextController.clear();
      _products.add(new Item(name: product, bought: false));
    });
  }

  _createShoppingList() {
      if(!_listIsValid) {
        return;
      }

      databaseService.createList(user.uid, ShoppingList(
        id: "",
        created: Timestamp.now(),
        name: _nameTextController.text,
        type: "pending",
        items: _products,
      ));

      Navigator.pop(context);
  }

  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameTextController.dispose();
    _productTextController.dispose();
    super.dispose();
  }



  List<String> daten = List.from({
    "Milk Protein Drink Choco Mountain",
    "Milk Protein Drink Coffee County",
    "Milk Protein Drink Vanilla Drive",
    "Milk Protein Drink Raspberry Falls",
    "Protein Pudding Choco Mountain",
    "Protein Pudding Vanilla Drive",
    "Milk Protein Drink Coco Island",
    "Milk Protein Drink Blueberry River",
    "Milk Protein Drink Mango Avenue",
    "Powergel Shot Cola",
    "Instant Hafer",
    "Performance Smoothie Banane-Heidelbeer",
    "Protein Plus High Protein Drink Schoko",
    "Protein Plus High Protein Drink Vanille",
    "FitRabbit Sportdrink",
    "Bod.e Burn",
    "Verve Energy Drink",
    "Vegan Blend natur",
    "Sport Isotonic Citrus Power",
    "Protein Plus Sports Fruicy Orange-Mango",
    "Body Fit Active L-Carnitine Apfelschorle",
    "L-Carnitin Liquid",
    "Mineral Vitamin Drink Orange",
    "Plus Kohlenhydratdrink",
    "Power Gel Fruit",
    "Powerade Mountain Blast",
    "Powerade Citrus Lime",
    "Gatorade div Sorten",
    "Professional Pyruvate Food Supplement",
    "Guarana Shot",
    "Protein Shake Schoko",
    "L-Carnitine Liquid",
    "L-Carnitine Water",
    "Body Cool + Form",
    "Magnesium Liquid",
    "Active Cool + Fit",
    "Energy Charge Drink",
    "Iso Drink Grapefruit-Lime",
    "Super Amino Liquid",
    "Red Kick",
    "Green Kick",
    "Muscle Amino Drink",
    "Isostar Hydrate & Perform Pulver Lemon",
    "55g High Protein Shake Schoko",
    "Creatin Monohydrat",
    "Fat Free Protein 85",
    "Hyperlyt Kirsche",
    "Anti- Oxidant Formula",
    "BCAA Kapseln",
    "Super Chitosan",
    "Kreatin-Monohydrat Pulver",
    "Vitalstoffkapseln für Knochen und Knorpel",
    "Perfect Body day",
    "Perfect Body night",
    "PEP 2",
    "Body L-Carnitine Drops",
    "Shake & Shape Weiße Schokolade",
    "Professional Zell Max plus 2",
    "BCAA Kapseln",
    "Aminosäure 2300 Kapseln",
    "Professional Triple Protein Complex",
    "Professional Thermo Burner",
    "L-Glutamine Powder neutral",
    "Professional Pure CLA Capsules",
    "Professional Double Protein Complex",
    "Muscle Creatine",
    "Creatine Caps",
    "BCAA Plus",
    "Whey Amino Tablets",
    "Whey Isolate 100% Erdbeer",
    "Muscle D-Fine",
    "Formula 80 Protein Complex Heidelbeer-Joghurt",
    "Soya Protein Shake Schokolade",
    "Proteinplus 80% Shake Banane",
    "Whey Protein Isolate Schoko",
    "Fitmaxx Soya Protein Schoko/Vanille",
    "Protein Plus Power Shake div Sorten",
    "Whey Molke- und Milchprotein Shake Vanille",
    "Whey Protein 100% Vanille",
    "Whey Protein",
    "Recovery Shake Schoko",
    "Active Energy Charge",
    "Fit Active",
    "Fit Active Plus Blutorange",
    "Active Fit Active Plus Q10",
    "Fit Active L-Carnitine Drink",
    "Body Molke Pro",
    "Muscle Supergainer Schoko-Honig",
    "Whey Gainer",
    "Glutargo forte Zitrone",
    "Energy Gel liquid",
    "Isoactive Isotonic Sports Drink Zitrone",
    "Gainer Shake Vanille",
    "Gainer Shake Schokolade",
    "Energizer Ultra Gel Cola-Geschmack",
    "Body Molke Pro L-Carnitine",
    "Muscle X-Plode",
    "Professional Weight Gainer",
    "Chimpanzee Energy Bar Aprikose",
    "Chimpanzee Slim Bar Preiselbeere & Nüsse",
    "Ride Sportriegel Erdnuss-Karamell",
    "Crunch Fit Bar Joghurt",
    "Active Energy Balance XXL",
    "Active Oats Bar",
    "Body Diet Fit",
    "Energate Balance Bar Erdbeer-Vanille",
    "L-Carnitine Bar Schoko-Crisp",
    "Ovo Sport",
    "Protein Bar Sweet Peanut",
    "Bio Vegan Protein Riegel Vanille",
    "Bio Vegan Protein Riegel Cocos",
    "Bio Vegan Protein Riegel Choco Maca",
    "53% Protein Bar Cookies",
    "Power Pack classic white",
    "Muscle Nutri Meal",
    "Power Pack classic dark",
    "Energy Bar div. Sorten",
    "Natural Energy Cereal Riegel Sweet'n Salty",
    "Proteinplus 30% Bar Vanille-Kokos",
    "Proteinplus 30% Bar Cappuccino Caramel-Crisp",
    "Proteinplus Bar LowCarb Vanille",
    "Proteinplus 30% Bar Schokolade",
    "Proteinplus Bar Erdbeer",
    "Energize Bar Berry",
    "Fitmaxx Bar 27% Protein",
    "Fit'n Lite L-Carnitine Low Carb",
    "Proteinplus + L-Carnitine Himbeer-Joghurt Riegel",
    "Power Pack Haferflockenriegel Bananenbrot",
    "Protein Wafer",
    "Professional Weight Gainer Riegel",
    "30% Protein Bar Kokos",
    "pro-Sports Müsliriegel Choco-Orange",
    "pro-Sports Müsliriegel Rote Beeren-Joghurt",
    "Corny Sport Riegel 30% Protein Schoko",
    "Corny Sport Riegel 30% Protein Karamell",
    "Corny Sport 30% Eiweiß Buttermilch-Zitrone",
    "Dörrfleisch vom Rind"
  });

  List<String> _test = <String>["kek", "kekomat"];


  @override
  Widget build(BuildContext context) {

    user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        title: Text("Neue Einkaufsliste erstellen"),
      ),
      body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: _nameTextController,
                    autofocus: true,
                    onChanged: (text){
                      setState(() {
                        if(text.length > 1){
                          _nameIsValid = true;
                          if(_productsIsNotEmpty) {
                            _listIsValid = true;
                          }
                        } else {
                          _nameIsValid = false;
                          _listIsValid = false;
                        }
                        text.length > 1 ? _nameIsValid = true : _nameIsValid = false;
                      });
                    },
                    onSubmitted: (term) => {
                      FocusScope.of(context).requestFocus(myFocusNode),
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.all(3),
                      labelText: 'Name',
                      errorText: _nameIsValid ? null : 'Bitte einen gültigen Namen eingeben',
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Produkte:"),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _productTextController,
                              focusNode: myFocusNode,
                              onSubmitted: (term) => {
                                if(_productTextController.text.length > 1){
                                  _addProduct(_productTextController.text)
                                },
                                FocusScope.of(context).requestFocus(myFocusNode),
                              },
                              //keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.all(3),
                                labelText: 'Produkt eingeben',
                                errorText: _productsIsNotEmpty ? _productIsValid ? null : 'Dieses Produkt ist bereits in der Einkaufsliste' : 'Die Einkaufsliste benötigt Produkte',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () =>
                            {
                              if(_productTextController.text.length > 1){
                                _addProduct(_productTextController.text)
                              },
                            }
                          ),


                          PopupMenuButton<int>(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Icon(Icons.category),
                                    Text("Kategorien")
                                  ],
                                )
                              ),

                              PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(Icons.search),
                                      Text("Suchen")
                                    ],
                                  )
                              ),
                            ]
                          ),


                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25.0),
                        constraints: BoxConstraints(
                          maxHeight: 530,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color(0xffeeeeee),
                        ),
                        child: ListView.builder(
                            itemCount: _products.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,
                            itemBuilder: (BuildContext context, int index){
                              return Dismissible(
                                key: Key(_products[index].name),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  child: Icon(Icons.delete, color: Colors.white,),
                                  alignment: AlignmentDirectional.centerStart,
                                  padding: EdgeInsets.only(left: 15),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      stops: [0, 0.3],
                                      colors: [Colors.red, Color(0xffeeeeee)],
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                ),
                                onDismissed: (direction){
                                  setState(() {
                                    _products.removeAt(index);
                                    if(_products.length > 0){
                                      _productsIsNotEmpty = true;
                                      if(_nameIsValid){
                                        _listIsValid = true;
                                      }
                                    } else {
                                      _productsIsNotEmpty = false;
                                      _listIsValid = false;
                                    }
                                  });
                                },
                                child: Container(
                                    child: CheckboxListTile(
                                        value: _products[index].bought,
                                        title: new Text("${_products[index].name}"),
                                        controlAffinity: ListTileControlAffinity.leading,
                                        onChanged: (bool val) { itemChange(val, index); },
                                        secondary: IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red,),
                                            onPressed: ()=>(){},
                                        ),
                                    )
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  )
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          backgroundColor: _listIsValid ? Colors.green : Colors.grey,
          onPressed: () => _listIsValid ? _createShoppingList() : null,
      ),
    );
  }

}