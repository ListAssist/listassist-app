import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/current-screen.dart';
import 'package:listassist/widgets/intro-slider/intro_slider.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/widgets/sidebar.dart';
import 'package:listassist/widgets/authentication/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/User.dart';

void main() => runApp(MyApp());

/*Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}*/

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> authScaffoldKey = GlobalKey<ScaffoldState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: authService.userDoc,
        ),
        StreamProvider<bool>.value(value: authService.loading.asBroadcastStream().defaultIfEmpty(true)),
        StreamProvider<FirebaseUser>.value(value: authService.user),
      ],
      child: ScopedModel<ScreenModel>(
        model: ScreenModel(),
        child: MaterialApp(title: "ListAssist", theme: ThemeData(primarySwatch: Colors.indigo, brightness: Brightness.light), home: MainApp()),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  /*final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
*//*
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("NACHRICHT VON onMessage: $message");
        //Navigator.push(context, MaterialPageRoute(builder: (context) => InviteView()));
      },
      //onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("NACHRICHT VON onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("NACHRICHT VON onResume: $message");
        //Navigator.push(context, MaterialPageRoute(builder: (context) => InviteView()));
      },
    );

  }*/

  bool firstLaunch = false;
  var prefs;

  initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
    firstLaunch = prefs.getBool("firstLaunch");
    //mach ich so weils mit ?? kurz angezeigt wird beim Starten der App wenns eigentlich false ist
    if(firstLaunch == null) firstLaunch = true;
  }

  onIntroSliderExit() {
    setState(() {
      firstLaunch = false;
    });
    prefs.setBool("firstLaunch", false);
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    User docUser = Provider.of<User>(context);
    bool loading = Provider.of<bool>(context);

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 600),
        child: user != null
            ? Scaffold(
                key: mainScaffoldKey,
                body: docUser != null ? firstLaunch ? IntroSliderView(onExit: onIntroSliderExit,) : Body() : null,
                drawer: docUser != null ? Sidebar() : null,
              )
            : Scaffold(
                key: authScaffoldKey,
                body: AnimatedSwitcher(
                  duration: Duration(milliseconds: 600),
                  child: loading != null && loading ? SpinKitDoubleBounce(color: Colors.blueAccent) : AuthenticationPage(),
                ),
                resizeToAvoidBottomInset: false,
              ));
  }
}

class Body extends StatefulWidget {
  createState() => _Body();
}

class _Body extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ScreenModel>(builder: (context, child, model) => model.screen);
  }
}
