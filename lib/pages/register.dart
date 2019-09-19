import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shoppy/services/auth.dart';
import 'package:shoppy/validators/email.dart';
import 'package:shoppy/validators/password.dart';
import 'package:shoppy/validators/username.dart';

import 'package:shoppy/widgets/formfield.dart';
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

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();


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
                  ReactiveTextInputFormField(
                    validator: EmailValidator(),
                    onSaved: (value) => _email = value,
                    hintText: "Email",
                    icon: Icon(
                        Icons.mail_outline,
                        color: Colors.black
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_){
                      FocusScope.of(context).requestFocus(_usernameFocus);
                    },
                  ),
                  ReactiveTextInputFormField(
                    validator: UsernameValidator(),
                    onSaved: (value) => _username = value,
                    hintText: "Username",
                    icon: Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                    focusNode: _usernameFocus,
                  ),
                  ReactiveTextInputFormField(
                    validator: PasswordRegisterValidator(),
                    onSaved: (value) => _password = value,
                    hintText: "Passwort",
                    icon: Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    obscureText: true,
                    onFieldSubmitted: (_) => submit(),
                    focusNode: _passwordFocus,
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

