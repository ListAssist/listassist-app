import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/validators/email.dart';
import 'package:listassist/validators/password.dart';
import 'package:listassist/widgets/forms/formfield.dart';
import 'package:progress_indicator_button/progress_button.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _LoginForm(),
            Divider(),
            SocialSignInButtons()
          ],
        )
    );
  }

}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String _email = "";

  final _passwordFocus = FocusNode();

  String _password = "";

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
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  ReactiveTextInputFormField(
                    focusNode: _passwordFocus,
                    validator: PasswordValidator(),
                    onSaved: (value) => _password = value,
                    hintText: "Passwort",
                    icon: Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    obscureText: true,
                    onFieldSubmitted: (_) => submit(),
                  ),
                ],
              ),
            ),
            Container(
              width: 100,
              height: 40,
              child: ProgressButton(
                child: Text(
                  "Log in",
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

      await authService.signInWithMail(_email, _password);
    }
  }
}

class SocialSignInButtons extends StatelessWidget {
  final String prependedString;

  SocialSignInButtons({this.prependedString = "Einloggen"});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SignInButton(
          Buttons.Google,
          onPressed: () => authService.signIn(AuthenticationType.Google),
          text: "$prependedString mit Google",
        ),
        SignInButton(
          Buttons.Facebook,
          onPressed: () => authService.signIn(AuthenticationType.Facebook),
          text: "$prependedString mit Facebook",
        ),
//        SignInButton(
//          Buttons.Twitter,
//          onPressed: () => authService.signIn(AuthenticationType.Twitter),
//          text: "$prependedString mit Twitter",
//        ),
      ],
    );
  }


}
