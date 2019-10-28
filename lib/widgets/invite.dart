import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class Invite extends StatefulWidget {
  final String title;
  final String creator;
  Invite({this.title = "Gruppe", this.creator = "Setscha"});

  @override
  _InviteState createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.title, style: Theme.of(context).textTheme.title),
                Text("von ${widget.creator}", style: Theme.of(context).textTheme.subhead)
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {},
            color: Colors.green,
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {_showDialog();},
            color: Colors.red,
          )
        ],
      ),
    );
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Einladung ablehnen"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(text:
                TextSpan(
                    style: new TextStyle(
                      color: Theme.of(context).textTheme.title.color,
                    ),
                    children: <TextSpan> [
                      TextSpan(text: "Sind Sie sicher, dass Sie die Einladung in die Gruppe "),
                      TextSpan(text: "${this.widget.title}", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " ablehnen möchten?")
                    ]
                )
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Ablehnen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}