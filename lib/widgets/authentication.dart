import 'package:flutter/material.dart';
import 'package:shoppy/widgets/pages/login.dart';
import 'package:shoppy/widgets/pages/register.dart';

enum _AuthType {SignIn, SignUp}

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {

  _AuthType type = _AuthType.SignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        getPage(),
        GestureDetector(
          onTap: () {
            setState(() {
              if (type == _AuthType.SignIn) {
                type = _AuthType.SignUp;
              } else {
                type = _AuthType.SignIn;
              }
            });
          },
          child: Text(
            getText(),
            style: TextStyle(color: Colors.blueAccent),
          ),
        )
      ],
    );
  }

  Widget getPage() => type == _AuthType.SignIn ? LoginPage() : RegisterPage();

  String getText() => type == _AuthType.SignIn ? "Don't have an account yet? Create one here." : "Already have an account? Sign in here.";
}

