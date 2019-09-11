// Flutter code sample for material.AppBar.1

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/material.dart';

import 'package:shoppy/services/auth.dart';
import 'package:shoppy/widgets/sidebar.dart';

// Run App
void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shoppy",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        body: Center(
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
            )
        ),
        drawer: Sidebar()
      ),
    );
  }
}
