import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:listassist/pages/login.dart';
import 'package:listassist/pages/register.dart';


BuildContext authContext;
enum _AuthType {SignIn, SignUp}

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  _AuthType type = _AuthType.SignIn;

  @override
  Widget build(BuildContext context) {
    authContext = context;

    return AnimatedCrossFade(
        firstCurve: LinearHalfCurve(),
        secondCurve: LinearHalfCurve().flipped,
        duration: Duration(milliseconds: 600),
        firstChild: FinalLoginPage(changeMainState: changeMainState),
        secondChild: FinalRegisterPage(changeMainState: changeMainState),
        crossFadeState: type == _AuthType.SignIn ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
          return Stack(
            children: <Widget>[
              Positioned(
                key: bottomChildKey,
                left: 0.0,
                top: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: bottomChild,
              ),
              Positioned(
                key: topChildKey,
                child: topChild,
              ),
            ],
          );
        },
    );
  }

  void changeMainState() => setState(() { type = type == _AuthType.SignIn ? _AuthType.SignUp : _AuthType.SignIn; });

}

class LinearHalfCurve extends Curve {
  @override
  double transformInternal(double t) {
    if(t < 0.5) {
      return t*2; // goes from 0-1.0 when t is 0-0.5
    }
    return 1.0; // cap to 1.0 when t is above 0.5
  }
}

class FinalLoginPage extends StatelessWidget {
  final Function changeMainState;

  FinalLoginPage({Key key, @required this.changeMainState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LoginPage(),
        GestureDetector(
          onTap: () => changeMainState(),
          child: Text(
            "Hast du noch kein ListAssist Konto? Erstelle hier eines!",
            style: TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }
}

class FinalRegisterPage extends StatelessWidget {
  final Function changeMainState;

  FinalRegisterPage({Key key, @required this.changeMainState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RegisterPage(),
        GestureDetector(
          onTap: () => changeMainState(),
          child: Text(
            "Du hast bereits ein ListAssist Konto? Logge dich hier ein!",
            style: TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }
}