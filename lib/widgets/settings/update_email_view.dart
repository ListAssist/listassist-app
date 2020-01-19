import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/validators/email.dart';
import 'package:progress_indicator_button/progress_button.dart';

class UpdateEmailView extends StatefulWidget {
  FirebaseUser firebaseUser;

  UpdateEmailView(this.firebaseUser);

  @override
  _UpdateEmailView createState() => _UpdateEmailView();
}

class _UpdateEmailView extends State<UpdateEmailView> {
  final _emailController = TextEditingController();
  final _repeatEmailController = TextEditingController();
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
                  TextSpan(text: 'Bitte gib deine '),
                  TextSpan(text: 'neue Email-Adresse', style: TextStyle(fontWeight: FontWeight.bold)),
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
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email-Adresse',
                  errorText: _errorText.isNotEmpty ? _errorText : null,
                  icon: Icon(Icons.email),
                ),
                validator: EmailValidator(),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text) {
                  if (_validateRealTime) {
                    if (_formKey.currentState.validate()) {}
                  }
                  if (_emailController.text.isEmpty || _repeatEmailController.text.isEmpty) {
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
                controller: _repeatEmailController,
                decoration: InputDecoration(
                  hintText: 'Email-Adresse wiederholen',
                  errorText: _errorText2.isNotEmpty ? _errorText2 : null,
                  icon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                //validator: EmailValidator(),
                onChanged: (text) {
                  if (_validateRealTime) {
                    if (_emailController.text == _repeatEmailController.text) {
                      setState(() {
                        _submitEnabled = true;
                        _errorText2 = "";
                      });
                    } else {
                      setState(() {
                        _submitEnabled = false;
                        _errorText2 = "Die Email-Adressen sind nicht gleich";
                      });
                    }
                  }
                  if (_emailController.text.isEmpty || _repeatEmailController.text.isEmpty) {
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
              child: Container(
                width: 120,
                height: 40,
                margin: EdgeInsets.only(top: 15.0),
                child: ProgressButton(
                  child: Text(
                    "Email ändern",
                    style: TextStyle(color: Colors.white),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Theme.of(context).primaryColor,
                  progressIndicatorColor: Colors.white,
                  progressIndicatorSize: 20,
                  //textColor: Colors.white,
                  onPressed: (AnimationController controller) async {
                    _validateRealTime = true;
                    setState(() {});
                    if (_formKey.currentState.validate()) {
                      if (_emailController.text == _repeatEmailController.text) {
                        controller.forward();
                        bool connected = await connectivityService.testInternetConnection();
                        if (!connected) {
                          // I am NOT connected to a network.
                          Future.delayed(Duration(milliseconds: 250)).then((value) async {
                            //Navigator.of(context).pop();
                            InfoOverlay.showErrorSnackBar("Kein Internetzugriff, versuche es erneut");
                            setState(() {
                              _errorText2 = "Kein Internetzugriff";
                            });
                            controller.reverse();
                          });
                        } else {
                          // I am connected to a network.
                          authService.updateEmail(widget.firebaseUser, _emailController.text).catchError((_) {
                            InfoOverlay.showErrorSnackBar("Fehler beim Ändern der Email-Adresse");
                          }).then((_) {
                            databaseService.updateEmail(widget.firebaseUser.uid, _emailController.text).catchError((_) {
                              InfoOverlay.showErrorSnackBar("Fehler beim Ändern der Email-Adresse");
                            }).then((_) {
                              InfoOverlay.showInfoSnackBar("Die Email-Adresse wurde geändert");
                              Navigator.of(context).pop();
                            });
                          });
                        }
                      } else {
                        setState(() {
                          _errorText2 = "Die Email-Adressen sind nicht gleich";
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
