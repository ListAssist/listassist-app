import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/models/Invite.dart' as model;
import 'package:listassist/services/snackbar.dart';


class Invite extends StatefulWidget {
  final model.Invite invite;
  Invite({this.invite});

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
                Text(widget.invite.groupname, style: Theme.of(context).textTheme.title),
                Text("von ${widget.invite.from}", style: Theme.of(context).textTheme.subhead)
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              final HttpsCallable accept = CloudFunctions.instance.getHttpsCallable(
                  functionName: "acceptInvite"
              );
              try {
                dynamic resp = await accept.call(<String, dynamic>{
                  "inviteid": widget.invite.id
                });
                if(resp.data["status"] == "Failed"){
                  InfoSnackbar.showErrorSnackBar("Fehler beim Akzeptieren der Einladung");
                }else {
                  InfoSnackbar.showInfoSnackBar("Einladung akzepiert");
                }
              }catch (e) {
                InfoSnackbar.showErrorSnackBar("Fehler: ${e.message}");
              }
            },
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
    bool declined = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctx) {
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
                      TextSpan(text: "${this.widget.invite.groupname}", style: TextStyle(fontWeight: FontWeight.bold)),
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
                if(!declined){
                  Navigator.of(context).pop();
                }
              },
            ),
            FlatButton(
              child: Text("Ablehnen"),
              onPressed: () async {
                declined = true;
                final HttpsCallable decline = CloudFunctions.instance.getHttpsCallable(
                    functionName: "declineInvite"
                );
                try {
                  dynamic resp = await decline.call(<String, dynamic>{
                    "inviteid": widget.invite.id,
                  });
                  if(resp.data["status"] == "Failed"){
                    InfoSnackbar.showErrorSnackBar("Fehler beim Ablehnen der Einladung");
                  }else {
                    InfoSnackbar.showInfoSnackBar("Einladung abgelehnt");
                  }
                }catch (e) {
                  InfoSnackbar.showErrorSnackBar("Fehler: ${e.message}");
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}