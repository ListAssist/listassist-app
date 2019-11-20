import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/current-screen.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/sidebar.dart';
import 'package:listassist/widgets/authentication/authentication.dart';
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
          StreamProvider<User>.value(value: authService.userDoc,),
          StreamProvider<bool>.value(value: authService.loading.asBroadcastStream()),
          StreamProvider<FirebaseUser>.value(value: authService.user)
        ],
        child: MaterialApp(
          title: "ListAssist",
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            brightness: Brightness.light
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

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 600),
      child: user != null ?
        Scaffold(
          key: mainScaffoldKey,
          body: Body(),
          drawer: Sidebar(),
        ) : Scaffold(
       key: authScaffoldKey,
       body: AnimatedSwitcher(
         duration: Duration(milliseconds: 600),
         child: loading ? SpinKitDoubleBounce(color: Colors.blueAccent) : AuthenticationPage(),
       ),
       resizeToAvoidBottomInset: false,
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