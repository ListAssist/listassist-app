import 'package:flutter/material.dart';


class ShoppingListDetail extends StatelessWidget {
  final String title;
  ShoppingListDetail({this.title = "Einkaufsliste"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: FlutterLogo(size: 100)
      )
    );
  }
}