import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/settings/updateProfileDataDialog.dart';
import 'package:progress_indicator_button/progress_button.dart';

class ReauthenticateForm extends StatefulWidget {
  BuildContext context;
  FirebaseUser firebaseUser;
  User user;
  String mode;

  ReauthenticateForm(this.context, this.firebaseUser, this.user, this.mode);

  @override
  _ReauthenticateForm createState() => _ReauthenticateForm();
}

class _ReauthenticateForm extends State<ReauthenticateForm> {
  var _passwordControllerrrrr = TextEditingController();
  String _errorText = "";

  var loginDialog = UpdateProfileDataDialog();

  @override
  void dispose() {
    _passwordControllerrrrr.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
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
            controller: _passwordControllerrrrr,
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
          child: Container(
            width: 100,
            height: 40,
            margin: EdgeInsets.only(top: 15.0),
            child: ProgressButton(
              child: Text("Einloggen",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Theme.of(context).primaryColor,
              progressIndicatorColor: Colors.white,
              progressIndicatorSize: 20,
              //textColor: Colors.white,
              onPressed: (AnimationController controller) async{

                if(_passwordControllerrrrr.text.isEmpty) {
                  _errorText = "Bitte Passwort eingeben";
                  setState(() {});
                  return;
                }
                bool connected = await connectivityService.testInternetConnection();
                if (connected) {
                  // I am not connected to a network
                  controller.forward();
                  Future.delayed(Duration(seconds: 1)).then((value) async{
                    controller.reverse();
                    //Navigator.of(context).pop();
                    InfoOverlay.showErrorSnackBar("Kein Internetzugriff, versuche es erneut");
                    setState(() {
                      _errorText = "Kein Internetzugriff";
                    });
                  });
                } else {
                  // I am connected to a network
                  controller.forward();
                  String erg = await authService.reauthenticateUser(widget.firebaseUser, _passwordControllerrrrr.text);
                  controller.reverse();
                  print(erg);
                  if(erg == "loggedin"){
                    Navigator.pop(context);
                    if(widget.mode == "email"){
                      loginDialog.showUpdateEmailDialog(context, widget.firebaseUser);
                    } else if(widget.mode == "password"){
                      loginDialog.showUpdatePasswordDialog(context, widget.firebaseUser);
                    }
                  }else {
                    setState(() {
                      _errorText = erg;
                    });
                  }
                }
              },
            ),
          ),
        )
      ],
    );
  }
}