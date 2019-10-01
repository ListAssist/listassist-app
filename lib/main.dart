import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/current-screen.dart';
import 'package:listassist/services/db.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/sidebar.dart';
import 'package:listassist/widgets/authentication.dart';

import 'models/User.dart';

void main() => runApp(MyApp());

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> authScaffoldKey = GlobalKey<ScaffoldState>();

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ScreenModel>(
      model: ScreenModel(),
      child: MultiProvider(
        providers: [
          StreamProvider<FirebaseUser>.value(value: authService.user,),
          StreamProvider<bool>.value(value: authService.loading.asBroadcastStream())
        ],
        child: MaterialApp(
            title: "ListAssist",
            theme: ThemeData(
              primarySwatch: Colors.indigo,
            ),
            home: MainApp()
        ),
      )
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    bool loading = Provider.of<bool>(context);

    return MaterialApp(
        title: "ListAssist",
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: AnimatedSwitcher(
            duration: Duration(milliseconds: 600),
            child: user != null ?
            StreamProvider<User>.value(
                value: databaseService.streamProfile(user),
                child: Scaffold(
                  key: mainScaffoldKey,
                  body: Body(),
                  drawer: Sidebar(),
              )
            )
             :
           Scaffold(
             key: authScaffoldKey,
             body: AuthenticationPage(),
             resizeToAvoidBottomInset: false,
           )
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