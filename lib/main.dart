import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shoppy/models/current-screen.dart';
import 'package:shoppy/services/auth.dart';
import 'package:shoppy/widgets/sidebar.dart';
import 'package:shoppy/widgets/authentication.dart';


void main() => runApp(MyApp());

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> authScaffoldKey = GlobalKey<ScaffoldState>();

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
                    key: mainScaffoldKey,
                    body: Body(),
                    drawer: Sidebar(),
                  );
              } else {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  key: authScaffoldKey,
                  body: AuthenticationPage()
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