import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/widgets/authentication/login.dart';
import 'package:listassist/widgets/authentication/register.dart';


BuildContext authContext;

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final List<Tab> tabs = [
    Tab(text: "Login"),
    Tab(text: "Registrieren")
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              controller: _tabController,
              tabs: tabs
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              LoginPage(),
              RegisterPage()
            ],
          ),
          resizeToAvoidBottomInset: false,
        )
    );
  }

  /// Remove Focus of any element on the page (e.g. keyboard)
  void _handleTabChange() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
