import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/validators/email.dart';
import 'package:provider/provider.dart';

class AddGroup extends StatefulWidget {
  @override
  _AddGroup createState() => _AddGroup();
}

class _AddGroup extends State<AddGroup> {

  final _memberTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  List<String> _members = [];

  _addMember(email) {
    setState(() {
      _memberTextController.clear();
      _members.add(email);
    });
  }

  _createGroup() {
    print(_members);
    print(_nameTextController.text);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameTextController.dispose();
    _memberTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        title: Text("Neue Gruppe erstellen"),
      ),
      body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: _nameTextController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(3),
                    labelText: 'Gruppenname',
                  ),
                )
              ),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Gruppenmitglieder:"),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _memberTextController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.all(3),
                                labelText: 'Email Adresse eingeben',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () =>
                                _addMember(_memberTextController.text),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _members.map((x) => Text(x)).toList(),
                      ),
                    ],
                  )
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          backgroundColor: Colors.green,
          onPressed: () => _createGroup()
      ),
    );
  }

}