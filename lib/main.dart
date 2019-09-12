// Flutter code sample for material.AppBar.1

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/material.dart';
import 'package:shoppy/services/auth.dart';
import 'package:shoppy/widgets/authentication.dart';

// Run App
void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shoppy",
      home: Scaffold(
        /// Prevents resizing when opening keyboard: resizeToAvoidBottomInset: false,
        resizeToAvoidBottomInset: false,
        body: Center(
            child: StreamBuilder(
                   stream: authService.user,
                   builder: (context, snapshot) {
                     if (snapshot.hasData) {
                       return
                         MaterialButton(
                           onPressed: () => authService.signOut(),
                           color: Colors.red,
                           textColor: Colors.black,
                           child: Text("Logout"),
                         );
                     } else {
                       return AuthenticationPage();
                     }
                   }
                 ),
            )
            )
        );
  }
}
