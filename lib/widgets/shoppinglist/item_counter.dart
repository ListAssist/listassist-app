import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      height: 60,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).primaryColor),
            onPressed: () {

            },
          ),
          Text("1"),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
            onPressed: () {

            },
          ),
        ],
      ),
    );
  }

}
