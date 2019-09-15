// Flutter code sample for material.AppBar.1

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shoppy/models/current-screen.dart';

import 'package:shoppy/services/auth.dart';
import 'package:shoppy/widgets/sidebar.dart';

// Run App
void main() => runApp(MyApp());

GlobalKey<ScaffoldState> mainScaffold = GlobalKey();

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ScreenModel>(
      model: ScreenModel(),
      child: MaterialApp(
        title: "Shoppy",
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: StreamBuilder(
            stream: authService.user,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return
                  Scaffold(
                    key: mainScaffold,
                    body: Body(),
                    drawer: Sidebar(),
                  );
              } else {
                return Scaffold(
                  body: Login()
                );
              }
            }
        ),
      )
    );
  }
}

class Body extends StatefulWidget {
  createState() => _Body();
}

class _Body extends State<Body> {

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ScreenModel>(
      builder: (context, child, model) => model.screen
    );
  }
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return /*Scaffold(
        drawer: Sidebar(),
        body: */Center(
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
              MaterialButton(
                onPressed: () => authService.googleSignIn(),
                color: Colors.white,
                textColor: Colors.black,
                child: Text("Mit Google einloggen"),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
         /* )*/
        )
    );
  }
}