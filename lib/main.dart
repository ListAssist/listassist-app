// Flutter code sample for material.AppBar.1

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:shoppy/services/auth.dart';

// Run App
void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shoppy",
      home: Scaffold(
        body: Center(
            child: Container(
              margin: EdgeInsets.all(50),
              child: Column(
               children: <Widget>[
                 StreamBuilder(
                   stream: authService.user,
                   builder: (context, snapshot) {
                     if (snapshot.hasData) {
                       return Text("logged in");
                     } else {
                       return Text("not logged in");
                     }
                   }
                 ),
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
                 MaterialButton(
                   onPressed: () => authService.signOut(),
                   color: Colors.red,
                   textColor: Colors.black,
                   child: Text("Logout"),
                 ),
               ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            )
            )
        )
      ),
    );
  }
}
