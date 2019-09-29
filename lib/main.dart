import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
              return AnimatedSwitcher(
                  // TODO: Do another animation
                  duration: const Duration(milliseconds: 600),
                  child: snapshot.hasData
                      ? Scaffold(
                          key: mainScaffoldKey,
                          body: Body(),
                          drawer: Sidebar(),
                        )
                      : Scaffold(
                          resizeToAvoidBottomInset: false,
                          key: authScaffoldKey,
                          body: StreamBuilder(
                            initialData: false,
                            stream: authService.loading,
                            builder: (context, isLoadingSnapshot) {
                              return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  child: isLoadingSnapshot.data
                                      ? SpinKitDoubleBounce(color: Colors.blueAccent)
                                      : AuthenticationPage()
                              );
                            },
                          )
                        )
              );
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