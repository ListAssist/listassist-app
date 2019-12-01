import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/validators/email.dart';
import 'package:listassist/validators/password.dart';
import 'package:listassist/validators/username.dart';

import 'package:listassist/widgets/forms/formfield.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'login.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(25),
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

class _RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";
  String _username = "";

  TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _passwordVerifyFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
  }

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
                    controller: _passwordController,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordVerifyFocus);
                    },
                    focusNode: _passwordFocus,
                  ),
                  ReactiveTextInputFormField(
                    validator: (value) {
                      if (_passwordController.text != value || value.isEmpty) {
                        return "Die Passwörter müssen übereinstimmen.";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => _password = value,
                    hintText: "Passwort bestätigen",
                    icon: Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    obscureText: true,
                    onFieldSubmitted: (_) => submit(),
                    focusNode: _passwordVerifyFocus,
                  ),
                ],
              ),
            ),
            Container(
              width: 170,
              height: 40,
              child: ProgressButton(
                child: Text(
                  "Registrieren",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
                onPressed: (AnimationController controller) async {
                  controller.forward();
                  await submit();
                  controller.reverse();
                },
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Theme.of(context).primaryColor,
                progressIndicatorColor: Colors.white,
                progressIndicatorSize: 20,
              ),
            )
          ],
        )
    );
  }

  Future<void> submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      await authService.signUpWithMail(_email, _password, _username);
    }
  }
}

