import 'package:flutter/material.dart';

class ShoppinglistsettingsView extends StatefulWidget{
  ShoppinglistsettingsViewState createState()=> ShoppinglistsettingsViewState();
}

class ShoppinglistsettingsViewState extends State<ShoppinglistsettingsView> {

  int _currValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Text(
                    "Wählen Sie ihr bevorzugtes Design aus:",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: GestureDetector(
                        onTap: () => setState(() => _currValue = 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Radio(
                            groupValue: _currValue,
                            onChanged: (int i) => setState(() => _currValue = i),
                            value: 1,
                          ),

                          Image.asset('images/ViewSetting1.png', width: 250,),

                        ]
                      )
                    )
                  ),

                  Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: GestureDetector(
                          onTap: () => setState(() => _currValue = 2),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio(
                                  groupValue: _currValue,
                                  onChanged: (int i) => setState(() => _currValue = i),
                                  value: 2,
                                ),

                                Image.asset('images/ViewSetting2.png', width: 250,),

                              ]
                          )
                      )
                  ),



                ])
        )
    );
  }
}