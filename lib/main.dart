import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:listassist/models/current-screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/sidebar.dart';
import 'package:listassist/widgets/authentication.dart';

void main() => runApp(MyApp());

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> authScaffoldKey = GlobalKey<ScaffoldState>();

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ScreenModel>(
      model: ScreenModel(),
      child: MaterialApp(
        title: "ListAssist",
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