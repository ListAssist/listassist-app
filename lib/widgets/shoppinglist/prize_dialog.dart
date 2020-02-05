import 'package:flutter/material.dart';

class PrizeDialog extends StatefulWidget {
  String name;
  double prize;

  PrizeDialog({this.name, this.prize});

  @override
  _PrizeDialogState createState() => _PrizeDialogState();
}

class _PrizeDialogState extends State<PrizeDialog> {
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    _textFieldController.text = widget.prize.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Preis von ' + widget.name.toString()),
      content: TextField(
        controller: _textFieldController,
        decoration: InputDecoration(hintText: "Preis"),
        keyboardType: TextInputType.number,

      ),
      actions: <Widget>[
        FlatButton(
          child: Text('SPEICHERN'),
          onPressed: () {
            print(double.parse(_textFieldController.text));
            Navigator.of(context).pop(double.parse(_textFieldController.text));
          },
        ),

      ],
    );
  }
}