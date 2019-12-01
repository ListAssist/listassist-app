import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:listassist/widgets/authentication/login.dart';
import 'package:listassist/widgets/authentication/register.dart';


BuildContext authContext;
enum _AuthType {SignIn, SignUp}

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {

  @override
  Widget build(BuildContext context) {
    authContext = context;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text("Authentizierung"),
            bottom: TabBar(
              tabs: [
                Tab(text: "Login",),
                Tab(text: "Registrieren")
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LoginPage(),
              RegisterPage()
            ],
          ),
          resizeToAvoidBottomInset: false,
        )
    );
  }
}
