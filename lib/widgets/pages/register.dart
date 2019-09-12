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
            SocialSignInButtons(prependedString: "Sign up",)
          ],
        )
    );;
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
                    validator: (value) => EmailValidator.validate(value) ? null : "Bitte eine E-Mail eingeben.",
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
                      maxLines: 1,
                      autovalidate: true,
                      obscureText: true,
                      validator: (value) => value.length >= 6 ? null : "The password must be at least 6 characters long.",
                      onSaved: (value) => _password = value,
                      decoration: InputDecoration(
                          hintText: "Password",
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
                "Sign up",
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

