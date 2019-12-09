import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/settings/updateProfileDataDialog.dart';

class ReauthenticateForm extends StatefulWidget {
  FirebaseUser firebaseUser;
  User user;

  ReauthenticateForm(this.firebaseUser, this.user);

  @override
  _ReauthenticateForm createState() => _ReauthenticateForm();
}

class _ReauthenticateForm extends State<ReauthenticateForm> {
  final _passwordController = TextEditingController();
  String _errorText = "";

  var loginDialog = UpdateProfileDataDialog();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(8.0),
            child:
            new RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0
                ),
                children: <TextSpan>[
                  TextSpan(text: 'Bitte melde dich an, um deine Identität als '),
                  TextSpan(text: widget.user.displayName, style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' zu bestätigen'),
                ],
              ),
            )
        ),

        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Passwort',
              errorText: _errorText.isNotEmpty ? _errorText : null,
              icon: Icon(Icons.lock_outline),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text("Einloggen"),
            color: Colors.blueAccent[700],
            textColor: Colors.white,
            onPressed: () async{
              String erg = await authService.reauthenticateUser(widget.firebaseUser, widget.firebaseUser.email, _passwordController.text);
              print(erg);
              if(erg == "loggedin"){
                Navigator.pop(context);
                loginDialog.showUpdateEmailDialog(context, widget.firebaseUser);
              }else {
                setState(() {
                  _errorText = erg;
                });
              }
            },
          ),
        )
      ],
    );
  }
}