import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:shoppy/services/auth.dart';
import 'package:email_validator/email_validator.dart';

class Authentication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _LoginForm(),
            Divider(),
            _SocialSignInButtons()
          ],
        )
    );
  }
}

class _LoginForm extends StatelessWidget {
  final _formKey = new GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return
      Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: _formKey,
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value.isEmpty ? "Bitte eine E-Mail eingeben!" : null,
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
                      obscureText: true,
                      validator: (value) => "Your password needs to be at least 6 character big!",
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
                "Log in",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onPressed: () => submit(),
              color: Colors.blueAccent,
            )
          ],
      );
  }

  void submit() async {
    print(_formKey.currentState.validate());

  authService.signInWithMail(_email, _password);
  }

}

class _SocialSignInButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SignInButton(
        Buttons.Google,
        onPressed: () => authService.signIn(AuthenticationType.Google),
        text: "Sign in with Google",
        ),
        SignInButton(
          Buttons.Facebook,
          onPressed: () => authService.signIn(AuthenticationType.Facebook),
          text: "Sign in with Facebook",
        ),
        SignInButton(
          Buttons.Twitter,
          onPressed: () => authService.signIn(AuthenticationType.Twitter),
          text: "Sign in with Twitter",
        ),
      ],
    );
  }

}