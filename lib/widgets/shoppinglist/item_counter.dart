import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemCounter extends StatefulWidget {

  int count;
  final Function() addCount;
  final Function() subtractCount;
  ItemCounter({Key key, this.count, @required this.addCount, @required this.subtractCount}) : super(key: key);

  @override
  _ItemCounter createState() => _ItemCounter();
}

class _ItemCounter extends State<ItemCounter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 60,
      child: Row(
        children: <Widget>[
          Text(widget.count.toString(), style: TextStyle(fontSize: 17),),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: widget.count == 1 ? Colors.red : Theme.of(context).primaryColor),
            onPressed: () {
              widget.subtractCount();
            },
          ),
          /*IconButton(
            icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
            onPressed: () {
              widget.addCount();
            },
          ),*/
        ],
      ),
    );
  }

}
