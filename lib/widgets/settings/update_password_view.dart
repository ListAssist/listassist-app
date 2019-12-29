import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:progress_indicator_button/progress_button.dart';

class UpdatePasswordView extends StatefulWidget {
  FirebaseUser firebaseUser;

  UpdatePasswordView(this.firebaseUser);

  @override
  _UpdatePasswordView createState() => _UpdatePasswordView();
}

class _UpdatePasswordView extends State<UpdatePasswordView> {
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorText = "";

  //Errortext vom 2ten input field (Email Wiederholen)
  String _errorText2 = "";

  //Wenn true wird der Input bei jedem Change validiert
  //Wird aktiviert wenn man das Form zum ersten mal submittet
  bool _validateRealTime = false;

  bool _submitEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(8.0),
            child: new RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                children: <TextSpan>[
                  TextSpan(text: 'Bitte gib dein '),
                  TextSpan(text: 'neues Passwort', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' ein'),
                ],
              ),
            )),
        Form(
          key: _formKey,
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Neues Passwort',
                  errorText: _errorText.isNotEmpty ? _errorText : null,
                  icon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte ein Passwort eingeben';
                  } else if (value.length <= 5) {
                    return 'Bitte ein längeres Passwort eingeben';
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                onChanged: (text) {
                  if (_validateRealTime) {
                    if (_formKey.currentState.validate()) {}
                  }
                  if (_passwordController.text.isEmpty || _repeatPasswordController.text.isEmpty) {
                    setState(() {
                      _submitEnabled = false;
                    });
                  } else {
                    setState(() {
                      _submitEnabled = true;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: true,
                controller: _repeatPasswordController,
                decoration: InputDecoration(
                  hintText: 'Passwort wiederholen',
                  errorText: _errorText2.isNotEmpty ? _errorText2 : null,
                  icon: Icon(Icons.lock_outline),
                ),
                onChanged: (text) {
                  if (_validateRealTime) {
                    if (_passwordController.text == _repeatPasswordController.text) {
                      setState(() {
                        _submitEnabled = true;
                        _errorText2 = "";
                      });
                    } else {
                      setState(() {
                        _submitEnabled = false;
                        _errorText2 = "Die Passwörter sind nicht gleich";
                      });
                    }
                  }
                  if (_passwordController.text.isEmpty || _repeatPasswordController.text.isEmpty) {
                    setState(() {
                      _submitEnabled = false;
                    });
                  } else {
                    setState(() {
                      _submitEnabled = true;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 153,
                height: 40,
                margin: EdgeInsets.only(top: 15.0),
                child: ProgressButton(
                  child: Text(
                    "Passwort festlegen",
                    style: TextStyle(color: Colors.white),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Theme.of(context).primaryColor,
                  progressIndicatorColor: Colors.white,
                  progressIndicatorSize: 20,
                  onPressed: (AnimationController controller) async {
                    _validateRealTime = true;
                    if (_formKey.currentState.validate()) {
                      if (_passwordController.text == _repeatPasswordController.text) {
                        controller.forward();

                        var connectivityResult;
                        try {
                          connectivityResult = await Connectivity().checkConnectivity();
                        } on PlatformException catch (e) {
                          print(e.toString());
                        }
                        if (!(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi)) {
                          // I am NOT connected to a network.
                          Future.delayed(Duration(seconds: 1)).then((value) async {
                            //Navigator.of(context).pop();
                            InfoOverlay.showErrorSnackBar("Kein Internetzugriff, versuche es erneut");
                            setState(() {
                              _errorText2 = "Kein Internetzugriff";
                            });
                            controller.reverse();
                          });
                          return;
                        }

                        authService.updatePassword(widget.firebaseUser, _passwordController.text).catchError((_) {
                          InfoOverlay.showErrorSnackBar("Fehler beim Ändern des Passworts");
                        }).then((_) {
                          InfoOverlay.showInfoSnackBar("Das Passwort wurde geändert");
                          Navigator.of(context).pop();
                        });
                      } else {
                        setState(() {
                          _errorText2 = "Die Passwörter sind nicht gleich";
                        });
                      }
                    }
                  },
                ),
              ),
            )
          ]),
        )
      ],
    );
  }
}
