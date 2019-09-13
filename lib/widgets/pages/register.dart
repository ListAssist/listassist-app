import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/services/auth.dart';

import 'login.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _RegisterForm(),
            Divider(),
            SocialSignInButtons(prependedString: "Registrieren",)
          ],
        )
    );
  }

}

class _RegisterForm extends StatelessWidget {
  final _formKey = new GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  String _username = "";

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    maxLines: 1,
                    autovalidate: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Bitte eine E-Mail eingeben.";
                      } else if (!EmailValidator.validate(value)) {
                        return "Bitte gültige E-Mail eingeben.";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => _email = value,
                    decoration: InputDecoration(
                        hintText: "Email",
                        icon: Icon(
                          Icons.mail_outline,
                          color: Colors.black,
                        )
                    ),
                  ),
                  TextFormField(
                    maxLines: 1,
                    autovalidate: true,
                    validator: (value) => value.isEmpty ? "Bitte einen Usernamen eingeben." : null,
                    onSaved: (value) => _username = value,
                    decoration: InputDecoration(
                        hintText: "Username",
                        icon: Icon(
                          Icons.person_outline,
                          color: Colors.black,
                        )
                    ),
                  ),
                  TextFormField(
                      onFieldSubmitted: (_) => submit(),
                      maxLines: 1,
                      autovalidate: true,
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Bitte ein Passwort eingeben.";
                        } else if (value.length < 6) {
                          return "Das Passwort muss mindestens 6 Stellen lang sein.";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => _password = value,
                      decoration: InputDecoration(
                          hintText: "Passwort",
                          icon: Icon(
                            Icons.lock_outline,
                            color: Colors.black,
                          )
                      )
                  ),
                ],
              ),
            ),
            MaterialButton(
              child: Text(
                "Registrieren",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onPressed: () => submit(),
              color: Colors.blueAccent,
            )
          ],
        )
    );
  }

  void submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      await authService.signUpWithMail(_email, _password, _username);
    }
  }

}

