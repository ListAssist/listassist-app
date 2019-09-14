import 'package:flutter/material.dart';
import 'package:shoppy/services/auth.dart';
import 'package:shoppy/widgets/authentication.dart';

void main() => runApp(MyApp());

/// Scaffold key to create snackbar anywhere..
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shoppy",
      home: Scaffold(
        key: scaffoldKey,
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
